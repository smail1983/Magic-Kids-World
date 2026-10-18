import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AlphabetSoundsGame extends StatefulWidget {
  const AlphabetSoundsGame({super.key});
  @override
  State<AlphabetSoundsGame> createState() => _AlphabetSoundsGameState();
}

class _AlphabetSoundsGameState extends State<AlphabetSoundsGame> {
  final FlutterTts tts = FlutterTts();
  final Random random = Random();
  final letters = const [
    ('A', 'Apple', '🍎', 'ah'), ('B', 'Ball', '⚽', 'buh'),
    ('C', 'Cat', '🐱', 'kuh'), ('D', 'Dog', '🐶', 'duh'),
    ('E', 'Elephant', '🐘', 'eh'), ('F', 'Fish', '🐟', 'fuh'),
    ('G', 'Grapes', '🍇', 'guh'), ('H', 'Hat', '🎩', 'huh'),
    ('I', 'Ice cream', '🍦', 'ih'), ('J', 'Juice', '🧃', 'juh'),
    ('K', 'Kite', '🪁', 'kuh'), ('L', 'Lion', '🦁', 'luh'),
    ('M', 'Moon', '🌙', 'muh'), ('N', 'Nose', '👃', 'nuh'),
    ('O', 'Orange', '🍊', 'oh'), ('P', 'Panda', '🐼', 'puh'),
    ('Q', 'Queen', '👑', 'kwuh'), ('R', 'Rabbit', '🐰', 'ruh'),
    ('S', 'Sun', '☀️', 'suh'), ('T', 'Tiger', '🐯', 'tuh'),
    ('U', 'Umbrella', '☂️', 'uh'), ('V', 'Van', '🚐', 'vuh'),
    ('W', 'Whale', '🐳', 'wuh'), ('X', 'X-ray', '🩻', 'ks'),
    ('Y', 'Yo-yo', '🪀', 'yuh'), ('Z', 'Zebra', '🦓', 'zuh'),
  ];

  late int current;
  int round = 1;
  int score = 0;
  List<int> options = [];

  @override
  void initState() {
    super.initState();
    tts.setLanguage('en-US');
    tts.setSpeechRate(0.42);
    tts.setPitch(1.12);
    _nextRound();
  }

  void _nextRound() {
    current = random.nextInt(letters.length);
    final set = <int>{current};
    while (set.length < 4) set.add(random.nextInt(letters.length));
    options = set.toList()..shuffle();
  }

  Future<void> _speak() async {
    final item = letters[current];
    await tts.stop();
    await tts.speak('Letter ${item.$1}. ${item.$1} says ${item.$4}. ${item.$2}.');
  }

  void _pick(int index) {
    if (index != current) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Almost! Listen and try again. 🔊')));
      return;
    }
    score++;
    if (round == 5) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      round++;
      _nextRound();
    });
    _speak();
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = letters[current];
    return Scaffold(
      appBar: AppBar(title: const Text('ABC Sounds 🔤'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(children: [
            const Text('Learn the letter, hear the sound, then choose it!', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(colors: [Color(0xFF7657E8), Color(0xFF32C7F5)]),
                boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x22000000))],
              ),
              child: Column(children: [
                Text(item.$3, style: const TextStyle(fontSize: 48)),
                Text(item.$1, style: const TextStyle(fontSize: 92, height: .95, color: Colors.white, fontWeight: FontWeight.w900)),
                Text(item.$2, style: const TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                FilledButton.icon(onPressed: _speak, icon: const Icon(Icons.volume_up_rounded), label: const Text('HEAR PRONUNCIATION')),
              ]),
            ),
            const SizedBox(height: 20),
            Text('Which one is ${item.$1}?', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: options.map((i) => FilledButton(
                onPressed: () => _pick(i),
                style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                child: Text(letters[i].$1, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Text('Round $round of 5  •  Score $score', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          ]),
        ),
      ),
    );
  }
}
