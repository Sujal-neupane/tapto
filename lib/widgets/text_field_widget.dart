import 'package:flutter/material.dart';

class TaptoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscure;
  final TextInputType type;
  final String? Function(String?)? validator;

  const TaptoTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefix,
    this.suffix,
    this.validator,
    this.obscure = false,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
      ),
    );
  }
}
