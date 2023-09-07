import 'package:flutter/material.dart';

Widget myTextField({
  required String label,
  String? hint,
  required TextEditingController mycontroller,
  IconData? prefixIcon,
  String? invalidText,
  bool obscure = false,
}) {
  return TextFormField(
    validator: (value) {
      if (value!.isEmpty) {
        return invalidText;
      } else {
        return null;
      }
    },
    controller: mycontroller,
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.all(20),
      label: Text(label),
      hintText: hint,
      prefixIcon: (prefixIcon != null) ? Icon(prefixIcon) : null,
      isDense: true,
    ),
    obscureText: obscure,
  );
}
