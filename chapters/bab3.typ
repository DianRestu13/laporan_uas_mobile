= Arsitektur Backend

Backend aplikasi CineBooking dikerjakan oleh Azka menggunakan Firebase sebagai Backend-as-a-Service (BaaS).

== Struktur Database Firestore

Aplikasi menggunakan 3 collection utama:

=== 1. Collection: `users`

Menyimpan data pengguna yang terdaftar.

*Fields*: email, username, created_at, balance, role, status

```dart
Future<User?> registerUser({
  required String email,
  required String password,
  required String username,
}) async {
  final cred = await _auth.createUserWithEmailAndPassword(
    email: email.trim(), password: password.trim());
    
  await _db.collection('users').doc(cred.user!.uid).set({
    'email': email.trim(),
    'username': username.trim(),
    'created_at': FieldValue.serverTimestamp(),
    'role': 'user',
    'status': 'active',
  });
  
  return cred.user;
}
```

=== 2. Collection: `movies`

Menyimpan informasi film yang tersedia.

*Fields*: title, poster_url, base_price, rating, duration, description, booked_seats

```dart
class MovieModelAzka {
  final String movieId;
  final String title;
  final int basePrice;
  final double rating;
  final List<String> bookedSeats;
  
  int get availableSeats => 48 - bookedSeats.length;
  bool isSeatAvailable(String seatId) => !bookedSeats.contains(seatId);
}

Future<List<MovieModelAzka>> getMovies() async {
  final snapshot = await _db.collection('movies').get();
  return snapshot.docs
    .map((doc) => MovieModelAzka.fromFirestore(doc))
    .toList();
}
```

=== 3. Collection: `bookings`

Menyimpan transaksi booking tiket.

*Fields*: user_id, movie_id, movie_title, seats, total_price, booking_date, qr_data

```dart
Future<void> createBooking(BookingModelAzka booking) async {
  // 1. Simpan booking
  await _db.collection('bookings')
    .doc(booking.bookingId)
    .set(booking.toFirestore());

  // 2. Update booked_seats di movies
  final movieRef = _db.collection('movies').doc(booking.movieId);
  final movieDoc = await movieRef.get();
  
  if (movieDoc.exists) {
    final currentSeats = List<String>.from(
      movieDoc.data()!['booked_seats'] ?? []);
    final updated = [...currentSeats, ...booking.seats];
    final uniqueSeats = updated.toSet().toList();
    
    await movieRef.update({'booked_seats': uniqueSeats});
  }
}
```

== Firebase Configuration

Konfigurasi multi-platform (Android, iOS, Web, Windows, macOS):

```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      default: throw UnsupportedError('Platform not supported');
    }
  }
}

// Inisialisasi
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CineBookingApp());
}
```

== Service Layer: FirebaseServiceAzka

Centralized service untuk semua operasi backend.

=== Authentication Methods

```dart
class FirebaseServiceAzka {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> loginUser({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(), password: password.trim());
    return cred.user;
  }

  Future<void> logoutUser() => _auth.signOut();
  
  User? getCurrentUser() => _auth.currentUser;
}
```

=== Booking Methods dengan Fallback

```dart
Future<List<BookingModelAzka>> getUserBookings(String userId) async {
  try {
    final snapshot = await _db.collection('bookings')
      .where('user_id', isEqualTo: userId)
      .orderBy('booking_date', descending: true)
      .get();
    return snapshot.docs.map((doc) => 
      BookingModelAzka.fromFirestore(doc)).toList();
  } catch (e) {
    // Fallback jika index belum dibuat
    if (e.toString().contains('index')) {
      final allSnapshot = await _db.collection('bookings').get();
      return allSnapshot.docs
        .map((doc) => BookingModelAzka.fromFirestore(doc))
        .where((b) => b.userId == userId)
        .toList()
        ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
    }
    return [];
  }
}
```

== Error Handling

```dart
try {
  await createBooking(booking);
} catch (e) {
  if (e.toString().contains('network')) {
    throw 'Tidak ada koneksi internet';
  } else if (e.toString().contains('permission')) {
    throw 'Akses ditolak';
  } else {
    throw 'Gagal membuat booking';
  }
}
```

== Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /movies/{movieId} {
      allow read: if true;
      allow write: if false; // Admin only
    }
    match /bookings/{bookingId} {
      allow read: if request.auth.uid == resource.data.user_id;
      allow create: if request.auth != null;
    }
  }
}
```

== Kesimpulan

Backend CineBooking menggunakan arsitektur clean dengan 3 collection utama (users, movies, bookings), model classes terpisah, service layer centralized, error handling robust dengan fallback, dan dukungan multi-platform.