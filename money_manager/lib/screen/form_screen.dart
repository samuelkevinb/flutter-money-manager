import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart'; // Untuk Toast Message
import 'package:money_manager/screen/transaction_screen.dart';

class FormScreen extends StatefulWidget {
  final Function onSubmit; // Callback untuk pengiriman data

  // Menambahkan constructor dengan parameter onSubmit
  FormScreen({required this.onSubmit});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  String _selectedAsset = 'Pendapatan'; // Aset default
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TextEditingController _totalController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ) ?? _selectedDate;

    if (picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  // Fungsi untuk memilih waktu
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    ) ?? _selectedTime;

    if (picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
      });
  }

  // Fungsi untuk menyimpan data ke MockAPI
  Future<void> _saveTransaction() async {
    String total = _totalController.text;
    String note = _noteController.text;

    // Validasi total
    if (total.isEmpty || double.tryParse(total) == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Masukkan jumlah yang valid!'),
      ));
      return;
    }

    // Validasi catatan
    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Masukkan catatan transaksi!'),
      ));
      return;
    }

    // Gabungkan tanggal dan waktu
    DateTime fullDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final response = await http.post(
      Uri.parse('https://675ae78c9ce247eb19350471.mockapi.io/transaction'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'asset': _selectedAsset,
        'date': fullDateTime.toIso8601String(), // Kirimkan waktu lengkap
        'time': _selectedTime.format(context),
        'total': total,
        'note': note,
      }),
    );

    if (response.statusCode == 201) {
      _totalController.clear();
      _noteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaksi berhasil disimpan!'),
      ));

      // Panggil callback onSubmit setelah transaksi berhasil disimpan
      widget.onSubmit({
        'asset': _selectedAsset,
        'date': fullDateTime.toIso8601String(), // Kirimkan waktu lengkap
        'time': _selectedTime.format(context),
        'total': total,
        'note': note,
      });

      // Navigasi ke halaman transaksi menggunakan Navigator.pushReplacementNamed
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal menyimpan transaksi. Coba lagi!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengubah warna total berdasarkan aset yang dipilih
    Color totalColor = _selectedAsset == 'Pendapatan' ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text('Form Transaksi'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tanggal dan Jam
              Row(
                children: [
                  Text(
                    "Tanggal: ${_selectedDate.toLocal()}".split(' ')[0],
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                  SizedBox(width: 16),
                  Text(
                    "Jam: ${_selectedTime.format(context)}",
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Tombol untuk memilih Aset (Pendapatan/Pengeluaran)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedAsset = 'Pendapatan';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedAsset == 'Pendapatan'
                          ? Colors.green
                          : Colors.grey,
                    ),
                    child: Text('Pendapatan'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedAsset = 'Pengeluaran';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedAsset == 'Pengeluaran'
                          ? Colors.red
                          : Colors.grey,
                    ),
                    child: Text('Pengeluaran'),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // TextField untuk Total yang hanya menampilkan angka
              TextField(
                controller: _totalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Total',
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan jumlah',
                  hintStyle: TextStyle(color: totalColor),
                ),
                style: TextStyle(color: totalColor),
              ),
              SizedBox(height: 16),

              // TextField untuk Catatan
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Catatan',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 32),

              // Tombol untuk Simpan atau Aksi lainnya
              ElevatedButton(
                onPressed: _saveTransaction, // Panggil fungsi simpan data
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
