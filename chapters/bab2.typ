= Bukti Keaslian Kode

== Watermark Code (Suffix Naming)

Untuk membuktikan keaslian kode dan mencegah penggunaan code generator, setiap anggota tim menggunakan suffix nama pada class, function, dan variable penting.

=== Contoh Implementasi Suffix

*Azka (Backend)*:
```dart
class FirebaseServiceAzka {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  Future<User?> registerUser(...) async { }
  Future<List<MovieModelAzka>> getMovies() async { }
}

class MovieModelAzka {
  final String movieId;
  final String title;
  // ...
}

class UserModelAzka {
  final String uid;
  final String email;
  // ...
}

class BookingModelAzka {
  final String bookingId;
  final String userId;
  // ...
}
```

*Dian (UI)*:
```dart
class HomeScreenDian extends StatefulWidget { }

class MovieCardDian extends StatelessWidget {
  final dynamic movie;
  final VoidCallback onTap;
  // ...
}

class MovieDetailScreenDian extends StatefulWidget {
  final String movieId;
  // ...
}
```

*Vina (Auth & Seat)*:
```dart
class SeatSelectionScreenVina extends StatefulWidget {
  final String movieId;
  final String movieTitle;
  final int basePrice;
  // ...
}

class SeatItemVina extends StatelessWidget {
  final String seatId;
  final bool isSold;
  final bool isSelected;
  // ...
}
```

*Nadif (Logic)*:
```dart
class BookingControllerNadif extends ChangeNotifier {
  List<String> _selectedSeats = [];
  List<BookingModelAzka> _userBookings = [];
  // ...
}

class CalculationServiceNadif {
  static bool validateStudentEmail(String email) { }
  static int calculateTotalPrice(...) { }
  // ...
}

class ProfileScreenNadif extends StatefulWidget {
  final String? highlightBookingId;
  // ...
}
```

== Logic Trap (Business Logic Unik)

Aplikasi ini memiliki logika bisnis khusus untuk perhitungan harga yang tidak umum digunakan di template generator:

=== 1. Diskon Kursi Genap (10%)

Kursi dengan nomor genap mendapatkan diskon 10% dari harga dasar.

```dart
static int parseSeatNumber(String seatCode) {
  try {
    return int.tryParse(seatCode) ?? 0;
  } catch (_) {
    return 0;
  }
}

static bool isEvenSeat(String seatCode) {
  final seatNumber = parseSeatNumber(seatCode);
  return seatNumber % 2 == 0;
}

static int calculateSeatPrice(String seatCode, int basePrice) {
  if (isEvenSeat(seatCode)) {
    // Diskon 10% untuk kursi genap
    return (basePrice * (1 - AppConstants.evenSeatDiscount)).toInt();
  }
  return basePrice;
}
```

*Contoh Perhitungan*:
- Kursi 1 (ganjil): Rp 50.000
- Kursi 2 (genap): Rp 45.000 (diskon 10%)
- Kursi 3 (ganjil): Rp 50.000
- Kursi 4 (genap): Rp 45.000 (diskon 10%)

=== 2. Pajak Judul Film

Jika judul film lebih dari 10 karakter, dikenakan pajak Rp 2.500 per kursi.

```dart
static int calculateTitleTax(String title, int seatCount) {
  return title.length > 10 
    ? AppConstants.titleTax * seatCount 
    : 0;
}
```

*Contoh*:
- "Inception" (9 karakter) → Tidak kena pajak
- "The Dark Knight" (16 karakter) → Pajak Rp 2.500 × jumlah kursi

=== 3. Total Perhitungan Harga

```dart
static int calculateTotalPrice({
  required List<String> seats,
  required String movieTitle,
  required int basePrice,
}) {
  if (seats.isEmpty) return 0;
  
  int total = 0;
  
  // Hitung harga per kursi (dengan diskon genap)
  for (final seat in seats) {
    total += calculateSeatPrice(seat, basePrice);
  }
  
  // Tambah pajak judul
  total += calculateTitleTax(movieTitle, seats.length);
  
  return total;
}
```

*Contoh Kasus*:
- Film: "The Dark Knight Returns" (24 karakter)
- Kursi: [1, 2, 3]
- Base Price: Rp 50.000

Perhitungan:
- Kursi 1 (ganjil): Rp 50.000
- Kursi 2 (genap): Rp 45.000
- Kursi 3 (ganjil): Rp 50.000
- Subtotal: Rp 145.000
- Pajak judul (3 kursi × Rp 2.500): Rp 7.500
- *Total: Rp 152.500*

=== 4. Price Breakdown Display

