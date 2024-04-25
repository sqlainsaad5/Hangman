import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(HangmanApp());
}

class HangmanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hangman Game App',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int wordLength = 5;
  int maxWords = 5;
  int maxTries = 5;

  void startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          wordLength: wordLength,
          maxWords: maxWords,
          maxTries: maxTries,
        ),
      ),
    );
  }

  Widget buildWordLengthButton(int length) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            wordLength = length;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: wordLength == length ? Colors.black87 : null,
        ),
        child: Text(length.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hangman Game - Home',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        leading: Icon(
          Icons.home,
          color: Colors.cyanAccent,
          size: 35,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/y.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Select Game Options:',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400, color: Colors.white),
                ),

                SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Maximum Word Length:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200, color: Colors.white),
                      ),

                      SizedBox(width: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildWordLengthButton(5),
                          buildWordLengthButton(6),
                          buildWordLengthButton(7),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        'Maximum Words : $maxWords',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200, color: Colors.white),
                      ),
                      Slider(
                        value: maxWords.toDouble(),
                        min: 1,
                        max: 10,
                        onChanged: (value) {
                          setState(() {
                            maxWords = value.toInt();
                          });
                        },
                        divisions: 9,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        'Maximum Tries: $maxTries',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200, color: Colors.white),
                      ),
                      Slider(
                        value: maxTries.toDouble(),
                        min: 1,
                        max: 10,
                        onChanged: (value) {
                          setState(() {
                            maxTries = value.toInt();
                          });
                        },
                        divisions: 9,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    elevation: 6,
                  ),
                  child: Text('Start Game', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final int wordLength;
  final int maxWords;
  final int maxTries;

  GameScreen({
    required this.wordLength,
    required this.maxWords,
    required this.maxTries,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> words = [];
  int currentWordIndex = 0;
  String currentWord = "";
  String missingWord = "";
  List<String> options = [];
  int triesLeft = 0;
  int score = 0;
  int seconds = 0;
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    triesLeft = widget.maxTries;
    generateWords();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void generateWords() {
    List<String> allWords = [
      'Apple', 'Banana', 'Cherry', 'Orange', 'Elephant', 'Parrot', 'Giraffe', 'Horse', 'Iguana', 'Jaguar',
      'Kangaroo', 'Jakkal', 'Monkey', 'Noodle', 'Ostrich', 'Penguin', 'Pigen', 'Rabbit', 'Snake', 'Tiger',
      'Unicorn', 'Vulture', 'Walrus', 'XyloApp', 'Faisal', 'Zebra', 'Intelligent', 'Comsats', 'Janisar',
      'Flutter', 'Worksup', 'UpsWork', 'Trading', 'OctaOx', 'GoodJob', 'Working', 'Shockin', 'Crows', 'Goats',
      'Cocks', 'Melon', 'Mango'
    ];
    words.clear();
    options.clear();

    for (String word in allWords) {
      if (word.length == widget.wordLength) {
        words.add(word);
      }
    }

    words.shuffle();
    currentWord = words[currentWordIndex];

    options.add(currentWord);
    while (options.length <= 4) {
      String randomWord = words[Random().nextInt(words.length)];
      if (!options.contains(randomWord)) {
        options.add(randomWord);
      }
    }
    options.shuffle();

    missingWord = generateMissingWord(currentWord);
  }

  String generateMissingWord(String word) {
    int missingIndex = Random().nextInt(word.length - 2) + 1;
    String missing = word.substring(0, missingIndex) + '_' + word.substring(missingIndex + 1);
    return missing;
  }

  void checkAnswer(String selectedWord) {
    setState(() {
      if (selectedWord == currentWord) {
        score++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your answer is correct! ✅',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                ),
                Text(
                  'The correct word is: $currentWord',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        );
      } else {
        triesLeft--;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wrong answer! ❌',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                ),
                Text(
                  'The correct word is: $currentWord',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        );
      }

      if (triesLeft == 0 || currentWordIndex == widget.maxWords - 1) {
        timer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: score,
              maxWords: widget.maxWords,
              totalTime: seconds,
            ),
          ),
        );
      } else {
        currentWordIndex++;
        generateWords();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String timerText = '${(seconds / 60).floor().toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hangman Game - Quiz',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        leading: Icon(
          Icons.question_answer,
          color: Colors.amberAccent,
          size: 35,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/y.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Question ${currentWordIndex + 1} out of ${widget.maxWords}',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),

                SizedBox(height: 40),
                Text(
                  'Guess Missing Word: $missingWord',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                SizedBox(height: 20),
                Text(
                  'Options:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 10),
                Column(
                  children: options
                      .map((option) => ElevatedButton(
                    onPressed: () => checkAnswer(option),
                    child: Text(option),
                  ))
                      .toList(),
                ),
                SizedBox(height: 40),
                Text(
                  'Tries Left: $triesLeft',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
                SizedBox(height: 40),
                Text(
                  'Time: $timerText',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final int maxWords;
  final int totalTime;

  ResultScreen({
    required this.score,
    required this.maxWords,
    required this.totalTime,
  });

  String getEmoji() {
    if (score == maxWords) {
      return '🎉'; // Celebration emoji for a perfect score
    } else if (score >= maxWords * 0.75) {
      return '👍'; // Thumbs-up emoji for a high score
    } else {
      return '😕'; // Sad emoji for a low score
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hangman Game - Result',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        leading: Icon(
          Icons.assessment,
          color: Colors.blueAccent,
          size: 35,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/y.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(70.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Game Over!',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                SizedBox(height: 20),
                Text(
                  'Score: $score / $maxWords',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),

                SizedBox(height: 20),
                Text(
                  'Total Time: ${(totalTime / 60).floor().toString().padLeft(2, '0')}:${(totalTime % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 40),
                Text(
                  getEmoji(),
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ),
                    );
                  },
                  child: Text('Play Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}