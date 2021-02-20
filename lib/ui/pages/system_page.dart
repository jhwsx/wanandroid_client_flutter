import 'package:flutter/material.dart';

class SystemPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyan,
      alignment: Alignment.center,
      child: Text(
        '体系',
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }
}