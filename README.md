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
| 📋 **Daftar Kontak** | Menampilkan semua kontak dengan nama, telepon, dan usia. |
| 🔍 **Pencarian Dinamis** | Filter nama, nomor, atau alamat secara real-time. |
| ➕ **Tambah / Edit / Hapus** | CRUD lengkap dengan validasi dan konfirmasi. |
| 🗓️ **Umur Otomatis** | Menghitung umur dari tanggal lahir. |
| 💾 **Penyimpanan Lokal (Hive)** | Semua data tersimpan di perangkat pengguna. |
| 🪄 **Animasi Halus (Hero & Fade)** | Transisi lembut antar halaman. |
| 🎨 **Material Design 3** | Tampilan modern dan konsisten di semua platform. |

---

## 🧩 Struktur Folder  

```bash
lib/
 ├── app/
 │   ├── app.dart                 # Root aplikasi & router
 │   └── theme.dart               # Tema global (Material 3)
 │
 ├── data/
 │   └── contacts_repository_hive.dart   # Repository Hive
 │
 ├── features/
 │   └── contacts/
 │       ├── contact_detail_page.dart    # Halaman detail kontak
 │       ├── contact_form_page.dart      # Form tambah/edit
 │       ├── contacts_controller.dart    # Riverpod AsyncNotifier
 │       └── contacts_page.dart          # Daftar kontak utama
 │
 ├── models/
 │   ├── contact.dart             # Model kontak
 │   └── contact.g.dart           # Adapter Hive
 │
 ├── widgets/
 │   ├── contact_avatar.dart      # Widget avatar dengan inisial fallback
 │   └── refresh.dart             # Widget pull-to-refresh
 │
 └── main.dart                    # Entry point aplikasi
```

---

## 🏗️ Tech Stack  

| Komponen | Teknologi |
|----------|------------|
| 🧩 **Framework** | Flutter (stable) |
| ⚙️ **State Management** | Riverpod 3 |
| 💾 **Local Database** | Hive |
| 🎨 **UI Framework** | Material Design 3 |
| 🧠 **Bahasa** | Dart (Null Safety) |

---

## 🚀 Cara Menjalankan  

### 1️⃣ Clone repository  
```bash
git clone https://github.com/Adiwijaya76/contact-keeper.git
cd contact-keeper
```

### 2️⃣ Install dependencies  
```bash
flutter pub get
```

### 3️⃣ Jalankan aplikasi  
```bash
flutter run
```

### 4️⃣ Build APK Release  
```bash
flutter build apk --release
```

---

## 🧪 Perintah Pengembangan  

```bash
flutter analyze        # Analisis kualitas kode
flutter test           # Jalankan unit test
flutter pub upgrade    # Perbarui dependency
```


> 💬 Reach me on [LinkedIn](https://www.linkedin.com/in/yuda-adi-wijaya-050b47197) or [GitHub](https://github.com/Adiwijaya76)

---

## ❤️ Dukungan  

Jika kamu suka project ini:  
⭐️ **Berikan Star di GitHub** → [Adiwijaya76/contact-keeper](https://github.com/Adiwijaya76/contact-keeper)

---

© 2025 — Made with Flutter 💙 by **Yuda Adi Wijaya**
