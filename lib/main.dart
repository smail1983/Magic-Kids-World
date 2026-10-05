import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MagicKidsWorldApp());

class GameState extends ChangeNotifier {
  int stars = 0;
  int level = 1;
  int completed = 0;
  int plays = 0;
  int character = 0;
  bool sound = true;
  final Set<int> unlockedWorlds = {0};
  final Set<String> unlockedItems = {};

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    stars = p.getInt('stars') ?? 0;
    level = p.getInt('level') ?? 1;
    completed = p.getInt('completed') ?? 0;
    plays = p.getInt('plays') ?? 0;
    character = p.getInt('character') ?? 0;
    sound = p.getBool('sound') ?? true;
    unlockedWorlds
      ..clear()
      ..addAll((p.getStringList('worlds') ?? ['0']).map(int.parse));
    unlockedItems
      ..clear()
      ..addAll(p.getStringList('items') ?? []);
    notifyListeners();
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('stars', stars);
    await p.setInt('level', level);
    await p.setInt('completed', completed);
    await p.setInt('plays', plays);
    await p.setInt('character', character);
    await p.setBool('sound', sound);
    await p.setStringList('worlds', unlockedWorlds.map((e) => '$e').toList());
    await p.setStringList('items', unlockedItems.toList());
  }

  Future<void> reward([int amount = 3]) async {
    stars += amount;
    completed += 1;
    plays += 1;
    if (completed >= 3) unlockedWorlds.add(1);
    if (completed >= 6) unlockedWorlds.add(2);
    if (completed >= 9) unlockedWorlds.add(3);
    if (completed >= 12) unlockedWorlds.add(4);
    level = min(20, 1 + completed ~/ 2);
    if (stars >= 10) unlockedItems.add('hat');
    if (stars >= 20) unlockedItems.add('glasses');
    if (stars >= 30) unlockedItems.add('shoes');
    await save();
    notifyListeners();
  }
}

class MagicKidsWorldApp extends StatefulWidget {
  const MagicKidsWorldApp({super.key});
  @override State<MagicKidsWorldApp> createState() => _MagicKidsWorldAppState();
}

class _MagicKidsWorldAppState extends State<MagicKidsWorldApp> {
  final state = GameState();
  @override void initState() { super.initState(); state.load(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: state,
    builder: (_, __) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Magic Kids World',
      theme: ThemeData(useMaterial3: true, fontFamily: 'sans-serif', scaffoldBackgroundColor: const Color(0xFFF7FBFF), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF))),
      home: HomeScreen(state: state),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  final GameState state;
  const HomeScreen({super.key, required this.state});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  final pages = ['Home', 'Worlds', 'Games', 'Rewards'];
  @override Widget build(BuildContext context) {
    final s = widget.state;
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: tab, children: [
        Dashboard(state: s, onPlay: () => openGame(context, s)),
        WorldsScreen(state: s),
        GamesScreen(state: s),
        RewardsScreen(state: s),
      ])),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: const [
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.public_rounded), label: 'Worlds'),
        NavigationDestination(icon: Icon(Icons.extension_rounded), label: 'Games'),
        NavigationDestination(icon: Icon(Icons.star_rounded), label: 'Rewards'),
      ]),
    );
  }
}

class Dashboard extends StatelessWidget {
  final GameState state; final VoidCallback onPlay;
  const Dashboard({super.key, required this.state, required this.onPlay});
  @override Widget build(BuildContext context) => SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Hello, little explorer! 👋', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), Text('Your magical adventure awaits.', style: TextStyle(color: Colors.black54))]),
      StarPill(stars: state.stars),
    ]),
    const SizedBox(height: 18),
    Container(height: 190, decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF35C9FF)])), child: Stack(children: [
      Positioned(right: 18, top: 18, child: Text('🪐', style: TextStyle(fontSize: 60))),
      Positioned(left: 22, top: 24, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('MAGIC KIDS', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 2)), SizedBox(height: 4), Text('WORLD', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('Play • Learn • Explore', style: TextStyle(color: Colors.white70, fontSize: 15))])),
      Positioned(left: 20, bottom: 18, child: FilledButton.icon(onPressed: onPlay, icon: const Icon(Icons.play_arrow_rounded), label: const Text('PLAY NOW'), style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF5E51D9), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13)))),
    ])),
    const SizedBox(height: 22),
    const Text('Today’s Adventure ✨', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
    const SizedBox(height: 10),
    Card(child: ListTile(contentPadding: const EdgeInsets.all(14), leading: CircleAvatar(radius: 27, backgroundColor: const Color(0xFFFFE7A8), child: const Text('🌈', style: TextStyle(fontSize: 27))), title: const Text('Rainbow Challenge', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('A short matching game • Earn 3 stars'), trailing: FilledButton(onPressed: onPlay, child: const Text('GO')))),
    const SizedBox(height: 18),
    Row(children: [Expanded(child: StatCard(icon: '⭐', value: '${state.stars}', label: 'Stars')), const SizedBox(width: 10), Expanded(child: StatCard(icon: '🏅', value: '${state.completed}', label: 'Completed')), const SizedBox(width: 10), Expanded(child: StatCard(icon: '🎮', value: '${state.plays}', label: 'Plays'))]),
    const SizedBox(height: 18),
    OutlinedButton.icon(onPressed: () => showParentGate(context, state), icon: const Icon(Icons.family_restroom_rounded), label: const Text('Parent Zone'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52))),
  ]));
}

