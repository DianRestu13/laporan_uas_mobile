= State Management & Transaction Logic

Bagian ini dikerjakan oleh Nadif, mencakup state management dengan Provider dan business logic untuk booking.

== Setup Provider

```dart
class CineBookingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookingControllerNadif()),
        Provider(create: (_) => FirebaseServiceAzka()),
      ],
      child: MaterialApp(...),
    );
  }
}
```

== Booking Controller

BookingControllerNadif mengelola state dan logic booking.

=== State Variables & Methods

```dart
class BookingControllerNadif extends ChangeNotifier {
  List<String> _selectedSeats = [];
  List<BookingModelAzka> _userBookings = [];
  List<String> _bookedSeats = [];
  String? _currentUserId;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get hasSelectedSeats => _selectedSeats.isNotEmpty;
  
  // Seat selection
  void toggleSeat(String seatId) {
    if (!_bookedSeats.contains(seatId)) {
      _selectedSeats.contains(seatId)
        ? _selectedSeats.remove(seatId)
        : _selectedSeats.add(seatId);
      notifyListeners();
    } else {
      _error = 'Kursi $seatId sudah dipesan';
      notifyListeners();
    }
  }
}
```

=== Create Booking dengan Validasi

```dart
Future<String?> createBooking({
  required String movieId,
  required String movieTitle,
  required int basePrice,
}) async {
  // Validasi
  if (_currentUserId == null) throw 'Silakan login terlebih dahulu';
  if (_selectedSeats.isEmpty) throw 'Pilih minimal satu kursi';
  
  for (final seat in _selectedSeats) {
    if (_bookedSeats.contains(seat)) {
      throw 'Kursi $seat sudah dipesan orang lain';
    }
  }

  _isLoading = true;
  notifyListeners();

  try {
    final bookingId = _uuid.v4();
    final totalPrice = calculateTotalPrice(movieTitle, basePrice);
    final qrData = CalculationServiceNadif.generateQRData(...);

    final booking = BookingModelAzka(
      bookingId: bookingId,
      userId: _currentUserId!,
      movieId: movieId,
      movieTitle: movieTitle,
      seats: List.from(_selectedSeats),
      totalPrice: totalPrice,
      bookingDate: DateTime.now(),
      qrData: qrData,
    );

    await _firebaseService.createBooking(booking);
    await Future.wait([loadUserBookings(), loadBookedSeats(movieId)]);
    
    _selectedSeats.clear();
    notifyListeners();
    return bookingId;
  } catch (e) {
    _error = e.toString().contains('network')
      ? 'Tidak ada koneksi internet'
      : 'Gagal membuat booking';
    notifyListeners();
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

== Calculation Service

CalculationServiceNadif menangani semua perhitungan business logic.

=== Logika Perhitungan

```dart
// Parse seat number
static int parseSeatNumber(String seatCode) {
  return int.tryParse(seatCode) ?? 0;
}

static bool isEvenSeat(String seatCode) {
  return parseSeatNumber(seatCode) % 2 == 0;
}

// Harga kursi dengan diskon genap 10%
static int calculateSeatPrice(String seatCode, int basePrice) {
  if (isEvenSeat(seatCode)) {
    return (basePrice * 0.9).toInt(); // Diskon 10%
  }
  return basePrice;
}

// Pajak judul >10 karakter
static int calculateTitleTax(String title, int seatCount) {
  return title.length > 10 
    ? AppConstants.titleTax * seatCount  // Rp 2.500/kursi
    : 0;
}

