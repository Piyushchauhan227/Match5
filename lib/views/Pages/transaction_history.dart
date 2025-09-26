import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/const.dart';
import 'package:provider/provider.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List<dynamic> transactions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    try {
      final res = await http.get(
        Uri.parse("$BASE_URL/transaction/getTransactions?userId=${user!.id}"),
      );
      var resData = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          transactions = resData["transaction"];

          loading = false;
        });
      } else {
        setState(() => loading = false);
        print("❌ Failed to fetch transactions: ${res.body}");
      }
    } catch (e) {
      setState(() => loading = false);
      print("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(
                  child: Text(
                    "No transactions yet",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final date = DateTime.parse(tx["createdAt"]);
                    final localDate = date.toLocal();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: Image.asset(
                          "assets/fire.png",
                          width: 32,
                          height: 32,
                        ),
                        title: Text(
                          "${tx["amount"]} Fires",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          "${localDate.day}/${localDate.month}/${localDate.year} at ${localDate.hour}:${localDate.minute.toString().padLeft(2, '0')}",
                        ),
                        trailing: Text(
                          "${tx["status"]}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
