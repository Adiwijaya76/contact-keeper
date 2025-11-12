
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/contact.dart';
import 'contacts_controller.dart';

class ContactFormPage extends ConsumerStatefulWidget {
  const ContactFormPage({super.key, this.existing});
  final Contact? existing;

  @override
  ConsumerState<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends ConsumerState<ContactFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _dobController;

  DateTime? _birthDate;

  bool get isEditing => widget.existing != null;
  bool _saving = false;

  // Animations
  late final AnimationController _sec1Ctrl;
  late final AnimationController _sec2Ctrl;
  late final AnimationController _fabCtrl;
  late final Animation<double> _sec1Fade;
  late final Animation<Offset> _sec1Slide;
  late final Animation<double> _sec2Fade;
  late final Animation<Offset> _sec2Slide;
  late final Animation<double> _fabScale;
  late final Animation<Offset> _fabSlide;

  @override
  void initState() {
    super.initState();
    _nameController    = TextEditingController(text: widget.existing?.name ?? '');
    _phoneController   = TextEditingController(text: widget.existing?.phone ?? '');
    _addressController = TextEditingController(text: widget.existing?.address ?? '');

    _birthDate         = widget.existing?.birthDate;
    _dobController     = TextEditingController(
      text: _birthDate == null ? '' : _formatDob(_birthDate!),
    );

    _sec1Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _sec2Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fabCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));

    _sec1Fade  = CurvedAnimation(parent: _sec1Ctrl, curve: Curves.easeOut);
    _sec1Slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic)).animate(_sec1Ctrl);

    _sec2Fade  = CurvedAnimation(parent: _sec2Ctrl, curve: Curves.easeOut);
    _sec2Slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic)).animate(_sec2Ctrl);

    _fabScale = Tween<double>(begin: 0.92, end: 1)
        .chain(CurveTween(curve: Curves.easeOutBack)).animate(_fabCtrl);
    _fabSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOut)).animate(_fabCtrl);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _sec1Ctrl.forward();
      await Future<void>.delayed(const Duration(milliseconds: 70));
      await _sec2Ctrl.forward();
      await Future<void>.delayed(const Duration(milliseconds: 40));
      _fabCtrl.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _sec1Ctrl.dispose();
    _sec2Ctrl.dispose();
    _fabCtrl.dispose();
    super.dispose();
  }

  // ======================= DOB helpers (typed) =======================

  String _formatDob(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year.toString().padLeft(4, '0')}';

  DateTime? _parseDob(String input) {
    // expects dd/MM/yyyy
    if (input.length != 10) return null;
    final re = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$');
    final m = re.firstMatch(input);
    if (m == null) return null;

    final dd = int.tryParse(m.group(1)!);
    final mm = int.tryParse(m.group(2)!);
    final yyyy = int.tryParse(m.group(3)!);
    if (dd == null || mm == null || yyyy == null) return null;

    // quick sanity
    if (mm < 1 || mm > 12) return null;
    if (yyyy < 1900) return null;

    // construct safely, check overflow (e.g., 31/02)
    DateTime? candidate;
    try {
      candidate = DateTime(yyyy, mm, dd);
    } catch (_) {
      return null;
    }
    // ensure same day/month/year (no overflow to next month)
    if (candidate.day != dd || candidate.month != mm || candidate.year != yyyy) {
      return null;
    }

    final now = DateTime.now();
    if (candidate.isAfter(DateTime(now.year, now.month, now.day))) {
      // future date not allowed
      return null;
    }
    return candidate;
  }

  String? _dobValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Tanggal lahir wajib diisi';
    final parsed = _parseDob(v.trim());
    if (parsed == null) return 'Format harus dd/MM/yyyy & tanggal valid';
    return null;
    // _birthDate akan diset di onChanged saat valid; validator cukup cek validitas
  }

  // ============================ Save ============================

  Future<void> _saveContact() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    // sinkronisasi final (jaga-jaga)
    final parsed = _parseDob(_dobController.text.trim());
    if (parsed == null) return; // validator harusnya sudah cegah ini
    _birthDate = parsed;

    setState(() => _saving = true);
    try {
      final notifier = ref.read(contactsProvider.notifier);

      if (!isEditing) {
        final newContact = notifier.blank().copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          birthDate: _birthDate!,
        );
        await notifier.add(newContact);
      } else {
        final updated = widget.existing!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          birthDate: _birthDate!,
        );
        await notifier.updateContact(updated);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ============================ UI ============================

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            expandedHeight: 140,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            leading: IconButton(
              tooltip: 'Kembali',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 28, right: 20),
              centerTitle: false,
              title: Text(
                isEditing ? 'Edit Kontak' : 'Tambah Kontak',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                child: Column(
                  children: [
                    // Section 1
                    FadeTransition(
                      opacity: _sec1Fade,
                      child: SlideTransition(
                        position: _sec1Slide,
                        child: _SectionCard(
                          icon: Icons.person_rounded,
                          chipColor: cs.primaryContainer,
                          chipIconColor: cs.onPrimaryContainer,
                          title: 'Informasi Dasar',
                          children: [
                            _LabeledField(
                              label: 'Nama Lengkap *',
                              child: TextFormField(
                                controller: _nameController,
                                decoration: _inputDecoration(
                                  hint: 'Masukkan nama lengkap',
                                  icon: Icons.badge_rounded,
                                  cs: cs,
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                                textInputAction: TextInputAction.next,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _LabeledField(
                              label: 'Nomor Telepon *',
                              child: TextFormField(
                                controller: _phoneController,
                                decoration: _inputDecoration(
                                  hint: 'Masukkan nomor telepon',
                                  icon: Icons.phone_rounded,
                                  cs: cs,
                                ),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 +()-]')),
                                ],
                                validator: (v) {
                                  final s = v?.trim() ?? '';
                                  if (s.isEmpty) return 'Nomor telepon wajib diisi';
                                  if (s.length < 6) return 'Nomor terlalu pendek';
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).nextFocus(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 2
                    FadeTransition(
                      opacity: _sec2Fade,
                      child: SlideTransition(
                        position: _sec2Slide,
                        child: _SectionCard(
                          icon: Icons.location_on_rounded,
                          chipColor: cs.tertiaryContainer,
                          chipIconColor: cs.onTertiaryContainer,
                          title: 'Detail Lainnya',
                          children: [
                            _LabeledField(
                              label: 'Alamat',
                              child: TextFormField(
                                controller: _addressController,
                                decoration: _inputDecoration(
                                  hint: 'Masukkan alamat lengkap',
                                  icon: Icons.home_rounded,
                                  cs: cs,
                                ),
                                maxLines: 3,
                                minLines: 1,
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Birthdate typed
                            _LabeledField(
                              label: 'Tanggal Lahir *',
                              child: TextFormField(
                                controller: _dobController,
                                decoration: _inputDecoration(
                                  hint: 'dd/MM/yyyy',
                                  icon: Icons.cake_rounded,
                                  cs: cs,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                                  LengthLimitingTextInputFormatter(10),
                                  _DobTextInputFormatter(),
                                ],
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: _dobValidator,
                                onChanged: (v) {
                                  final parsed = _parseDob(v.trim());
                                  setState(() {
                                    _birthDate = parsed; // valid -> set, invalid -> null
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // FAB save
      floatingActionButton: SlideTransition(
        position: _fabSlide,
        child: ScaleTransition(
          scale: _fabScale,
          child: FloatingActionButton.extended(
            onPressed: _saving ? null : _saveContact,
            icon: _saving
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(isEditing ? Icons.save_rounded : Icons.check_rounded),
            label: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Kontak'),
            elevation: 3,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required ColorScheme cs,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: cs.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}

/* ======================= SUBWIDGETS ======================= */

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.chipColor,
    required this.chipIconColor,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final Color chipColor;
  final Color chipIconColor;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, color: chipIconColor, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/* ======================= DOB InputFormatter ======================= */

/// Memasukkan slash otomatis di posisi 2 & 5 untuk pola dd/MM/yyyy.
/// Hanya angka & '/' yang diperbolehkan, panjang maksimum 10.
class _DobTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // allow only digits and slash
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9/]'), '');
    // build with auto slash
    final digits = raw.replaceAll('/', '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length && i < 8; i++) {
      buf.write(digits[i]);
      if (i == 1 || i == 3) buf.write('/');
    }
    var text = buf.toString();
    if (text.length > 10) text = text.substring(0, 10);

    // caret position
    int sel = text.length;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: sel),
    );
  }
}