// Total harga
static int calculateTotalPrice({
  required List<String> seats,
  required String movieTitle,
  required int basePrice,
}) {
  if (seats.isEmpty) return 0;

  int total = 0;
  for (final seat in seats) {
    total += calculateSeatPrice(seat, basePrice);
  }
  total += calculateTitleTax(movieTitle, seats.length);
  
  return total;
}
```

=== Contoh Perhitungan

Film: "The Dark Knight Returns" (24 karakter), Base: Rp 50.000, Kursi: [1,2,3,4]

```
Kursi 1 (ganjil): Rp 50.000
Kursi 2 (genap):  Rp 45.000 (diskon 10%)
Kursi 3 (ganjil): Rp 50.000
Kursi 4 (genap):  Rp 45.000 (diskon 10%)
Subtotal:         Rp 190.000
Pajak (4×2.500):  Rp 10.000
TOTAL:            Rp 200.000
```

=== Price Breakdown

```dart
static String generatePriceBreakdown({
  required String movieTitle,
  required List<String> seats,
  required int basePrice,
}) {
  final evenSeats = seats.where((s) => isEvenSeat(s)).length;
  final oddSeats = seats.length - evenSeats;
  final titleTax = calculateTitleTax(movieTitle, seats.length);
  final discount = (basePrice * 0.1 * evenSeats).toInt();

  return '''
=== PRICE BREAKDOWN ===
Base: Rp $basePrice x ${seats.length}
Even Seats ($evenSeats): -10% (Rp $discount)
Odd Seats ($oddSeats): Regular
Title Tax: ${titleTax > 0 ? '+Rp $titleTax' : 'No tax'}
TOTAL: Rp ${calculateTotalPrice(...)}
''';
}
```

=== QR Code Generation

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
  return '''
🎬🎫 CINEBOOKING TICKET 🎬🎫
===============================
MOVIE: $movieTitle
SEATS: ${seats.join(', ')}
TOTAL: Rp $totalPrice
DATE: ${DateFormat('dd/MM/yyyy HH:mm').format(bookingDate)}
BOOKING ID: $bookingId
===============================
⚠️ PERMANENT - Non-refundable
SCAN FOR THEATER ENTRY
''';
}
```

=== Helper Functions

```dart
static String formatDate(DateTime date) =>
  DateFormat('dd MMM yyyy').format(date);

static String formatDateTime(DateTime date) =>
  DateFormat('dd/MM/yyyy HH:mm').format(date);

static bool validateStudentEmail(String email) =>
  email.endsWith('@student.univ.ac.id');

static String getSeatSummary(List<String> seats) {
  final evenSeats = seats.where((s) => isEvenSeat(s)).toList();
  final oddSeats = seats.where((s) => !isEvenSeat(s)).toList();
  
  String summary = '';
  if (evenSeats.isNotEmpty) 
    summary += 'Even: ${evenSeats.join(', ')} (-10%)\n';
  if (oddSeats.isNotEmpty) 
    summary += 'Odd: ${oddSeats.join(', ')} (regular)';
  return summary.trim();
}
```

== Penggunaan di UI

=== Consumer Pattern

```dart
Consumer<BookingControllerNadif>(
  builder: (context, controller, _) {
    return Column(
      children: [
        Text('Selected: ${controller.selectedSeats.join(', ')}'),
        Text('Total: Rp ${controller.calculateTotalPrice(...)}'),
        
        ElevatedButton(
          onPressed: controller.hasSelectedSeats && !controller.isLoading
              ? () => _confirmBooking(controller)
              : null,
          child: controller.isLoading
              ? CircularProgressIndicator()
              : Text('Confirm Booking'),
        ),
        
        // Error display
        if (controller.error != null)
          Container(
            child: Row(
              children: [
                Icon(Icons.error),
                Text(controller.error!),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: controller.clearError,
                ),
              ],
            ),
          ),
      ],
    );
  },
)
```

=== QR Dialog

```dart
void _showQrDialog(BookingModelAzka booking) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Column(
        children: [
          Text('YOUR TICKET'),
          QrImageView(data: booking.qrData, size: 180),
          Text(booking.movieTitle),
          Text('Seats: ${booking.seats.join(', ')}'),
          Text('Total: Rp ${booking.totalPrice}'),
        ],
      ),
    ),
  );
}
```

== Kesimpulan

State management dengan Provider memberikan: reactive UI (perubahan state langsung terlihat), centralized logic (semua perhitungan di CalculationService), reusable functions, testable code (logic terpisah dari UI), dan maintainable structure. Business logic unik: diskon kursi genap 10%, pajak judul >10 karakter Rp 2.500/kursi, dan QR code generation.