```dart
static String generatePriceBreakdown({
  required String movieTitle,
  required List<String> seats,
  required int basePrice,
}) {
  final total = calculateTotalPrice(
    seats: seats,
    movieTitle: movieTitle,
    basePrice: basePrice,
  );
  
  final evenSeats = seats.where((seat) => isEvenSeat(seat)).length;
  final oddSeats = seats.length - evenSeats;
  final titleTax = calculateTitleTax(movieTitle, seats.length);
  final evenSeatDiscount = (basePrice * AppConstants.evenSeatDiscount * evenSeats).toInt();
  final hasTitleTax = movieTitle.length > 10;

  return '''
=== PRICE BREAKDOWN ===
Base Price: Rp $basePrice x ${seats.length}
Even Seats ($evenSeats): -10% each (Rp $evenSeatDiscount discount)
Odd Seats ($oddSeats): Regular price
${hasTitleTax
    ? "Title Tax (${movieTitle.length} chars): +Rp $titleTax"
    : "Title Tax: No tax"
}

TOTAL: Rp $total
''';
}
```

== Validasi Email Mahasiswa

Sistem hanya menerima email dengan domain `@student.univ.ac.id`:

```dart
static bool validateStudentEmail(String email) {
  return email.endsWith(AppConstants.studentEmailSuffix);
}

// Konstanta
class AppConstants {
  static const String studentEmailSuffix = '@student.univ.ac.id';
}
```

*Implementasi di LoginScreen*:
```dart
if (!_isLogin) {
  if (!CalculationServiceNadif.validateStudentEmail(
    _emailController.text)) {
    setState(() => _error = 
      'Only student emails allowed (@student.univ.ac.id)');
    return;
  }
}
```

== QR Code dengan Format Khusus

Setiap booking menghasilkan QR Code dengan format unik yang tidak bisa digenerate otomatis:

```dart
static String generateQRData({
  required String bookingId,
  required String movieTitle,
  required List<String> seats,
  required int totalPrice,
  required DateTime bookingDate,
  required String movieId,
  required String userId,
}) {
  final formatter = DateFormat('dd/MM/yyyy HH:mm');
  return '''
🎬🎫 CINEBOOKING TICKET 🎬🎫
===============================
MOVIE: $movieTitle
SEATS: ${seats.join(', ')}
TOTAL: Rp $totalPrice
DATE: ${formatter.format(bookingDate)}
BOOKING ID: $bookingId
USER ID: ${userId.substring(0, 8)}
MOVIE ID: $movieId
===============================
⚠️ This ticket is PERMANENT
⚠️ Non-refundable & Non-transferable
===============================
SCAN FOR THEATER ENTRY
''';
}
```

*Contoh Output QR*:
```
🎬🎫 CINEBOOKING TICKET 🎬🎫
===============================
MOVIE: Inception
SEATS: 1, 2, 5
TOTAL: Rp 142500
DATE: 23/12/2025 14:30
BOOKING ID: 7a3b9c4d-2e1f-4a5b-8c6d-9e7f1a2b3c4d
USER ID: abc12345
MOVIE ID: movie_001
===============================
⚠️ This ticket is PERMANENT
⚠️ Non-refundable & Non-transferable
===============================
SCAN FOR THEATER ENTRY
```

== Seat Summary Helper

```dart
static String getSeatSummary(List<String> seats) {
  if (seats.isEmpty) return 'No seats selected';
  
  final evenSeats = seats.where((seat) => isEvenSeat(seat)).toList();
  final oddSeats = seats.where((seat) => !isEvenSeat(seat)).toList();
  
  String summary = '';
  if (evenSeats.isNotEmpty) {
    summary += 'Even seats: ${evenSeats.join(', ')} (-10% each)\n';
  }
  if (oddSeats.isNotEmpty) {
    summary += 'Odd seats: ${oddSeats.join(', ')} (regular price)';
  }
  return summary.trim();
}
```

== Kesimpulan Bukti Keaslian

Dari implementasi di atas, dapat dibuktikan bahwa:

1. *Suffix Naming*: Setiap class menggunakan nama anggota sebagai suffix (Azka, Dian, Vina, Nadif)

2. *Logic Trap Unik*: 
   - Diskon kursi genap (tidak umum)
   - Pajak berdasarkan panjang judul
   - Format QR dengan template khusus

3. *Validasi Custom*: Email harus domain mahasiswa

4. *Business Logic Kompleks*: Perhitungan harga dengan multiple factor

Semua ini membuktikan bahwa kode ditulis manual oleh tim, bukan hasil code generator.