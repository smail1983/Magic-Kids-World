import 'dart:math';
import 'package:flutter/material.dart';

class GamesPage extends StatelessWidget {
  final Future<void> Function() onComplete;
  const GamesPage({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final games = [
      ('🌈', 'Color Match', 'Find the matching color', const ColorMatchGame()),
      ('🔢', 'Count & Find', 'Count the stars', const CountFindGame()),
      ('🧠', 'Memory Pairs', 'Match the cards', const MemoryPairsGame()),
      ('🔷', 'Shape Spotter', 'Find the right shape', const ShapeSpotterGame()),
      ('🎈', 'Balloon Pop', 'Pop the target balloons', const BalloonPopGame()),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Mini Games 🎮', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('Choose an adventure and earn stars!', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 18),
        ...games.map((g) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: CircleAvatar(radius: 28, child: Text(g.$1, style: const TextStyle(fontSize: 27))),
            title: Text(g.$2, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text(g.$3),
            trailing: FilledButton(onPressed: () => _open(context, g.$4), child: const Text('PLAY')),
          ),
        )),
      ],
    );
  }

  void _open(BuildContext context, Widget game) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => game)).then((value) {
      if (value == true) onComplete();
    });
  }
}

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});
  @override State<ColorMatchGame> createState() => _ColorMatchState();
}
class _ColorMatchState extends State<ColorMatchGame> {
  final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.pink];
  final random = Random();
  late Color target, a, b;
  int round = 1;
  @override void initState() { super.initState(); _next(); }
  void _next() {
    target = colors[random.nextInt(colors.length)]; a = target;
    do { b = colors[random.nextInt(colors.length)]; } while (b == target);
    if (random.nextBool()) { final t = a; a = b; b = t; }
  }
  void _pick(Color color) {
    if (color != target) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Try again! 🌟'))); return; }
    if (round == 3) { Navigator.pop(context, true); return; }
    setState(() { round++; _next(); });
  }
  @override Widget build(BuildContext context) => GameScaffold(
    title: 'Color Match 🌈', instruction: 'Find the color that matches the circle.',
    child: Column(children: [
      const SizedBox(height: 20),
      Container(width: 150, height: 150, decoration: BoxDecoration(color: target, shape: BoxShape.circle)),
      const SizedBox(height: 28),
      Row(children: [Expanded(child: ColorChoice(color: a, onTap: () => _pick(a))), const SizedBox(width: 16), Expanded(child: ColorChoice(color: b, onTap: () => _pick(b)))]),
      const SizedBox(height: 24), Text('Round $round of 3', style: const TextStyle(fontWeight: FontWeight.bold)),
    ]),
  );
}

class CountFindGame extends StatefulWidget {
  const CountFindGame({super.key});
  @override State<CountFindGame> createState() => _CountFindState();
}
class _CountFindState extends State<CountFindGame> {
  final random = Random();
  late int answer; late List<int> options; int round = 1;
  @override void initState() { super.initState(); _next(); }
  void _next() {
    answer = random.nextInt(8) + 2;
    options = {answer, answer + 1, answer - 1, random.nextInt(9) + 2}.where((n) => n > 0).toSet().toList()..shuffle();
    while (options.length < 4) { final n = random.nextInt(10) + 1; if (!options.contains(n)) options.add(n); }
  }
  void _pick(int n) {
    if (n != answer) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Count again! 🔢'))); return; }
    if (round == 3) { Navigator.pop(context, true); return; }
    setState(() { round++; _next(); });
  }
  @override Widget build(BuildContext context) => GameScaffold(
    title: 'Count & Find 🔢', instruction: 'How many stars can you count?',
    child: Column(children: [
      const SizedBox(height: 18),
      Wrap(alignment: WrapAlignment.center, spacing: 7, runSpacing: 7, children: List.generate(answer, (_) => const Text('⭐', style: TextStyle(fontSize: 34)))),
      const SizedBox(height: 28),
      Wrap(spacing: 12, runSpacing: 12, children: options.map((n) => SizedBox(width: 130, child: FilledButton(onPressed: () => _pick(n), child: Text('$n', style: const TextStyle(fontSize: 22))))).toList()),
      const SizedBox(height: 22), Text('Round $round of 3', style: const TextStyle(fontWeight: FontWeight.bold)),
    ]),
  );
}

