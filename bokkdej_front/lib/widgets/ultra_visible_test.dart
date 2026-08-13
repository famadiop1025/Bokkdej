import 'package:flutter/material.dart';

class UltraVisibleTest extends StatelessWidget {
  const UltraVisibleTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.red,
        border: Border.all(color: Colors.yellow, width: 5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'WAVE TEST ULTRA VISIBLE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
