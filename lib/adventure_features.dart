import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class CharacterPage extends StatelessWidget {
  final GameState game;
  const CharacterPage({super.key, required this.game});
  static const characters = [('🧒', 'Sunny'), ('👧', 'Luna'), ('🦊', 'Foxy'), ('🐼', 'Panda'), ('🐰', 'Bunny'), ('🐨', 'Koko')];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Choose Your Friend')),
    body: GridView.builder(
      padding: const EdgeInsets.all(20), itemCount: characters.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14),
      itemBuilder: (_, i) {
        final selected = game.character == i;
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            game.character = i;
            final p = await SharedPreferences.getInstance();
            await p.setInt('character', i);
            game.notifyListeners();
            if (context.mounted) Navigator.pop(context);
          },
          child: Card(elevation: selected ? 5 : 1, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(characters[i].$1, style: const TextStyle(fontSize: 60)),
            Text(characters[i].$2, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            if (selected) const Text('Selected ⭐', style: TextStyle(fontSize: 12)),
          ])),
        );
      },
    ),
  );
}

class WorldAdventurePage extends StatelessWidget {
  final int world;
  final GameState game;
  const WorldAdventurePage({super.key, required this.world, required this.game});
  static const names = ['Happy Forest', 'Ocean World', 'Space World', 'Magic Castle', 'Cloud World'];
  static const icons = ['🌳', '🐳', '🚀', '🏰', '☁️'];
  static const activities = [
    ['Animal Match 🐾', 'Count the friendly forest animals.'],
    ['Ocean Colors 🌊', 'Match the colorful sea creatures.'],
    ['Rocket Numbers 🚀', 'Choose the correct number for the rocket.'],
    ['Castle Memory 🏰', 'Remember the magical cards.'],
    ['Rainbow Puzzle 🌈', 'Put the rainbow colors in order.'],
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${icons[world]} ${names[world]}')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(height: 170, decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF7657E8), Color(0xFF32C7F5)])), child: Center(child: Text(icons[world], style: const TextStyle(fontSize: 90)))),
      const SizedBox(height: 18),
      Text(names[world], style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(activities[world][1], style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      Card(child: ListTile(leading: Text(activities[world][0], style: const TextStyle(fontSize: 27)), title: const Text('Adventure coming up!', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('More mini-games will unlock here.'))),
      const SizedBox(height: 10),
      Text('⭐ ${game.stars} stars', style: const TextStyle(fontWeight: FontWeight.bold)),
    ]),
  );
}
