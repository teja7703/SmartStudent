import 'dart:math';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class _Word {
  final String word;
  final String hint;
  const _Word(this.word, this.hint);
}

class WordScrambleScreen extends StatefulWidget {
  const WordScrambleScreen({super.key});

  @override
  State<WordScrambleScreen> createState() => _WordScrambleScreenState();
}

class _WordScrambleScreenState extends State<WordScrambleScreen> {
  static const _words = [
    _Word('SCIENCE', 'Study of the natural world'),
    _Word('PLANET', 'Earth is one of these'),
    _Word('GRAVITY', 'Pulls things down'),
    _Word('TEACHER', 'Helps you learn'),
    _Word('LIBRARY', 'Full of books'),
    _Word('NUMBER', 'Used for counting'),
    _Word('ENERGY', 'Power to do work'),
    _Word('FRIEND', 'A close companion'),
    _Word('GARDEN', 'Where plants grow'),
    _Word('VICTORY', 'Winning a contest'),
    _Word('KNOWLEDGE', 'What you gain by learning'),
    _Word('COMPUTER', 'An electronic machine'),
  ];

  final _random = Random();
  final _controller = TextEditingController();

  late List<_Word> _deck;
  int _index = 0;
  String _scrambled = '';
  int _score = 0;
  String? _feedback;
  bool _correct = false;

  @override
  void initState() {
    super.initState();
    _deck = [..._words]..shuffle(_random);
    _loadWord();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadWord() {
    _controller.clear();
    _feedback = null;
    _correct = false;
    _scrambled = _scramble(_deck[_index].word);
  }

  String _scramble(String word) {
    final letters = word.split('');
    String result = word;
    while (result == word) {
      letters.shuffle(_random);
      result = letters.join();
    }
    return result;
  }

  void _check() {
    final guess = _controller.text.trim().toUpperCase();
    if (guess.isEmpty) return;
    setState(() {
      if (guess == _deck[_index].word) {
        _correct = true;
        _score++;
        _feedback = 'Correct! 🎉';
      } else {
        _feedback = 'Not quite, try again';
      }
    });
  }

  void _next() {
    setState(() {
      _index = (_index + 1) % _deck.length;
      _loadWord();
    });
  }

  void _reveal() {
    setState(() {
      _feedback = 'Answer: ${_deck[_index].word}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _deck[_index];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Scramble'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('Score: $_score',
                  style: AppTextStyles.titleMedium),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                _scrambled.split('').join(' '),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.blueTint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded,
                      color: AppColors.accentOrange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Hint: ${current.hint}',
                        style: AppTextStyles.bodyLarge),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              enabled: !_correct,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium,
              onSubmitted: (_) => _check(),
              decoration: const InputDecoration(
                hintText: 'Type your answer',
              ),
            ),
            if (_feedback != null) ...[
              const SizedBox(height: 14),
              Text(
                _feedback!,
                style: AppTextStyles.titleMedium.copyWith(
                  color: _correct
                      ? AppColors.secondaryGreenDark
                      : AppColors.accentRed,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _correct ? null : _reveal,
                    child: const Text('Reveal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _correct
                      ? ElevatedButton(
                          onPressed: _next,
                          child: const Text('Next Word'),
                        )
                      : ElevatedButton(
                          onPressed: _check,
                          child: const Text('Check'),
                        ),
                ),
              ],
            ),
            if (!_correct) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _next,
                child: const Text('Skip'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
