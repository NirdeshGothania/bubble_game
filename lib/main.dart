import 'package:bubble_game/game_screen.dart';
import 'package:bubble_game/level.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BubbleGameApp());
}

class BubbleGameApp extends StatelessWidget {
  const BubbleGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const NewGame(),
    );
  }
}

class NewGame extends StatefulWidget {
  const NewGame({super.key});

  @override
  State<NewGame> createState() => _NewGameState();
}

class _NewGameState extends State<NewGame> {
  double bubbleSpeed = 0.01;
  int totalCount = 10;
  Duration spawnDelay = const Duration(seconds: 2);
  int level = 1;
  double nirdeshPosition = 0.3;
  double ridhimaPosition = 0.7;
  double nirmaPosition = 0.5;

  void gameWin() {
    level++;
    if (level > 3) {
      showWinDialog(context);
    } else {
      setState(() {
        totalCount += 5;
        bubbleSpeed += 0.05;
        spawnDelay -= const Duration(milliseconds: 200);
      });
    }
  }

  void gameLose() {
    showLoseDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bubble Game'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: Level(
              key: ValueKey(level),
              bubbleSpeed: bubbleSpeed,
              totalCount: totalCount,
              spawnDelay: spawnDelay,
              onGameWin: gameWin,
              onGameLose: gameLose,
            ),
          ),
          SizedBox(
            height: 300,
            width: 500,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  top: MediaQuery.of(context).size.height * 0.6,
                  left: level >= 4
                      ? MediaQuery.of(context).size.width * nirmaPosition - 35
                      : MediaQuery.of(context).size.width * nirdeshPosition -
                          35,
                  child: NamedBubble(
                    name: level >= 4 ? "Nirma" : "Nirdesh",
                    color: Colors.pink,
                  ),
                ),
                if (level < 4)
                  AnimatedPositioned(
                    duration: const Duration(seconds: 1),
                    top: MediaQuery.of(context).size.height * 0.6,
                    left: MediaQuery.of(context).size.width * ridhimaPosition -
                        35,
                    child: const NamedBubble(name: "Ridhima"),
                  ),
                if (level >= 4)
                  AnimatedPositioned(
                    duration: const Duration(seconds: 1),
                    top: MediaQuery.of(context).size.height * 0.6,
                    left:
                        MediaQuery.of(context).size.width * nirmaPosition - 35,
                    child: const NamedBubble(name: "Nirma"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showWinDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('You Win!'),
        content: const Text('You have completed all levels.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<void> showLoseDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('You Lose!'),
        content: const Text('You have lost all your bubbles.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
