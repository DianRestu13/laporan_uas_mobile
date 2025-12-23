= Pendahuluan & Pembagian Kerja

== Deskripsi Aplikasi
Aplikasi CineBooking adalah sistem pemesanan tiket bioskop berbasis mobile yang dibangun menggunakan Flutter. Aplikasi ini memungkinkan pengguna untuk melihat daftar film, memilih kursi, dan melakukan booking secara real-time dengan integrasi Firebase sebagai backend.

Fitur utama aplikasi:
- Autentikasi pengguna (Login & Register)
- Daftar film dengan informasi detail
- Pemilihan kursi interaktif
- Sistem booking dengan QR Code
- Riwayat transaksi pengguna
- Perhitungan harga otomatis dengan diskon kursi genap

== Teknologi yang Digunakan
- *Framework*: Flutter
- *Backend*: Firebase (Authentication, Firestore)
- *State Management*: Provider
- *Database*: Cloud Firestore
- *Version Control*: Git

== Pembagian Tugas Tim

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  [*Nama*], [*NIM*], [*Peran*],
  [Danish Naisyila Azka], [362458302098], [Backend Architect],
  [Dian Restu Khoirunnisa], [362458302094], [UI Engineer],
  [Vina Faizatus Sofita], [362458302094], [Auth & Navigation],
  [Nadhifah Afiyah Qurota'ain], [362458302100], [Transaction Logic],
)

=== Detail Tanggung Jawab

*Azka (Backend Architect)*:
- Setup Firebase dan konfigurasi project
- Membuat model data (MovieModel, UserModel, BookingModel)
- Implementasi FirebaseService untuk CRUD operations
- Integrasi database Firestore

*Dian (UI Engineer)*:
- Desain dan implementasi HomeScreen
- Membuat MovieCard widget
- Implementasi MovieDetailScreen
- Styling dan theming aplikasi

*Vina (Auth & Navigation)*:
- Implementasi LoginScreen dan RegisterScreen
- Handling autentikasi Firebase
- Setup routing dan navigation
- Membuat SeatSelectionScreen

*Nadif (Transaction Logic)*:
- Implementasi BookingController dengan Provider
- Logika pemilihan kursi dan validasi
- Sistem perhitungan harga dan diskon
- ProfileScreen dengan QR Code booking
- CalculationService untuk business logic