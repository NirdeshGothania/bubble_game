import 'dart:math';

import 'package:bubble_game/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Level extends StatefulWidget {
  final double bubbleSpeed;
  final int totalCount;
  final Duration spawnDelay;
  final void Function() onGameWin;
  final void Function() onGameLose;

  const Level({
    super.key,
    required this.bubbleSpeed,
    required this.totalCount,
    required this.spawnDelay,
    required this.onGameWin,
    required this.onGameLose,
  });

  @override
  State<Level> createState() => _LevelState();
}

class BubbleProps {
  Offset position;
  double speed;

  BubbleProps(this.position, this.speed);
}

class _LevelState extends State<Level> with TickerProviderStateMixin {
  int bubblesDestroyed = 0;
  Set<BubbleProps> bubblePositions = {};

  Random random = Random();
  bool disposed = false;

  late final Ticker ticker;

  int bubblesLost = 0;

  @override
  void initState() {
    ticker = createTicker(moveBubbles);
    super.initState();
  }

  @override
  void dispose() {
    endGame();
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!ticker.isActive)
          Positioned(
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.green,
                ),
                iconSize: 50,
                onPressed: () {
                  ticker.start();
                  spawn();
                },
              ),
            ),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bubbles Lost: $bubblesLost',
                style: const TextStyle(fontSize: 15),
              ),
              Text(
                'Bubbles Destroyed: $bubblesDestroyed / ${widget.totalCount}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        for (final bubblePosition in bubblePositions)
          Positioned(
            top: bubblePosition.position.dy,
            left: bubblePosition.position.dx,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  bubblePositions.remove(bubblePosition);
                  destroyBubble();
                });
              },
              child: const Bubble(),
            ),
          ),
      ],
    );
  }

  Future<void> spawn() async {
    await Future.delayed(widget.spawnDelay);
    if (!disposed) {
      bubblePositions.add(
        BubbleProps(
          Offset(
            30 +
                random.nextDouble() *
                    (MediaQuery.of(context).size.width - 30 * 2),
            0,
          ),
          widget.bubbleSpeed + random.nextDouble() * widget.bubbleSpeed,
        ),
      );
      spawn();
    }
  }

  void moveBubbles(Duration elapsed) {
    if (disposed) return;
    final int millisecondsElapsed = elapsed.inMilliseconds;
    setState(() {
      bubblePositions = bubblePositions
          .map((bubble) => BubbleProps(
              Offset(
                bubble.position.dx,
                bubble.position.dy + bubble.speed * millisecondsElapsed / 1000,
              ),
              bubble.speed))
          .toSet();
      bubblePositions.removeWhere((bubble) {
        bool hasReachedEnd =
            bubble.position.dy > MediaQuery.of(context).size.height;
        if (hasReachedEnd) bubblesLost++;
        return hasReachedEnd;
      });
      if (bubblesLost >= widget.totalCount / 2) {
        endGame();
        widget.onGameLose();
      }
    });
  }

  void destroyBubble() {
    bubblesDestroyed++;
    if (bubblesDestroyed >= widget.totalCount) {
      endGame();
      widget.onGameWin();
    }
  }

  void endGame() {
    disposed = true;
    ticker.stop();
    bubblePositions.clear();
  }
}
