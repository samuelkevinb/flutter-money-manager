// currency_model.dart

class Currency {
  final String code; // Kode mata uang (misalnya 'USD', 'EUR')
  final double rate; // Nilai tukar mata uang terhadap mata uang dasar (misalnya 1 USD = 0.85 EUR)

  // Konstruktor untuk membuat instance Currency
  Currency({required this.code, required this.rate});

  // Membuat instance Currency dari Map (misalnya JSON response)
  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      code: map['code'],
      rate: map['rate'].toDouble(),
    );
  }

  // Mengubah instance Currency menjadi Map, biasanya untuk API POST
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'rate': rate,
    };
  }
}

// Model untuk response API dengan daftar mata uang
class CurrencyResponse {
  final Map<String, Currency> currencies;

  CurrencyResponse({required this.currencies});

  // Fungsi untuk mengonversi response JSON ke CurrencyResponse
  factory CurrencyResponse.fromJson(Map<String, dynamic> json) {
    Map<String, Currency> currencies = {};

    json['rates'].forEach((key, value) {
      currencies[key] = Currency.fromMap({'code': key, 'rate': value});
    });

    return CurrencyResponse(currencies: currencies);
  }
}
