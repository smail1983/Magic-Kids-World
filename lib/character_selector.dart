import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class CharacterSelector extends StatelessWidget {
  final GameState game;
  const CharacterSelector({super.key, required this.game});
  static const characters = [('🧒','Sunny'),('👧','Luna'),('🦊','Foxy'),('🐼','Panda'),('🐰','Bunny'),('🐨','Koko')];
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Choose Your Friend')),
    body: GridView.builder(padding: const EdgeInsets.all(20), itemCount: characters.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14), itemBuilder: (_, i) {
      final selected = game.character == i;
      return InkWell(borderRadius: BorderRadius.circular(24), onTap: () async {
        game.character = i; final p = await SharedPreferences.getInstance(); await p.setInt('character', i); game.notifyListeners(); if (context.mounted) Navigator.pop(context);
      }, child: Card(elevation: selected ? 6 : 1, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(characters[i].$1, style: const TextStyle(fontSize: 58)), Text(characters[i].$2, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), if (selected) const Text('Selected ⭐')] )));
    }),
  );
}
