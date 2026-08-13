import 'package:flutter/material.dart';

class TestButtonReplacement extends StatelessWidget {
  const TestButtonReplacement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red,
        border: Border.all(color: Colors.yellow, width: 5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          'BOUTON WAVE TEST - ULTRA VISIBLE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
