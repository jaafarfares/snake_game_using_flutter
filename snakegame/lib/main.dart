import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int squaresPerRow = 20;
  final int squaresPerCol = 40;
  // final fontStyle = TextStyle(color: Colors.white, fontSize: 20);
  final randomGen = Random();

  var snake = [
    [0, 1],
    [0, 0]
  ];
  var food = [0, 2];
  var direction = 'up';
  var isPlaying = false;

/*   void startBgmMusic() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('assets/audio/Spazzmatica-Polka.mp3');
  } */
/*  String audioasset = "assets/audio/Spazzmatica-Polka.mp3";
 ByteData bytes = await rootBundle.load(audioasset); //load audio from assets
 Uint8List audiobytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes); */
  bool isPlayingg = false;
  double value = 0;
  final player = AudioPlayer();
  Duration? duration;

  void initPlayer() async {
    await player.setSource(AssetSource("/sound.mp3"));
    duration = await player.getDuration();
  }

  //init the player
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlayer();
  }

  void startGame() {
    const duration = Duration(milliseconds: 300);

    snake = [
      // Snake head
      [(squaresPerRow / 2).floor(), (squaresPerCol / 2).floor()]
    ];

    snake.add([snake.first[0], snake.first[1] + 1]); // Snake body

    createFood();

    isPlaying = true;
    Timer.periodic(duration, (Timer timer) {
      moveSnake();
      if (checkGameOver()) {
        timer.cancel();
        endGame();
      }
    });
  }

  void moveSnake() {
    setState(() {
      switch (direction) {
        case 'up':
          snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          break;

        case 'down':
          snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          break;

        case 'left':
          snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          break;

        case 'right':
          snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          break;
      }

      if (snake.first[0] != food[0] || snake.first[1] != food[1]) {
        snake.removeLast();
      } else {
        createFood();
      }
    });
  }

  void createFood() {
    food = [randomGen.nextInt(squaresPerRow), randomGen.nextInt(squaresPerCol)];
  }

  bool checkGameOver() {
    if (!isPlaying ||
        snake.first[1] < 0 ||
        snake.first[1] >= squaresPerCol ||
        snake.first[0] < 0 ||
        snake.first[0] > squaresPerRow) {
      return true;
    }

    for (var i = 1; i < snake.length; ++i) {
      if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1]) {
        return true;
      }
    }

    return false;
  }

  void endGame() {
    isPlaying = false;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.all(10.0),
            alignment: Alignment.center,
            title: const Text(
              'Game Over',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.red, fontSize: 22),
            ),
            content: Text(
              'Score: ${snake.length - 2}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[200],
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor:
                                isPlaying ? Colors.red : Colors.deepPurple),
                        child: Text(
                          isPlaying ? 'End' : 'Start',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            isPlaying = false;
                          } else {
                            startGame();
                            //player.setSource();
                            //player.play('assets/audio/Spazzmatica-Polka.mp3');
                          }
                        }),
                    Text(
                      'Score: ${snake.length - 2}',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
            SizedBox(height: 5),
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (direction != 'up' && details.delta.dy > 0) {
                    direction = 'down';
                  } else if (direction != 'down' && details.delta.dy < 0) {
                    direction = 'up';
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (direction != 'left' && details.delta.dx > 0) {
                    direction = 'right';
                  } else if (direction != 'right' && details.delta.dx < 0) {
                    direction = 'left';
                  }
                },
                child: AspectRatio(
                  aspectRatio: squaresPerRow / (squaresPerCol + 5),
                  child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: squaresPerRow,
                      ),
                      itemCount: squaresPerRow * squaresPerCol,
                      itemBuilder: (BuildContext context, int index) {
                        var color;
                        var x = index % squaresPerRow;
                        var y = (index / squaresPerRow).floor();

                        bool isSnakeBody = false;
                        for (var pos in snake) {
                          if (pos[0] == x && pos[1] == y) {
                            isSnakeBody = true;
                            break;
                          }
                        }

                        if (snake.first[0] == x && snake.first[1] == y) {
                          color = Colors.green;
                        } else if (isSnakeBody) {
                          color = Colors.green[200];
                        } else if (food[0] == x && food[1] == y) {
                          color = Colors.red;
                        } else {
                          color = Colors.grey[400];
                        }

                        return Container(
                          margin: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.rectangle,
                          ),
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
