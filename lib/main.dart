import 'package:challenges/features/challenge_one/presentation/screens/challenge_one_screen.dart';
import 'package:challenges/features/challenge_two/presentation/screens/challenge_two_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Challenges',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black),
          iconTheme: IconThemeData(color: Colors.black),
          surfaceTintColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenges')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Challenge One'),
            subtitle: const Text('Debugging Task'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const DebuggingTask(),
              ));
            },
          ),
          ListTile(
            title: const Text('Challenge Two'),
            subtitle: const Text('Product List'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProductListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
