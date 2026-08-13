import 'package:flutter/material.dart';

class SimpleRedBox extends StatelessWidget {
  const SimpleRedBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 30,
      color: Colors.red,
      child: const Center(
        child: Text(
          'TEST',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
