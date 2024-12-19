import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Gambar pertama
            Image.asset('images/hanan.jpg'), // Pastikan gambar ada di folder assets
            SizedBox(height: 32),

            // Gambar kedua
            Image.asset('images/sam.png'), // Pastikan gambar ada di folder assets
            SizedBox(height: 32),

            // Gambar ketiga
            Image.asset('images/marsa.jpg'), // Pastikan gambar ada di folder assets
            SizedBox(height: 32),

            // Deskripsi tentang aplikasi
            Text(
              'Aplikasi Money Manager adalah alat pengelolaan keuangan yang membantu pengguna mengatur dan melacak pendapatan serta pengeluaran mereka. Aplikasi ini menyediakan fitur untuk mencatat transaksi, mengelompokkan transaksi berdasarkan kategori, serta menampilkan ringkasan keuangan.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Deskripsi tim pengembang
            Text(
              'Tim Pengembang:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '- Samuel Kevin (17220189): Samuel bertanggung jawab atas pengembangan backend aplikasi, termasuk pengelolaan basis data dan integrasi API.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '- Marsanda Lestari (17220163): Marsanda memimpin desain antarmuka pengguna (UI) dan pengalaman pengguna (UX), memastikan aplikasi ini mudah digunakan dan menarik secara visual.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '- Hanan Putri (17220624): Hanan mengelola pengujian aplikasi dan kontrol kualitas, memastikan semua fitur berfungsi dengan baik dan aplikasi bebas dari bug.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AboutScreen(),
  ));
}
