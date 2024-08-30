import 'package:flutter/material.dart';
import 'package:bubble_game/game_screen.dart';

void main() {
  runApp(BubbleGameApp());
}

class BubbleGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: GameScreen(),
    );
  }
}
