= Bukti Keaslian Kode (Strict Mode)

Sesuai instruksi ujian untuk mencegah penggunaan *code generator* otomatis[cite: 8].

== Watermark Code
Berikut adalah bukti penggunaan suffix inisial pada variabel Widget dan Fungsi:

// Ganti dengan screenshot kode Anda
// #image("../images/watermark_code.png", width: 80%)
*Penjelasan:* Variabel `buttonLogin_budi` menunjukkan kode dibuat oleh Budi (UI Engineer)[cite: 9].

== Logic Trap (Diskon NIM)
Implementasi logika bisnis unik "Ganjil 5%, Genap Gratis Ongkir"[cite: 10].

```dart
// Contoh snippet kode (Logic Trap)
void hitungDiskon_dani(String nim) {
  int lastDigit = int.parse(nim.characters.last);
  if (lastDigit % 2 != 0) {
    // Logika Ganjil
    print("Diskon 5%");
  } else {
    // Logika Genap
    print("Gratis Ongkir");
  }
}
```