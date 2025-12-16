import 'package:flutter/material.dart';

class TaptoButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const TaptoButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
