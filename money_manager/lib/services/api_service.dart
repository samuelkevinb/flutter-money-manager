import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://675ae78c9ce247eb19350471.mockapi.io';
  final String exchangeRateBaseUrl = 'https://api.exchangerate-api.com/v4/latest/USD'; // Gantilah 'YOUR_API_KEY' dengan API Key yang valid

  // Fungsi untuk membuat request GET dengan penanganan error
  Future<http.Response> _get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'))
          .timeout(Duration(seconds: 10)); // Menambahkan timeout 10 detik
      return response;
    } catch (e) {
      print('Error during GET request: $e');
      throw Exception('Request gagal: $e');
    }
  }

  // Fungsi untuk membuat request POST dengan penanganan error
  Future<http.Response> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: json.encode(body),
          )
          .timeout(Duration(seconds: 10)); // Timeout selama 10 detik

      return response;
    } catch (e) {
      print('Error during POST request: $e');
      throw Exception('Request gagal: $e');
    }
  }

  // Fungsi untuk mendapatkan daftar transaksi
  Future<List<dynamic>> getTransactions() async {
    final response = await _get('/transactions'); // Mengambil data transaksi dari API

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body); // Mengembalikan data transaksi sebagai list
      } catch (e) {
        throw Exception('Failed to decode transactions: $e');
      }
    } else {
      throw Exception('Failed to load transactions, Status code: ${response.statusCode}');
    }
  }

  // Fungsi untuk mendapatkan kurs mata uang dari API
  Future<Map<String, dynamic>> getExchangeRate(String baseCurrency) async {
    final url = Uri.parse('$exchangeRateBaseUrl$baseCurrency'); // API untuk mengambil kurs

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));
      print('Exchange Rate Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          return json.decode(response.body); // Mengembalikan data kurs dalam format map
        } catch (e) {
          throw Exception('Failed to decode exchange rate: $e');
        }
      } else {
        throw Exception('Failed to load exchange rate, Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during exchange rate request: $e');
      throw Exception('Request gagal: $e');
    }
  }

  // Fungsi untuk membuat transaksi baru
  Future<bool> createTransaction(Map<String, dynamic> transactionData) async {
    final response = await _post(
      '/transactions', // Endpoint untuk menambahkan transaksi
      transactionData,
    );

    print('Create transaction status: ${response.statusCode}');
    return response.statusCode == 201; // Mengembalikan true jika berhasil membuat transaksi
  }

  // Fungsi untuk login
  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final response = await _get('/users'); // Mengambil semua data pengguna

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);
      print('Users found: ${users.length}'); // Cek jumlah pengguna yang ditemukan

      // Mencari apakah ada pengguna dengan username dan password yang cocok
      for (var user in users) {
        if (user['username'] == username && user['password'] == password) {
          print('Login successful for username: $username');
          return user; // Mengembalikan data pengguna jika login berhasil
        }
      }
      print('Invalid username or password');
      return null; // Jika tidak ada yang cocok
    } else {
      throw Exception('Failed to load users, Status code: ${response.statusCode}');
    }
  }

  // Fungsi untuk mendapatkan data pengguna berdasarkan username
  Future<Map<String, dynamic>?> getUserData(String username) async {
    final response = await _get('/users'); // Mengambil semua data pengguna

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);

      // Mencari pengguna berdasarkan username
      for (var user in users) {
        if (user['username'] == username) {
          print('User data found: $user');
          return user; // Mengembalikan data pengguna jika ditemukan
        }
      }
      print('User not found');
      return null; // Jika pengguna tidak ditemukan
    } else {
      throw Exception('Failed to load users, Status code: ${response.statusCode}');
    }
  }

  // Fungsi untuk registrasi
  Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String username,
    required String password,
  }) async {
    final response = await _post(
      '/users',
      {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'password': password,
      },
    );

    print('Register user status: ${response.statusCode}');
    return response.statusCode == 201; // Jika status code adalah 201 berarti berhasil
  }
}