class StarPill extends StatelessWidget { final int stars; const StarPill({super.key, required this.stars}); @override Widget build(BuildContext c) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFFFF1B8), borderRadius: BorderRadius.circular(20)), child: Text('⭐ $stars', style: const TextStyle(fontWeight: FontWeight.w900))); }
class StatCard extends StatelessWidget { final String icon, value, label; const StatCard({super.key, required this.icon, required this.value, required this.label}); @override Widget build(BuildContext c) => Card(child: Padding(padding: const EdgeInsets.all(13), child: Column(children: [Text(icon, style: const TextStyle(fontSize: 24)), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54))]))); }

final worlds = [
  ['Happy Forest', '🌳', 'Animals, nature & counting', Color(0xFFDDF7D6)],
  ['Ocean World', '🐳', 'Fish, colors & matching', Color(0xFFD8F2FF)],
  ['Space World', '🚀', 'Planets, rockets & numbers', Color(0xFFE9DFFF)],
  ['Magic Castle', '🏰', 'Shapes & memory', Color(0xFFFFE1F1)],
  ['Cloud World', '☁️', 'Rainbows, letters & puzzles', Color(0xFFFFF0C7)],
];

class WorldsScreen extends StatelessWidget { final GameState state; const WorldsScreen({super.key, required this.state}); @override Widget build(BuildContext c) => ListView(padding: const EdgeInsets.all(20), children: [const Text('World Map 🗺️', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 6), const Text('Complete adventures to discover new worlds.', style: TextStyle(color: Colors.black54)), const SizedBox(height: 18), ...List.generate(worlds.length, (i) { final w=worlds[i]; final open=state.unlockedWorlds.contains(i); return Padding(padding: const EdgeInsets.only(bottom: 12), child: Card(child: ListTile(enabled: open, contentPadding: const EdgeInsets.all(12), leading: CircleAvatar(radius: 30, backgroundColor: w[3] as Color, child: Text(w[1] as String, style: const TextStyle(fontSize: 29))), title: Text(w[0] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), subtitle: Text(w[2] as String), trailing: open ? const Icon(Icons.chevron_right_rounded) : const Icon(Icons.lock_rounded)))); })]); }

class GamesScreen extends StatelessWidget { final GameState state; const GamesScreen({super.key, required this.state}); @override Widget build(BuildContext c) { final games=[['🎨','Color Match','Match two colors'],['🔢','Count & Find','Count friendly objects'],['🧠','Memory Pairs','Find matching cards'],['🔺','Shape Spotter','Find the right shape'],['🔤','Letter Fun','Recognize letters'],['⭐','Star Catch','Catch falling stars']]; return GridView.builder(padding: const EdgeInsets.all(20), itemCount: games.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .95), itemBuilder: (_,i) => Card(child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () => openGame(c,state), child: Padding(padding: const EdgeInsets.all(14), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(games[i][0], style: const TextStyle(fontSize: 42)), const SizedBox(height: 10), Text(games[i][1], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 5), Text(games[i][2], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54))])))); } }

