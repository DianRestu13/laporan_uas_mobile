= Implementasi Antarmuka & Autentikasi

== Implementasi UI oleh Dian

=== Home Screen

HomeScreenDian menampilkan daftar film dalam grid 2 kolom dengan fitur: header user info, pull-to-refresh, loading/error state, dan floating button.

*Grid Movies dengan Empty State*:
```dart
Widget _buildMoviesGrid() {
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

  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.62,
    ),
    itemCount: _movies.length,
    itemBuilder: (_, index) => Hero(
      tag: 'movie-${_movies[index].movieId}',
      child: MovieCardDian(
        movie: _movies[index],
        onTap: () => _navigateToDetail(_movies[index].movieId),
      ),
    ),
  );
}
```

=== Movie Card Widget

Card kompak dengan poster, rating, duration, price, dan badge availability (Available/Almost Full/Sold Out).

```dart
class MovieCardDian extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSoldOut = movie.availableSeats == 0;
    final isAlmostFull = movie.availableSeats > 0 && 
                         movie.availableSeats <= 5;

    return GestureDetector(
      onTap: isSoldOut ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.netflixGrey,
        ),
        child: Column(
          children: [
            // Poster dengan loading/error handling
            ClipRRect(
              child: Image.network(movie.posterUrl, 
                height: 140, fit: BoxFit.cover),
            ),
            // Info: title, rating, duration, price, badge
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(movie.title, maxLines: 2),
                  Row(children: [
                    Icon(Icons.star, size: 12),
                    Text('${movie.rating}'),
                  ]),
                  Row(children: [
                    Text('Rp ${movie.basePrice}'),
                    Container(
                      decoration: BoxDecoration(
                        color: isSoldOut ? AppColors.seatSold 
                          : isAlmostFull ? AppColors.warningOrange 
                          : AppColors.successGreen,
                      ),
                      child: Text(isSoldOut ? 'SOLD OUT' 
                        : '${movie.availableSeats} left'),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

=== Movie Detail Screen

Tampilan detail dengan poster full-width, gradient overlay, dan informasi lengkap.

```dart
Widget _buildPosterSection() {
  return Stack(
    children: [
      Image.network(_movie.posterUrl, height: 400, fit: BoxFit.cover),
      Container(
        height: 400,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
      ),
      Positioned(
        bottom: 20, left: 20, right: 20,
        child: Column(
          children: [
            Text(_movie.title, style: TextStyle(fontSize: 32)),
            Row(
              children: [
                Icon(Icons.star), Text('${_movie.rating}'),
                Icon(Icons.timer), Text('${_movie.duration} min'),
                Container(
                  color: AppColors.netflixRed,
                  child: Text('Rp ${_movie.basePrice}'),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
```

== Implementasi Auth oleh Vina

=== Login Screen dengan Validasi

LoginScreenAzka dengan validasi lengkap untuk login dan register.

*Validasi Form*:
```dart
Future<void> _submitForm(BuildContext context) async {
  // Basic validation
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    setState(() => _error = 'Please fill all fields');
    return;
  }

  // Register validation
  if (!_isLogin) {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    
    if (!CalculationServiceNadif.validateStudentEmail(_emailController.text)) {
      setState(() => _error = 
        'Only student emails allowed (@student.univ.ac.id)');
      return;
    }
    
    if (_usernameController.text.length < 3) {
      setState(() => _error = 'Username must be at least 3 characters');
      return;
    }
    
    if (_passwordController.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
  }

  // Process
  setState(() => _isLoading = true);
  try {
    final service = Provider.of<FirebaseServiceAzka>(context, listen: false);
    
    if (_isLogin) {
      await service.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      await service.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
      );
      await service.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  } catch (e) {
    setState(() => _error = e.toString());
  } finally {
    setState(() => _isLoading = false);
  }
}
```

*UI dengan Error Display*:
```dart
// Error message
if (_error.isNotEmpty)
  Container(
    decoration: BoxDecoration(color: Colors.red[900]),
    child: Row(
      children: [
        Icon(Icons.error),
        Text(_error),
      ],
    ),
  ),

// Submit button
ElevatedButton(
  onPressed: _isLoading ? null : () => _submitForm(context),
  child: _isLoading
    ? CircularProgressIndicator()
    : Text(_isLogin ? 'Sign In' : 'Sign Up'),
)
```

=== Navigation System

*Auth Wrapper*:
```dart
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<FirebaseServiceAzka>(context);
    final user = service.getCurrentUser();
    
    return user != null ? HomeScreenDian() : LoginScreenAzka();
  }
}
```

*Splash Screen*:
```dart
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: [
            Icon(Icons.movie, size: 80, color: Color(0xFFE50914)),
            Text('CINEBOOKING', style: TextStyle(fontSize: 32)),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```

== Theme & Constants

Color palette Netflix-inspired untuk konsistensi UI:

```dart
class AppColors {
  static const netflixRed = Color(0xFFE50914);
  static const netflixDark = Color(0xFF141414);
  static const netflixBlack = Color(0xFF000000);
  static const netflixGrey = Color(0xFF2D2D2D);
  
  static const seatAvailable = Color(0xFF404040);
  static const seatSelected = Color(0xFF2196F3);
  static const seatSold = Color(0xFFF44336);
}
```

== Kesimpulan

UI implementation mencakup: HomeScreen dengan grid responsif, MovieCard dengan badge status, MovieDetail dengan hero animation, LoginScreen dengan validasi lengkap (email mahasiswa, password 6+ karakter, username 3+ karakter), dan navigation system dengan AuthWrapper dan SplashScreen. Semua menggunakan theme konsisten Netflix-inspired.