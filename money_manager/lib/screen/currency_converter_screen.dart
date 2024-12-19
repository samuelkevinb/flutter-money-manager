import 'package:flutter/material.dart';

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController amountController = TextEditingController();
  
  String fromCurrency = 'USD'; // Mata uang asal (default USD)
  String toCurrency = 'IDR'; // Mata uang tujuan (default IDR, misalnya Rupiah)
  double conversionRate = 0.0; // Nilai tukar dari 'fromCurrency' ke 'toCurrency'
  double result = 0.0;

  // Nilai tukar tetap (contoh)
  final Map<String, double> exchangeRates = {
    'USD': 16150.70, // 1 USD = 15,000 IDR
    'EUR': 16827.97, // 1 EUR = 16,000 IDR
  };

  // Fungsi untuk mengonversi mata uang
  void _convertCurrency() {
    final double amount = double.tryParse(amountController.text) ?? 0.0;
    if (conversionRate != 0.0) {
      setState(() {
        result = amount * conversionRate; // Menghitung hasil konversi
      });
    } else {
      setState(() {
        result = 0.0; // Jika nilai tukar tidak valid
      });
    }
  }

  // Fungsi untuk memilih mata uang dan mengubah nilai tukar
  Widget buildCurrencyButton(String currencyCode, String buttonText) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          fromCurrency = currencyCode; // Memilih mata uang asal
          conversionRate = exchangeRates[currencyCode] ?? 0.0; // Memperbarui nilai tukar
        });
      },
      child: Text(buttonText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Currency Converter')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount in $fromCurrency'),
            ),
            SizedBox(height: 20),
            // Tombol untuk memilih USD atau EUR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildCurrencyButton('USD', 'USD to IDR'),
                buildCurrencyButton('EUR', 'EUR to IDR'), // Tombol EUR ke IDR
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertCurrency,
              child: Text('Convert'),
            ),
            SizedBox(height: 20),
            Text(
              'Result: $result IDR',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