class MemoryPairsGame extends StatefulWidget {
  const MemoryPairsGame({super.key});
  @override State<MemoryPairsGame> createState() => _MemoryPairsState();
}
class _MemoryPairsState extends State<MemoryPairsGame> {
  final symbols = ['🐶', '🐱', '🦊', '🐸'];
  late List<String> cards; final revealed = <int>{}; final matched = <int>{}; int? first; bool busy = false;
  @override void initState() { super.initState(); cards = [...symbols, ...symbols]..shuffle(); }
  Future<void> _tap(int i) async {
    if (busy || revealed.contains(i) || matched.contains(i)) return;
    setState(() => revealed.add(i));
    if (first == null) { first = i; return; }
    final second = i;
    if (cards[first!] == cards[second]) {
      setState(() { matched.add(first!); matched.add(second); first = null; });
      if (matched.length == cards.length) Navigator.pop(context, true);
    } else {
      busy = true;
      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      setState(() { revealed.remove(first); revealed.remove(second); first = null; busy = false; });
    }
  }
  @override Widget build(BuildContext context) => GameScaffold(
    title: 'Memory Pairs 🧠', instruction: 'Find all four matching pairs.',
    child: GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (_, i) => InkWell(
        onTap: () => _tap(i), borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(color: revealed.contains(i) || matched.contains(i) ? Colors.white : const Color(0xFF7657E8), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE1DAFF), width: 2)),
          alignment: Alignment.center, child: Text(revealed.contains(i) || matched.contains(i) ? cards[i] : '❓', style: const TextStyle(fontSize: 30)),
        ),
      ),
    ),
  );
}

class ShapeSpotterGame extends StatefulWidget {
  const ShapeSpotterGame({super.key});
  @override State<ShapeSpotterGame> createState() => _ShapeSpotterState();
}
class _ShapeSpotterState extends State<ShapeSpotterGame> {
  final random = Random(); final shapes = ['●', '■', '▲', '◆']; late String target; late List<String> options; int round = 1;
  @override void initState() { super.initState(); _next(); }
  void _next() { target = shapes[random.nextInt(shapes.length)]; options = [...shapes]..shuffle(); }
  void _pick(String s) {
    if (s != target) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Look closely! 🔷'))); return; }
    if (round == 3) { Navigator.pop(context, true); return; }
    setState(() { round++; _next(); });
  }
  @override Widget build(BuildContext context) => GameScaffold(
    title: 'Shape Spotter 🔷', instruction: 'Tap the shape that matches the target.',
    child: Column(children: [
      const SizedBox(height: 18), Text(target, style: const TextStyle(fontSize: 110, fontWeight: FontWeight.w900)),
      const SizedBox(height: 20),
      Wrap(spacing: 12, runSpacing: 12, children: options.map((s) => SizedBox(width: 130, height: 75, child: OutlinedButton(onPressed: () => _pick(s), child: Text(s, style: const TextStyle(fontSize: 42))))).toList()),
      const SizedBox(height: 20), Text('Round $round of 3', style: const TextStyle(fontWeight: FontWeight.bold)),
    ]),
  );
}

class BalloonPopGame extends StatefulWidget {
  const BalloonPopGame({super.key});
  @override State<BalloonPopGame> createState() => _BalloonPopState();
}
class _BalloonPopState extends State<BalloonPopGame> {
  final random = Random(); final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.pink];
  late Color target; late List<Color> balloons; int popped = 0; int misses = 0;
  @override void initState() { super.initState(); _newRound(); }
  void _newRound() {
    target = colors[random.nextInt(colors.length)]; balloons = List.generate(8, (_) => colors[random.nextInt(colors.length)]);
    if (!balloons.contains(target)) balloons[0] = target; balloons.shuffle();
  }
  void _pop(int i) {
    if (balloons[i] != target) { setState(() => misses++); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('That one is different! 🎈'))); if (misses >= 3) setState(() => misses = 0); return; }
    setState(() { balloons[i] = Colors.transparent; popped++; }); if (popped >= 5) Navigator.pop(context, true);
  }
  @override Widget build(BuildContext context) => GameScaffold(
    title: 'Balloon Pop 🎈', instruction: 'Pop 5 balloons matching the target color.',
    child: Column(children: [
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Target: '), Container(width: 34, height: 44, decoration: BoxDecoration(color: target, shape: BoxShape.circle))]),
      const SizedBox(height: 18),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: balloons.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 12),
        itemBuilder: (_, i) => GestureDetector(onTap: balloons[i] == Colors.transparent ? null : () => _pop(i), child: AnimatedContainer(duration: const Duration(milliseconds: 180), decoration: BoxDecoration(color: balloons[i], shape: BoxShape.circle), child: balloons[i] == Colors.transparent ? const SizedBox() : const Icon(Icons.favorite, color: Colors.white70)))),
      const SizedBox(height: 18), Text('Popped $popped / 5', style: const TextStyle(fontWeight: FontWeight.bold)),
    ]),
  );
}

class ColorChoice extends StatelessWidget {
  final Color color; final VoidCallback onTap;
  const ColorChoice({super.key, required this.color, required this.onTap});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Container(height: 130, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.touch_app, color: Colors.white, size: 34)));
}

class GameScaffold extends StatelessWidget {
  final String title; final String instruction; final Widget child;
  const GameScaffold({super.key, required this.title, required this.instruction, required this.child});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: SingleChildScrollView(padding: const EdgeInsets.all(22), child: Column(children: [Text(instruction, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 10), child])));
}
