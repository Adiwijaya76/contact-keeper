# 📇 Contact Keeper  
> Flutter + Riverpod 3 + Hive — Simple, Offline-First Contact Manager  

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-40C4FF?style=for-the-badge&logo=riverpod&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-FFCA28?style=for-the-badge&logo=hive&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

---


## ✨ Fitur Utama  

| Fitur | Deskripsi |
|-------|------------|
| 📋 **Daftar Kontak** | Tampilkan semua kontak dengan nama, telepon, dan usia. |
| 🔍 **Pencarian Dinamis** | Cari berdasarkan nama, nomor, atau alamat secara real-time. |
| ➕ **Tambah / Edit / Hapus** | CRUD lengkap dengan validasi dan konfirmasi. |
| 🗓️ **Umur Otomatis** | Hitung umur dari tanggal lahir. |
| 🧠 **Penyimpanan Lokal (Hive)** | Semua data disimpan di perangkat pengguna. |
| 🪄 **Animasi Halus & Hero Transition** | Transisi fade/slide untuk pengalaman yang lembut. |
| 🎨 **Material 3 UI** | Tampilan modern dan konsisten di seluruh platform. |

---

## 🧩 Arsitektur & Struktur Folder  

```bash
lib/
 ├── app/
 │   ├── app.dart                 # Root aplikasi & konfigurasi router
 │   └── theme.dart               # Tema global (Material 3)
 │
 ├── data/
 │   └── contacts_repository_hive.dart   # Repository untuk penyimpanan Hive
 │
 ├── features/
 │   └── contacts/
 │       ├── contact_detail_page.dart    # Halaman detail kontak (SliverAppBar)
 │       ├── contact_form_page.dart      # Form tambah/edit kontak
 │       ├── contacts_controller.dart    # Riverpod AsyncNotifier untuk kontak
 │       └── contacts_page.dart          # Daftar kontak utama
 │
 ├── models/
 │   ├── contact.dart             # Model utama untuk data kontak
 │   └── contact.g.dart           # File hasil generate Hive adapter
 │
 ├── widgets/
 │   ├── contact_avatar.dart      # Widget avatar dengan fallback inisial
 │   └── refresh.dart             # Widget custom pull-to-refresh
 │
 └── main.dart                    # Entry point aplikasi Flutter
