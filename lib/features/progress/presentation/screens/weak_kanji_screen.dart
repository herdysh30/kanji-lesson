import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeakKanjiScreen extends ConsumerWidget {
  const WeakKanjiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weak Kanji')),
      body: const Center(
        child: Text('Weak Kanji List - Work in progress'),
      ),
    );
  }
}
