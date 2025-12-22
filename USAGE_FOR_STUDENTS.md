# Panduan Edit & Gunakan Template Typst

Dokumen ini ditujukan untuk mahasiswa yang akan menggunakan template Typst di folder proyek ini.

**Ringkasan**
- Lokasi utama file: `main.typ`, `conf.typ`, `cover.typ`, dan folder `chapters/`.
- Gunakan `typst` untuk kompilasi dan `tinymist` untuk preview interaktif.

**Struktur Proyek (singkat)**
- `main.typ` : dokumen root; gabungkan/sertakan file lain di sini.
- `conf.typ` : konfigurasi metadata (judul, pengarang, dsb.).
- `cover.typ` : halaman sampul (jika ada).
- `chapters/` : tiap bab ada pada file `chapters/babX.typ`.
- `images/` : simpan gambar yang dipakai dokumen.

**Cara Mengedit (langkah demi langkah)**
1. Buka file di folder `chapters/` sesuai bab yang ingin Anda ubah, mis. `chapters/bab1.typ`.
2. Edit teks, judul, atau tambahkan sub-bab menggunakan format Typst yang umum (paragraf, heading, daftar, code block).
3. Simpan perubahan.

Contoh menambahkan potongan kode (gunakan tiga backticks untuk raw/code fence):

