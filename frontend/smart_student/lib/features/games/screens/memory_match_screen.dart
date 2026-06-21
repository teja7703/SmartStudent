import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  static const _emojis = ['🍎', '🚀', '⭐', '🎈', '🐶', '🌸', '⚽', '🎲'];

  late List<String> _cards;
  late List<bool> _revealed;
  late List<bool> _matched;
  int? _firstIndex;
  bool _busy = false;
  int _moves = 0;
  int _pairsFound = 0;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    final deck = [..._emojis, ..._emojis];
    deck.shuffle(Random());
    _cards = deck;
    _revealed = List.filled(deck.length, false);
    _matched = List.filled(deck.length, false);
    _firstIndex = null;
    _busy = false;
    _moves = 0;
    _pairsFound = 0;
    setState(() {});
  }

  void _onTap(int index) {
    if (_busy || _revealed[index] || _matched[index]) return;

    setState(() => _revealed[index] = true);

    if (_firstIndex == null) {
      _firstIndex = index;
      return;
    }

    _moves++;
    final first = _firstIndex!;
    _firstIndex = null;

    if (_cards[first] == _cards[index]) {
      setState(() {
        _matched[first] = true;
        _matched[index] = true;
        _pairsFound++;
      });
      if (_pairsFound == _emojis.length) _showWin();
    } else {
      _busy = true;
      Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _revealed[first] = false;
          _revealed[index] = false;
          _busy = false;
        });
      });
    }
  }

  void _showWin() {
    Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('You did it! 🎉'),
          content: Text('You matched all pairs in $_moves moves.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _setup();
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _setup,
            tooltip: 'Restart',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(label: 'Moves', value: '$_moves'),
                _Stat(label: 'Pairs', value: '$_pairsFound/${_emojis.length}'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final faceUp = _revealed[index] || _matched[index];
                  return GestureDetector(
                    onTap: () => _onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: faceUp
                            ? null
                            : AppColors.purpleGradient,
                        color: faceUp
                            ? (_matched[index]
                                ? AppColors.secondaryGreen
                                    .withValues(alpha: 0.18)
                                : AppColors.surfaceLight)
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _matched[index]
                              ? AppColors.secondaryGreen
                              : AppColors.divider,
                          width: _matched[index] ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        faceUp ? _cards[index] : '?',
                        style: TextStyle(
                          fontSize: faceUp ? 30 : 24,
                          color: faceUp ? null : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineMedium),
        Text(label, style: AppTextStyles.labelMedium),
      ],
    );
  }
}
