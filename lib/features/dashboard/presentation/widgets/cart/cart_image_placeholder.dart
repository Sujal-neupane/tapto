import 'package:flutter/material.dart';

class CartImagePlaceholder extends StatelessWidget {
  const CartImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 32,
        color: Colors.grey[350],
      ),
    );
  }
}