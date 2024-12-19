import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  EditTransactionScreen({required this.transaction});

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController noteController;
  late TextEditingController totalController;
  late TextEditingController dateController;
  String? selectedAsset;

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController(text: widget.transaction['note']);
    totalController = TextEditingController(text: widget.transaction['total'].toString());
    dateController = TextEditingController(text: widget.transaction['date']);
    selectedAsset = widget.transaction['asset']; // Asset bisa 'Pendapatan' atau 'Pengeluaran'
  }

  // Fungsi untuk memperbarui transaksi
  Future<void> updateTransaction(Map<String, dynamic> updatedTransaction) async {
    final url = Uri.parse('https://675ae78c9ce247eb19350471.mockapi.io/transaction/${widget.transaction['id']}');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedTransaction),
      );

      if (response.statusCode == 200) {
        print('Transaction updated successfully');
      } else {
        print('Failed to update transaction, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating transaction: $e');
    }
  }

  // Fungsi untuk menghapus transaksi
  Future<void> deleteTransaction(BuildContext context) async {
    final url = Uri.parse('https://675ae78c9ce247eb19350471.mockapi.io/transaction/${widget.transaction['id']}');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Transaction deleted successfully');
        Navigator.pop(context, 'deleted');
      } else {
        print('Failed to delete transaction, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi penghapusan
  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Konfirmasi Penghapusan'),
        content: Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Menutup dialog jika dibatalkan
            },
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Menutup dialog
              deleteTransaction(context); // Memanggil fungsi penghapusan
            },
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: noteController,
              decoration: InputDecoration(labelText: 'Note'),
            ),
            TextField(
              controller: totalController,
              decoration: InputDecoration(labelText: 'Total'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Date'),
            ),
            SizedBox(height: 20),
            // Tombol untuk memilih jenis transaksi (Pendapatan/Pengeluaran)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedAsset = 'Pendapatan'; // Mengubah jenis transaksi menjadi Pendapatan
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedAsset == 'Pendapatan' ? Colors.green : Colors.grey,
                  ),
                  child: Text('Pendapatan'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedAsset = 'Pengeluaran'; // Mengubah jenis transaksi menjadi Pengeluaran
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedAsset == 'Pengeluaran' ? Colors.red : Colors.grey,
                  ),
                  child: Text('Pengeluaran'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol Simpan
                ElevatedButton(
                  onPressed: () {
                    final updatedTransaction = {
                      'note': noteController.text,
                      'total': double.tryParse(totalController.text) ?? 0.0,
                      'date': dateController.text,
                      'asset': selectedAsset ?? 'Pendapatan', // Menggunakan nilai asset yang dipilih
                    };

                    // Memperbarui transaksi di API
                    updateTransaction(updatedTransaction);

                    // Setelah berhasil update, kembali dengan data yang sudah diperbarui
                    Navigator.pop(context, updatedTransaction);
                  },
                  child: Text('Save'),
                ),
                // Tombol Hapus dengan konfirmasi
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Mengubah warna tombol menjadi merah
                  ),
                  onPressed: () {
                    showDeleteConfirmationDialog(context);
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
