import 'package:flutter/material.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lainnya'), // Top bar dengan judul "Lainnya"
        centerTitle: true,
        backgroundColor: Colors.purple, // Warna AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding untuk konten
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Opsi Menu: About, Mata Uang
            ListTile(
              leading: Icon(Icons.info), // Ganti dengan ikon "About"
              title: Text('About'),
              onTap: () {
                Navigator.pushNamed(context, '/about'); // Navigasi ke halaman About
              },
            ),
            Divider(),

            ListTile(
              leading: Icon(Icons.monetization_on), // Ikon Mata Uang
              title: Text('Mata Uang'),
              onTap: () {
                 // Navigasi ke CurrencyConverterScreen
                Navigator.pushNamed(context, '/currency');
              },
            ),
            Divider(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Others',
          ),
        ],
        currentIndex: 1, // Menandakan bahwa halaman "Lainnya" aktif
        onTap: (index) {
          if (index == 0) {
            // Navigasi ke halaman Transaksi jika index == 0
            Navigator.pushReplacementNamed(context, '/transaction');
          }
        },
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.black,
      ),
    );
  }
}
