import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MagicKidsWorldApp());

class GameState extends ChangeNotifier {
  int stars = 0;
  int completed = 0;
  int plays = 0;
  int character = 0;
  bool sound = true;
  final Set<int> worlds = {0};
  final Set<String> items = {};

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    stars = p.getInt('stars') ?? 0;
    completed = p.getInt('completed') ?? 0;
    plays = p.getInt('plays') ?? 0;
    character = p.getInt('character') ?? 0;
    sound = p.getBool('sound') ?? true;
    worlds
      ..clear()
      ..addAll((p.getStringList('worlds') ?? ['0']).map(int.parse));
    items
      ..clear()
      ..addAll(p.getStringList('items') ?? []);
    notifyListeners();
  }

  Future<void> reward() async {
    stars += 3;
    completed++;
    plays++;
    if (completed >= 3) worlds.add(1);
    if (completed >= 6) worlds.add(2);
    if (completed >= 9) worlds.add(3);
    if (completed >= 12) worlds.add(4);
    if (stars >= 10) items.add('hat');
    if (stars >= 20) items.add('glasses');
    if (stars >= 30) items.add('shoes');
    final p = await SharedPreferences.getInstance();
    await p.setInt('stars', stars);
    await p.setInt('completed', completed);
    await p.setInt('plays', plays);
    await p.setInt('character', character);
    await p.setBool('sound', sound);
    await p.setStringList('worlds', worlds.map((e) => '$e').toList());
    await p.setStringList('items', items.toList());
    notifyListeners();
  }
}

class MagicKidsWorldApp extends StatefulWidget {
  const MagicKidsWorldApp({super.key});
  @override State<MagicKidsWorldApp> createState() => _AppState();
}

class _AppState extends State<MagicKidsWorldApp> {
  final game = GameState();
  @override void initState() { super.initState(); game.load(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: game,
    builder: (_, __) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Magic Kids World',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7657E8)), scaffoldBackgroundColor: const Color(0xFFF7FBFF)),
      home: HomeScreen(game: game),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  final GameState game;
  const HomeScreen({super.key, required this.game});
  @override State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int tab = 0;
  @override Widget build(BuildContext context) {
    final pages = [
      HomePage(game: widget.game, onPlay: () => openGame(context)),
      WorldsPage(game: widget.game),
      GamesPage(game: widget.game),
      RewardsPage(game: widget.game),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.public_rounded), label: 'Worlds'),
          NavigationDestination(icon: Icon(Icons.extension_rounded), label: 'Games'),
          NavigationDestination(icon: Icon(Icons.star_rounded), label: 'Rewards'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final GameState game;
  final VoidCallback onPlay;
  const HomePage({super.key, required this.game, required this.onPlay});
  @override Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hello, Explorer! 👋', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          Text('Your magical adventure awaits.', style: TextStyle(color: Colors.black54)),
        ]),
        Chip(label: Text('⭐ ${game.stars}')),
      ]),
      const SizedBox(height: 18),
      Container(
        height: 210,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: const LinearGradient(colors: [Color(0xFF7657E8), Color(0xFF32C7F5)])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('✨ MAGIC KIDS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const Text('WORLD', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
          const Text('Play • Learn • Explore', style: TextStyle(color: Colors.white, fontSize: 16)),
          const Spacer(),
          FilledButton.icon(onPressed: onPlay, icon: const Icon(Icons.play_arrow_rounded), label: const Text('PLAY NOW')),
        ]),
      ),
      const SizedBox(height: 22),
      const Text('Today’s Adventure 🌈', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      Card(child: ListTile(leading: const CircleAvatar(child: Text('🌈')), title: const Text('Rainbow Challenge', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('A short color matching game'), trailing: FilledButton(onPressed: onPlay, child: const Text('GO')))),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: StatCard(icon: '⭐', value: '${game.stars}', label: 'Stars')),
        const SizedBox(width: 10),
        Expanded(child: StatCard(icon: '🏅', value: '${game.completed}', label: 'Completed')),
        const SizedBox(width: 10),
        Expanded(child: StatCard(icon: '🎮', value: '${game.plays}', label: 'Plays')),
      ]),
      const SizedBox(height: 18),
      OutlinedButton.icon(onPressed: () => parentGate(context), icon: const Icon(Icons.family_restroom), label: const Text('Parent Zone'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52))),
    ],
  );
}

class StatCard extends StatelessWidget {
  final String icon, value, label;
  const StatCard({super.key, required this.icon, required this.value, required this.label});
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Text(icon, style: const TextStyle(fontSize: 24)), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 11))])));
}

