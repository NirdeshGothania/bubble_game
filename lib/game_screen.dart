import 'dart:async';
import 'dart:math';

import 'package:bubble_game/level.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int currentStage = 1;
  int bubblesDestroyed = 0;
  int bubblesMissed = 0;
  double nirdeshPosition = 0.3;
  double ridhimaPosition = 0.7;
  double nirmaPosition = 0.5;

  List<Widget> bubbles = [];
  Timer? spawnTimer;
  Timer? moveTimer;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    bubblesDestroyed = 0;
    bubblesMissed = 0;
    bubbles.clear();
    startSpawningBubbles();
  }

  void startSpawningBubbles() {
    int spawnInterval = 3000;

    spawnTimer = Timer.periodic(Duration(milliseconds: spawnInterval), (timer) {
      if (bubbles.length >= currentStage * 5) {
        stopGame();
        return;
      }
      addBubble();
    });

    moveTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      moveBubbles();
    });
  }

  void addBubble() {
    setState(() {
      bubbles.add(Positioned(
        top: 0,
        left: random.nextDouble() * MediaQuery.of(context).size.width * 0.8,
        child: GestureDetector(
          onTap: () {
            setState(() {
              bubblesDestroyed++;
              bubbles.removeAt(0);
              if (bubblesDestroyed >= currentStage * 10) {
                advanceStage();
              }
            });
          },
          child: const Icon(Icons.favorite),
        ),
      ));
    });
  }

  void moveBubbles() {
    setState(() {
      for (int i = bubbles.length - 1; i >= 0; i--) {
        Positioned bubble = bubbles[i] as Positioned;
        double newTop = bubble.top! + (currentStage / 2);
        if (newTop >= MediaQuery.of(context).size.height * 0.5) {
          bubblesMissed++;
          bubbles.removeAt(i);
          if (bubblesMissed >= currentStage * 5) {
            resetGame();
            return;
          }
        } else {
          bubbles[i] = Positioned(
            top: newTop,
            left: bubble.left,
            child: bubble.child,
          );
        }
      }
    });
  }

  void advanceStage() {
    if (currentStage < 5) {
      setState(() {
        currentStage++;
        nirdeshPosition += 0.05;
        ridhimaPosition -= 0.05;
      });
      showMessage();
      startGame();
    } else {
      endGame();
    }
  }

  void stopGame({bool failed = false}) {
    spawnTimer?.cancel();
    moveTimer?.cancel();
    if (failed) {
      setState(() {
        nirdeshPosition -= 0.05;
        ridhimaPosition += 0.05;
      });
    }
  }

  void resetGame() {
    stopGame(failed: true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Too many bubbles missed! Restarting from Stage 1."),
      duration: Duration(seconds: 4),
    ));
    setState(() {
      currentStage = 1;
      nirdeshPosition = 0.3;
      ridhimaPosition = 0.7;
    });
    startGame();
  }

  void endGame() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: const Column(
            children: [
              Text("Lifetime together!"),
              Text('Happy Birthday meri Jaan❤️',
                  style: TextStyle(
                      color: Colors.pink,
                      fontSize: 18,
                      fontStyle: FontStyle.italic)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentStage = 1;
                  nirdeshPosition = 0.25;
                  ridhimaPosition = 0.80;
                  startGame();
                });
              },
              child:
                  const Text("Restart", style: TextStyle(color: Colors.pink)),
            ),
          ],
        );
      },
    );
  }

  void showMessage() {
    String message = "";
    switch (currentStage) {
      case 2:
        message = "Our trust grows stronger.";
        break;
      case 3:
        message = "Our loyalty deepens.";
        break;
      case 4:
        message = "Communication is key!";
        break;
      case 5:
        message = "Forever together.";
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: const TextStyle(
              color: Colors.white, fontStyle: FontStyle.italic)),
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.pink,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bubble Game',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade100, Colors.purple.shade100],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Text(
              'Stage: $currentStage | Bubbles Destroyed: $bubblesDestroyed/${currentStage * 10}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 2.0, color: Colors.white),
              ),
            ),
            child: Level(
              bubbleSpeed: 1,
              onGameLose: () {
                resetGame();
              },
              onGameWin: () {
                endGame();
              },
              spawnDelay: const Duration(seconds: 1),
              totalCount: 10,
            ),
          ),
          Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(seconds: 1),
                top: MediaQuery.of(context).size.height * 0.6,
                left: currentStage >= 4
                    ? MediaQuery.of(context).size.width * nirmaPosition - 35
                    : MediaQuery.of(context).size.width * nirdeshPosition - 35,
                child: NamedBubble(
                  name: currentStage >= 4 ? "Nirma" : "Nirdesh",
                  color: Colors.pink,
                ),
              ),
              if (currentStage < 4)
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  top: MediaQuery.of(context).size.height * 0.6,
                  left:
                      MediaQuery.of(context).size.width * ridhimaPosition - 35,
                  child: const NamedBubble(name: "Ridhima"),
                ),
              if (currentStage >= 4)
                AnimatedPositioned(
                  duration: const Duration(seconds: 1),
                  top: MediaQuery.of(context).size.height * 0.6,
                  left: MediaQuery.of(context).size.width * nirmaPosition - 35,
                  child: const NamedBubble(name: "Nirma"),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    spawnTimer?.cancel();
    moveTimer?.cancel();
    super.dispose();
  }
}

// class HeartBubble extends StatelessWidget {
//   const HeartBubble({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.pink.withOpacity(0.5),
//       ),
//     );
//   }
// }

class NamedBubble extends StatelessWidget {
  final String name;
  final Color color;

  const NamedBubble({
    super.key,
    required this.name,
    this.color = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: const Center(child: Icon(Icons.favorite)),
        ),
        Text(
          name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}
