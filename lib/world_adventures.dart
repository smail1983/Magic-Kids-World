import 'package:flutter/material.dart';
import 'main.dart';

class WorldAdventures extends StatelessWidget {
  final GameState game;
  const WorldAdventures({super.key, required this.game});
  static const names = ['Happy Forest', 'Ocean World', 'Space World', 'Magic Castle', 'Cloud World'];
  static const icons = ['🌳', '🐳', '🚀', '🏰', '☁️'];
  static const descriptions = ['Animals, nature & counting', 'Fish, colors & matching', 'Planets, rockets & numbers', 'Shapes & memory', 'Rainbows, letters & puzzles'];
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('World Adventures 🗺️')),
    body: ListView.builder(padding: const EdgeInsets.all(20), itemCount: names.length, itemBuilder: (_, i) {
      final unlocked = game.worlds.contains(i);
      return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(enabled: unlocked, contentPadding: const EdgeInsets.all(14), leading: CircleAvatar(radius: 29, child: Text(icons[i], style: const TextStyle(fontSize: 27))), title: Text(names[i], style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(unlocked ? descriptions[i] : '🔒 Complete more games to unlock'), trailing: Icon(unlocked ? Icons.play_arrow_rounded : Icons.lock_rounded), onTap: unlocked ? () => _open(context, i) : null));
    }),
  );
  void _open(BuildContext context, int i) => showDialog(context: context, builder: (_) => AlertDialog(title: Text('${icons[i]} ${names[i]}'), content: Text('Welcome to ${names[i]}! More adventures will appear here as the world grows.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('LET’S GO!'))]));
}
