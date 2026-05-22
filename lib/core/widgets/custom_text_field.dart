import 'package:flutter/material.dart';

// Reusable text input field used in forms
class CustomTextField extends StatelessWidget {
  final String hint;
  const CustomTextField({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(decoration: InputDecoration(hintText: hint));
  }
}