class RewardsScreen extends StatelessWidget { final GameState state; const RewardsScreen({super.key, required this.state}); @override Widget build(BuildContext c) { final items=[['hat','🧢','Sunny Hat',10],['glasses','🤓','Happy Glasses',20],['shoes','👟','Magic Shoes',30],['cape','🦸','Rainbow Cape',40]]; return ListView(padding: const EdgeInsets.all(20), children: [const Text('My Rewards 🎁', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text('${state.stars} stars collected', style: const TextStyle(color: Colors.black54)), const SizedBox(height: 20), ...items.map((x) { final unlocked=state.unlockedItems.contains(x[0]); return Card(child: ListTile(contentPadding: const EdgeInsets.all(12), leading: Text(x[1] as String, style: const TextStyle(fontSize: 38)), title: Text(x[2] as String, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(unlocked ? 'Unlocked!' : 'Unlock at ${x[3]} stars'), trailing: unlocked ? const Icon(Icons.check_circle_rounded, color: Colors.green) : const Icon(Icons.lock_outline_rounded))); })]); } }

void openGame(BuildContext context, GameState state) { Navigator.of(context).push(MaterialPageRoute(builder: (_) => ColorMatchGame(state: state))); }

class ColorMatchGame extends StatefulWidget { final GameState state; const ColorMatchGame({super.key, required this.state}); @override State<ColorMatchGame> createState()=>_ColorMatchGameState(); }
class _ColorMatchGameState extends State<ColorMatchGame> { final colors=[Colors.red,Colors.blue,Colors.green,Colors.orange,Colors.purple,Colors.pink]; late Color target; late Color option1; late Color option2; int score=0; final r=Random(); @override void initState(){super.initState(); next();} void next(){ target=colors[r.nextInt(colors.length)]; option1=target; do{option2=colors[r.nextInt(colors.length)];}while(option2==target); if(r.nextBool()){final t=option1;option1=option2;option2=t;} } void pick(Color c){ if(c==target){score++; if(score>=3){widget.state.reward(3); showDialog(context:context,barrierDismissible:false,builder:(_)=>AlertDialog(title:const Text('Great Job! ⭐'),content:const Text('You matched the colors and earned 3 stars!'),actions:[TextButton(onPressed:(){Navigator.pop(context);Navigator.pop(context);},child:const Text('AWESOME!'))]));} else {setState(next);} } } @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Color Match 🎨')),body:Padding(padding:const EdgeInsets.all(24),child:Column(children:[const SizedBox(height:20),Text('Find this color',style:Theme.of(c).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900)),const SizedBox(height:18),Container(width:130,height:130,decoration:BoxDecoration(color:target,shape:BoxShape.circle,boxShadow:const[BoxShadow(blurRadius:14,offset:Offset(0,7),color:Colors.black12)])),const Spacer(),Row(children:[Expanded(child:ColorButton(color:option1,onTap:()=>pick(option1))),const SizedBox(width:18),Expanded(child:ColorButton(color:option2,onTap:()=>pick(option2)))]),const SizedBox(height:30),Text('Round ${score+1} of 3',style:const TextStyle(color:Colors.black54)),const SizedBox(height:15)]))); }
class ColorButton extends StatelessWidget { final Color color; final VoidCallback onTap; const ColorButton({super.key,required this.color,required this.onTap}); @override Widget build(BuildContext c)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(24),child:Container(height:130,decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(24)),child:const Center(child:Icon(Icons.touch_app_rounded,color:Colors.white,size:34)))); }

void showParentGate(BuildContext context, GameState state) { final a=Random().nextInt(5)+2,b=Random().nextInt(5)+2; final controller=TextEditingController(); showDialog(context:context,builder:(ctx)=>AlertDialog(title:const Text('Parent Zone 👨‍👩‍👧'),content:Column(mainAxisSize:MainAxisSize.min,children:[const Text('Adults only. Please solve this simple question.'),const SizedBox(height:12),Text('What is $a + $b?',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800)),TextField(controller:controller,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Answer'))]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('CANCEL')),FilledButton(onPressed:(){if(int.tryParse(controller.text)==a+b){Navigator.pop(ctx);showParentPanel(context,state);} },child:const Text('ENTER'))])); }
void showParentPanel(BuildContext context, GameState state) { showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('Parent Zone'),content:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Completed levels: ${state.completed}'),Text('Stars earned: ${state.stars}'),Text('Games played: ${state.plays}'),const SizedBox(height:12),SwitchListTile(contentPadding:EdgeInsets.zero,value:state.sound,onChanged:(v){state.sound=v;state.save();state.notifyListeners();},title:const Text('Sound effects')),const SizedBox(height:8),const Text('Privacy: progress is stored locally on this device. No account, chat, location tracking or personal profile is required.',style:TextStyle(fontSize:12,color:Colors.black54))]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('DONE'))])); }
