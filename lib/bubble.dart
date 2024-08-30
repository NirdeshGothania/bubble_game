import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  const Bubble({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: Icon(Icons.favorite_rounded, size: 40),
    );
  }
}
