import 'package:flutter/material.dart';
import 'main.dart';
import 'character_selector.dart';
import 'world_adventures.dart';

class AdventureMenu extends StatelessWidget {
  final GameState game;
  const AdventureMenu({super.key, required this.game});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('My Adventure ✨', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    const SizedBox(height: 6),
    Text('⭐ ${game.stars} stars • 🏅 ${game.completed} adventures', style: const TextStyle(color: Colors.black54)),
    const SizedBox(height: 18),
    Card(child: ListTile(leading: const Text('🧒', style: TextStyle(fontSize: 38)), title: const Text('Choose Your Friend', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Pick a character for your adventure'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CharacterSelector(game: game))))),
    Card(child: ListTile(leading: const Text('🗺️', style: TextStyle(fontSize: 38)), title: const Text('Explore Worlds', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Unlock magical worlds by playing'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorldAdventures(game: game))))),
  ]);
}
