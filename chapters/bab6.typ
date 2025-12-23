= Integrasi & Version Control

== Strategi Branching Git

Tim menggunakan Git Flow dengan branch terpisah untuk setiap fitur:

```
main (production)
  |-- feature/backend-setup (Azka)
  |-- feature/ui-widgets (Dian)
  |-- feature/auth-nav (Vina)
  |-- feature/transaction-logic (Nadif)
```

*Commit Convention*:
```
feat: add movie detail screen
fix: resolve seat selection bug
style: update color scheme
refactor: improve calculation logic
docs: add README documentation
```

== Integrasi Antar Modul

=== Backend Integration (Azka → All)

FirebaseServiceAzka sebagai centralized API:

```dart
// Di HomeScreen (Dian)
final movies = await FirebaseServiceAzka().getMovies();

// Di BookingController (Nadif)
await _firebaseService.createBooking(booking);
```

=== UI Integration (Dian → All)

Component reusable dengan styling konsisten:

```dart
// MovieCard dipakai di berbagai screen
MovieCardDian(movie: movie, onTap: () => navigateToDetail(movie.movieId))

// Constants untuk konsistensi
Container(
  color: AppColors.netflixRed,
  child: Text('Title', style: AppTextStyles.movieTitle),
)
```

=== State Management (Nadif → All)

Consumer pattern di semua screen:

```dart
// Di SeatSelectionScreen (Vina)
Consumer<BookingControllerNadif>(
  builder: (context, controller, _) => Column(
    children: [
      Text('Selected: ${controller.selectedSeats.length} seats'),
      Text('Total: Rp ${controller.calculateTotalPrice(...)}'),
      ElevatedButton(
        onPressed: controller.hasSelectedSeats ? () => _confirm() : null,
        child: Text('Confirm'),
      ),
    ],
  ),
)

// Di HomeScreen (Dian) - statistik user
Consumer<BookingControllerNadif>(
  builder: (context, controller, _) {
    final total = controller.userBookings.fold(0, (sum, b) => sum + b.totalPrice);
    return Text('${controller.userBookings.length} bookings, Rp $total spent');
  },
)
```

=== Navigation Integration (Vina → All)

Routing konsisten:

```dart
// Login → Home
Navigator.pushReplacement(context, 
  MaterialPageRoute(builder: (_) => HomeScreenDian()));

// Home → Detail → Seat Selection → Profile
Navigator.push(context, MaterialPageRoute(...));
```

== Error Handling Strategy

=== Network & Loading States

```dart
try {
  _isLoading = true;
  notifyListeners();
  await firebaseService.createBooking(booking);
} catch (e) {
  _error = e.toString().contains('network')
    ? 'Tidak ada koneksi internet'
    : 'Gagal membuat booking';
} finally {
  _isLoading = false;
  notifyListeners();
}

// Di UI
if (_isLoading) CircularProgressIndicator()
else if (_error != null) ErrorWidget(error: _error)
else ContentWidget()
```

=== Empty State

```dart
if (_movies.isEmpty) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.movie_outlined, size: 60),
        Text('No movies available'),
        ElevatedButton(onPressed: _refreshData, child: Text('Refresh')),
      ],
    ),
  );
}
```

== Testing Checklist

*Authentication*: Register (valid/invalid email), Login (benar/salah), Logout

*Movie Browsing*: Load data, detail film, hero animation, refresh, empty state

*Seat Selection*: Pilih available, reject booked, toggle, hitung harga real-time

*Booking*: Validasi, QR generation, save Firebase, update booked_seats

*Calculation*: Diskon genap 10%, pajak judul >10 char, total akurat

== Performance Optimization

```dart
// 1. Lazy Loading
ListView.builder(
  itemCount: bookings.length,
  itemBuilder: (context, index) => BookingCard(booking: bookings[index]),
)

// 2. Image Caching (otomatis di Flutter)
Image.network(movie.posterUrl, fit: BoxFit.cover)

// 3. Batch Updates
Future<void> refreshAll() async {
  _isLoading = true;
  notifyListeners(); // 1x
  
  await Future.wait([loadMovies(), loadBookings(), loadProfile()]);
  
  _isLoading = false;
  notifyListeners(); // 1x
}
```

== Deployment

*Platform Support*: Android, iOS, Web, Windows, macOS

*Build Commands*:
```bash
flutter build apk --release      # Android
flutter build ios --release      # iOS
flutter build web --release      # Web
```

== Collaboration Workflow

```bash
# Feature Development
git checkout -b feature/auth-nav
git add .
git commit -m "feat: add login screen"
git push origin feature/auth-nav

# Merge
git checkout main
git merge feature/auth-nav
git push origin main
```

== Documentation

```markdown
# CineBooking App
Flutter + Firebase cinema booking app

## Features
- Authentication, Movie browsing, Seat selection
- QR Code tickets, Booking history

## Setup
1. Clone repo
2. flutter pub get
3. Configure Firebase
4. flutter run

## Team
Azka (Backend), Dian (UI), Vina (Auth), Nadif (Logic)
```

== Kesimpulan

Integrasi sukses dengan: centralized FirebaseService API, consistent UI components dan styling, reactive state dengan Provider, robust navigation pattern, comprehensive error handling (network/loading/empty), performance optimization (lazy loading, caching, batch updates), dan structured Git workflow.