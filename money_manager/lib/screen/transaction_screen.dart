import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'form_screen.dart';
import 'edit_transaction_screen.dart';
import 'other_screen.dart'; // Impor OtherScreen

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  DateTime _currentDate = DateTime.now();
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  List<dynamic> transactions = [];
  bool isLoading = true;
  bool hasError = false;

  double income = 0.0;
  double expense = 0.0;
  double balance = 0.0;

  int _currentIndex = 0;

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTransactions(_startDate, _endDate);
  }

  Future<void> _fetchTransactions(DateTime startDate, DateTime endDate) async {
    final url = 'https://675ae78c9ce247eb19350471.mockapi.io/transaction';
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      // Mengambil data dari API
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> fetchedTransactions = json.decode(response.body);

        // Menyaring transaksi berdasarkan tanggal yang sesuai
        setState(() {
          transactions = fetchedTransactions.where((transaction) {
            if (transaction['date'] != null) {
              try {
                DateTime transactionDate = DateTime.parse(transaction['date']);
                return transactionDate.isAfter(startDate) && transactionDate.isBefore(endDate);
              } catch (e) {
                return false;
              }
            }
            return false;
          }).toList();

          _applySearchQuery();
          _calculateSummary();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print('Error: $error');
    }
  }

  void _applySearchQuery() {
    if (_searchQuery.isNotEmpty) {
      setState(() {
        transactions = transactions.where((transaction) {
          String note = transaction['note']?.toLowerCase() ?? '';
          return note.contains(_searchQuery.toLowerCase());
        }).toList();
      });
    }
  }

  void _calculateSummary() {
    double tempIncome = 0.0;
    double tempExpense = 0.0;

    for (var transaction in transactions) {
      double total = _parseToDouble(transaction['total']);
      String asset = transaction['asset'] ?? '';

      if (asset.toLowerCase() == 'pendapatan' && total >= 0) {
        tempIncome += total;
      } else if (asset.toLowerCase() == 'pengeluaran' && total > 0) {
        tempExpense += total.abs();
      }
    }

    setState(() {
      income = tempIncome;
      expense = tempExpense;
      balance = tempIncome - tempExpense;
    });
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is String) {
      final parsedValue = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
      return parsedValue ?? 0.0;
    }
    return value is double ? value : 0.0;
  }

  void _changeMonth(int step) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + step);
      _startDate = DateTime(_currentDate.year, _currentDate.month, 1);
      _endDate = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    });
    _fetchTransactions(_startDate, _endDate);
  }

  void _addTransaction(Map<String, dynamic> newTransaction) {
    setState(() {
      transactions.add(newTransaction);
      _calculateSummary();
    });
    Navigator.pop(context);
  }

  // Fungsi untuk memilih tanggal
  void _selectDateRange() async {
    DateTime selectedStartDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ) ?? _startDate;

    DateTime selectedEndDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: selectedStartDate,
      lastDate: DateTime.now(),
    ) ?? _endDate;

    if (selectedStartDate != _startDate || selectedEndDate != _endDate) {
      setState(() {
        _startDate = selectedStartDate;
        _endDate = selectedEndDate;
      });
      _fetchTransactions(_startDate, _endDate); // Fetch transactions within the selected date range
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedMonth = DateFormat('MMM yyyy').format(_currentDate);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 16),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  formattedMonth,
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: TransactionSearchDelegate(
                        transactions: transactions,
                        onSearch: (query) {
                          setState(() {
                            _searchQuery = query;
                            _applySearchQuery();
                          });
                        },
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: _selectDateRange, // Menambahkan fungsi pemilihan tanggal
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          _buildSummaryRow(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : hasError
                    ? Center(child: ElevatedButton(
                        onPressed: () => _fetchTransactions(_startDate, _endDate),
                        child: Text('Retry'),
                      ))
                    : _buildTransactionList(),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSummaryRow() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _summaryColumn('Pendapatan', income, Colors.green),
          _summaryColumn('Pengeluaran', expense, Colors.red),
          _summaryColumn('Saldo', balance, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return transactions.isEmpty
        ? Center(child: Text('Minimum date distance is two days'))
        : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              var transaction = transactions[index];
              DateTime transactionDate = DateTime.parse(transaction['date']).toLocal();
              String formattedDate = DateFormat('dd MMM yyyy').format(transactionDate);
              String formattedTime = DateFormat('HH:mm').format(transactionDate.toLocal());
              String asset = transaction['asset'] ?? '';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTransactionScreen(transaction: transaction),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        transactions[index] = result;
                        _calculateSummary();
                      });
                    }
                  },
                  child: ListTile(
                    title: Text(
                      transaction['note'] ?? 'No notes available',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rp${_parseToDouble(transaction['total']).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: asset.toLowerCase() == 'pendapatan'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Text(formattedDate),
                        Text(formattedTime),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _summaryColumn(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title),
        SizedBox(height: 4),
        Text(
          'Rp${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () async {
        final newTransaction = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormScreen(onSubmit: _addTransaction),
          ),
        );

        if (newTransaction != null) {
          _fetchTransactions(_startDate, _endDate);
        }
      },
      child: Icon(Icons.add),
      backgroundColor: Colors.purple,
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });

        if (index == 0) {
          // Sudah di layar TransactionScreen
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtherScreen(),
            ),
          );
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'Other',
        ),
      ],
    );
  }
}

class TransactionSearchDelegate extends SearchDelegate {
  final List<dynamic> transactions;
  final Function(String) onSearch;

  TransactionSearchDelegate({required this.transactions, required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredTransactions = transactions.where((transaction) {
      String note = transaction['note']?.toLowerCase() ?? '';
      return note.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        var transaction = filteredTransactions[index];
        DateTime transactionDate = DateTime.parse(transaction['date']).toLocal();
        String formattedDate = DateFormat('dd MMM yyyy').format(transactionDate);
        String formattedTime = DateFormat('HH:mm').format(transactionDate.toLocal());
        String asset = transaction['asset'] ?? '';

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTransactionScreen(transaction: transaction),
                ),
              );

              if (result != null) {
                onSearch(query); // Refresh the search results
              }
            },
            child: ListTile(
              title: Text(
                transaction['note'] ?? 'No notes available',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rp${_parseToDouble(transaction['total']).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: asset.toLowerCase() == 'pendapatan' ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(formattedDate),
                  Text(formattedTime),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredTransactions = transactions.where((transaction) {
      String note = transaction['note']?.toLowerCase() ?? '';
      return note.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        var transaction = filteredTransactions[index];
        DateTime transactionDate = DateTime.parse(transaction['date']).toLocal();
        String formattedDate = DateFormat('dd MMM yyyy').format(transactionDate);
        String formattedTime = DateFormat('HH:mm').format(transactionDate.toLocal());
        String asset = transaction['asset'] ?? '';

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTransactionScreen(transaction: transaction),
                ),
              );

              if (result != null) {
                onSearch(query); // Refresh the search results
              }
            },
            child: ListTile(
              title: Text(
                transaction['note'] ?? 'No notes available',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rp${_parseToDouble(transaction['total']).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: asset.toLowerCase() == 'pendapatan' ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(formattedDate),
                  Text(formattedTime),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is String) {
      final parsedValue = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
      return parsedValue ?? 0.0;
    }
    return value is double ? value : 0.0;
  }
}
