import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money_manager/model/currency_model.dart';

class CurrencyService {
  final String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/USD'; // Contoh API untuk konversi mata uang

  // Fungsi untuk mengambil data mata uang
  Future<Map<String, Currency>> getCurrencies() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Map<String, Currency> currencies = {};

      // Memasukkan data ke dalam map berdasarkan kode mata uang dan rate
      for (var currencyCode in data['rates'].keys) {
        currencies[currencyCode] = Currency(
          code: currencyCode,
          rate: (data['rates'][currencyCode] ?? 0.0).toDouble(), // Pastikan rate tidak null
        );
      }
      return currencies;
    } else {
      throw Exception('Failed to load currencies');
    }
  }
}