```
// contoh kode di dalam file .typ — pastikan menutup kembali ```
```

Catatan: kesalahan umum yang menyebabkan kompilasi gagal:
- "unclosed delimiter" — biasanya ada tanda kurung/kurung siku yang tidak ditutup (mis. `[` atau `{`).
- "unclosed raw text" — biasanya terjadi karena code fence (```) tidak ditutup.

Jika error muncul saat kompilasi, baca pesan error yang menunjuk file/nomor baris lalu perbaiki file tersebut.

**Cara Compile PDF (CLI)**
Jalankan dari folder proyek (lokasi `main.typ`):

```zsh
typst compile main.typ output.pdf
# contoh: typst compile main.typ /tmp/main.pdf
```

Perintah ini akan menampilkan pesan error parsing jika ada masalah; perbaiki file yang disebutkan.

**Preview Interaktif (tinymist)**
Jika `tinymist` sudah terpasang di sistem, jalankan preview interaktif:

```zsh
tinymist preview main.typ --open
```

Catatan untuk pengguna VS Code:
- Workspace sudah berisi file `.vscode/settings.json` yang menunjuk ke `/usr/local/bin/tinymist` dan `/usr/local/bin/typst`.
- Setelah mengubah `.vscode/settings.json`, jalankan "Developer: Reload Window" di VS Code.

Jika preview tidak muncul di VS Code, coba jalankan `tinymist preview` di terminal untuk melihat log/erornya.

**Contoh Cara Menambah Bab Baru**
1. Buat file baru mis. `chapters/bab8.typ`.
2. Isi konten bab sesuai struktur yang sudah dipakai di bab lain.
3. Tambahkan include atau panggil file tersebut dari `main.typ` sesuai pola yang ada di `main.typ` (lihat contoh penggunaan include pada `main.typ`).

**Gambar**
- Taruh file gambar di folder `images/`.
- Sebutkan path relatif saat memasukkan gambar (lihat pola penggunaan gambar di `cover.typ` atau bab yang sudah ada).

**Tips Memperbaiki Kesalahan Lingkungan (rbenv / zsh noise)**
Jika ketika menjalankan preview muncul pesan seperti:

```
/Users/username/.zprofile:10: command not found: rbenv
```

Itu berarti file `~/.zprofile` Anda mengeksekusi sesuatu yang tidak tersedia untuk proses non-interaktif. Untuk mencegah gangguan pada proses editor/extension, amankan inisialisasi rbenv dengan pengecekan, misalnya tambahkan atau ganti baris berikut di `~/.zprofile`:

```zsh
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi
```

Atau pindahkan inisialisasi ke `~/.zshrc` sehingga hanya dieksekusi pada sesi interaktif.

**Template & Gaya Penulisan**
- Gunakan struktur bab yang konsisten: judul bab, pengantar singkat, sub-bab, dan penutup.
- Jika perlu menampilkan tabel besar, bila terjadi error parsing, coba gunakan alternatif sementara (daftar atau teks) lalu perbaiki format tabel secara bertahap.

**Jika Mahasiswa Mengalami Masalah**
- Jalankan `typst compile main.typ /tmp/main.pdf` untuk melihat pesan error yang mendetail.
- Jika kompilasi lokal berhasil tetapi VS Code preview gagal, periksa apakah extension menggunakan path absolute (lihat `.vscode/settings.json`) dan cek `~/.zprofile` untuk pesan error.

**Petunjuk Khusus: Pengguna Windows**
Berikut panduan singkat untuk mahasiswa yang bekerja di Windows (PowerShell atau Command Prompt). Jika Anda menggunakan WSL (Windows Subsystem for Linux), Anda dapat mengikuti instruksi Linux/macOS dari bagian utama tetapi jalankan perintah dalam shell WSL.

- Mengunduh dan memasang `typst` / `tinymist`:
  - Kunjungi halaman rilis Typst dan tinymist di GitHub, unduh paket `x86_64-pc-windows-msvc.zip` (atau yang sesuai), lalu ekstrak.
  - Tempatkan `typst.exe` dan `tinymist.exe` ke folder yang mudah diakses, mis. `C:\Tools\typst` atau `C:\Program Files\Typst`.

- Menambahkan ke PATH (sementara untuk sesi PowerShell saat ini):

```powershell
$env:Path += ";C:\Tools\typst"
# lalu cek versi
typst.exe --version
```

- Menambahkan ke PATH permanen (Windows):
  - Dari Command Prompt (permanent, perlu buka CMD sebagai Administrator):

```cmd
setx PATH "%PATH%;C:\Tools\typst"
```

  - Atau gunakan Settings → System → About → Advanced system settings → Environment Variables → edit `Path` untuk user atau system.
  - Perhatikan: perubahan `setx` atau lewat Settings berlaku di sesi baru (restart terminal/VS Code diperlukan).

- Menjalankan compile/preview di Windows (PowerShell / CMD):

PowerShell:
```powershell
typst.exe compile main.typ output.pdf
tinymist.exe preview main.typ --open
```

Command Prompt (CMD):
```cmd
typst.exe compile main.typ output.pdf
tinymist.exe preview main.typ --open
```

- Jika VS Code tidak menemukan binary:
  - Pastikan path absolut binary ada di workspace `.vscode/settings.json`, gunakan backslash ganda di JSON, misal:

```json
{
  "typst.typstPath": "C:\\Tools\\typst\\typst.exe",
  "tinymist.serverPath": "C:\\Tools\\typst\\tinymist.exe"
}
```

- Firewall / Port:
  - `tinymist preview` membuka server lokal (mis. `http://127.0.0.1:23625`). Jika Anda tidak dapat membuka preview, periksa apakah firewall atau antivirus memblokir proses. Biasanya akses lokal tidak diblok, tetapi jika diminta oleh Windows Defender/AV, izinkan aplikasi tersebut.

- Masalah umum di Windows:
  - Pastikan file memiliki ekstensi `.exe` ketika Anda memanggilnya.
  - Jika perintah "not found" masih muncul di PowerShell, jalankan `Get-Command typst.exe` untuk melihat lokasi yang dikenali.
  - Jika Anda lebih suka lingkungan Linux, gunakan WSL2 dan pasang `typst`/`tinymist` di distro WSL, lalu jalankan preview/compile dari sana.

Dengan langkah-langkah di atas pengguna Windows seharusnya bisa mengedit, compile, dan melihat preview sama seperti pengguna macOS/Linux.

—
File ini adalah panduan singkat; bila Anda ingin, saya bisa menambahkan:
- Contoh tabel Typst yang aman, atau
- Contoh penggunaan gambar + caption, atau
- Template file `bab.template.typ` untuk siswa mulai menulis.

Terakhir: untuk instruksi lanjutan atau menambahkan contoh, beri tahu saya contoh yang Anda mau masukkan (contoh tabel, gambar, atau potongan kode).
