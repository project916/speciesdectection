import 'package:flutter/material.dart';

class ViewTransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Transactions')),
      body: Center(
        child: Text('Here you can view transaction details'),
      ),
    );
  }
}
