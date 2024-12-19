import 'package:flutter/material.dart';
import 'package:money_manager/screen/about_screen.dart';
import 'screen/transaction_screen.dart'; // Pastikan path ini sesuai
import 'screen/other_screen.dart'; // Pastikan path ini sesuai
import 'screen/currency_converter_screen.dart'; // Mengimpor halaman kalkulator mata uang

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Menentukan rute awal ke TransactionScreen
      routes: {
        '/': (context) => TransactionScreen(),
        '/transaction': (context) => TransactionScreen(),
        '/other': (context) => OtherScreen(),
        '/home': (context) => TransactionScreen(),
        '/about': (context) => AboutScreen(),
        '/currency': (context) => CurrencyConverterScreen(), // Menambahkan rute kalkulator mata uang
      },
    );
  }
}
