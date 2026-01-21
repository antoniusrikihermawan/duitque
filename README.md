## Panduan Persiapan Kolaborasi (PENTING)

Repositori ini tidak menyertakan file konfigurasi Firebase demi keamanan. Sebelum menjalankan aplikasi, silakan ikuti langkah berikut:

1. **Dapatkan File Konfigurasi**: Hubungi admin/pemilik proyek untuk mendapatkan file berikut:
   - `google-services.json`
   - `firebase_options.dart`
   - `firebase.json`

2. **Penempatan File**:
   - Letakkan `google-services.json` di folder: `android/app/src`
   - Letakkan `firebase_options.dart` di folder: `lib/widgets`
   - Letakkan `firebase.json` di root folder proyek (folder utama).

3. **Jalankan Aplikasi**:
   Setelah file terpasang, jalankan perintah:
   ```bash
   flutter pub get
   flutter run