const worldData = [
  ('Happy Forest', '🌳', 'Animals, nature & counting'),
  ('Ocean World', '🐳', 'Fish, colors & matching'),
  ('Space World', '🚀', 'Planets, rockets & numbers'),
  ('Magic Castle', '🏰', 'Shapes & memory'),
  ('Cloud World', '☁️', 'Rainbows, letters & puzzles'),
];

class WorldsPage extends StatelessWidget {
  final GameState game;
  const WorldsPage({super.key, required this.game});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('World Map 🗺️', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    const Text('Complete adventures to unlock new worlds.', style: TextStyle(color: Colors.black54)),
    const SizedBox(height: 18),
    ...List.generate(worldData.length, (i) {
      final w = worldData[i];
      final open = game.worlds.contains(i);
      return Card(child: ListTile(enabled: open, contentPadding: const EdgeInsets.all(14), leading: CircleAvatar(radius: 28, child: Text(w.$2, style: const TextStyle(fontSize: 27))), title: Text(w.$1, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(w.$3), trailing: Icon(open ? Icons.chevron_right_rounded : Icons.lock_rounded)));
    }),
  ]);
}

class GamesPage extends StatelessWidget {
  final GameState game;
  const GamesPage({super.key, required this.game});
  @override Widget build(BuildContext context) {
    final games = [('🎨','Color Match'), ('🔢','Count & Find'), ('🧠','Memory Pairs'), ('🔺','Shape Spotter'), ('🔤','Letter Fun'), ('⭐','Star Catch')];
    return GridView.builder(padding: const EdgeInsets.all(20), itemCount: games.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12), itemBuilder: (_, i) => Card(child: InkWell(onTap: () => openGame(context), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(games[i].$1, style: const TextStyle(fontSize: 42)), const SizedBox(height: 10), Text(games[i].$2, style: const TextStyle(fontWeight: FontWeight.w900))])))));
  }
}

class RewardsPage extends StatelessWidget {
  final GameState game;
  const RewardsPage({super.key, required this.game});
  @override Widget build(BuildContext context) {
    final rewards = [('hat','🧢','Sunny Hat',10), ('glasses','🤓','Happy Glasses',20), ('shoes','👟','Magic Shoes',30)];
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('My Rewards 🎁', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      Text('${game.stars} stars collected', style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      ...rewards.map((r) => Card(child: ListTile(leading: Text(r.$2, style: const TextStyle(fontSize: 35)), title: Text(r.$3, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(game.items.contains(r.$1) ? 'Unlocked!' : 'Unlock at ${r.$4} stars'), trailing: Icon(game.items.contains(r.$1) ? Icons.check_circle : Icons.lock_outline)))),
    ]);
  }
}

void openGame(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const ColorMatchGame()));

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});
  @override State<ColorMatchGame> createState() => _ColorMatchState();
}

class _ColorMatchState extends State<ColorMatchGame> {
  final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.pink];
  final random = Random();
  late Color target, a, b;
  int round = 0;
  @override void initState() { super.initState(); next(); }
  void next() { target = colors[random.nextInt(colors.length)]; a = target; do { b = colors[random.nextInt(colors.length)]; } while (b == target); if (random.nextBool()) { final t = a; a = b; b = t; } }
  void pick(Color c) { if (c != target) return; if (round == 2) { Navigator.pop(context, true); return; } setState(() { round++; next(); }); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Color Match 🎨')),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      const SizedBox(height: 20),
      Text('Find this color', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 20),
      Container(width: 140, height: 140, decoration: BoxDecoration(color: target, shape: BoxShape.circle)),
      const Spacer(),
      Row(children: [Expanded(child: ColorChoice(color: a, onTap: () => pick(a))), const SizedBox(width: 18), Expanded(child: ColorChoice(color: b, onTap: () => pick(b)))]),
      const SizedBox(height: 24),
      Text('Round ${round + 1} of 3'),
    ])),
  );
}

class ColorChoice extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  const ColorChoice({super.key, required this.color, required this.onTap});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Container(height: 130, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.touch_app, color: Colors.white, size: 34)));
}

void parentGate(BuildContext context) {
  final r = Random();
  final a = r.nextInt(5) + 2;
  final b = r.nextInt(5) + 2;
  final controller = TextEditingController();
  showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Parent Zone 👨‍👩‍👧'), content: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Adults only. Solve the question.'), Text('What is $a + $b?', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), TextField(controller: controller, keyboardType: TextInputType.number)]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')), FilledButton(onPressed: () { if (int.tryParse(controller.text) == a + b) Navigator.pop(ctx); }, child: const Text('ENTER'))]));
}
