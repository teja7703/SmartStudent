import 'dart:math';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class GuessNumberScreen extends StatefulWidget {
  const GuessNumberScreen({super.key});

  @override
  State<GuessNumberScreen> createState() => _GuessNumberScreenState();
}

class _GuessNumberScreenState extends State<GuessNumberScreen> {
  static const _min = 1;
  static const _max = 100;
  static const _maxAttempts = 7;

  final _random = Random();
  final _controller = TextEditingController();

  late int _target;
  int _attempts = 0;
  String _hint = 'I picked a number between $_min and $_max. Can you guess it?';
  bool _over = false;
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _target = _random.nextInt(_max - _min + 1) + _min;
      _attempts = 0;
      _over = false;
      _history.clear();
      _hint = 'I picked a number between $_min and $_max. Can you guess it?';
      _controller.clear();
    });
  }

  void _guess() {
    if (_over) return;
    final value = int.tryParse(_controller.text.trim());
    _controller.clear();
    if (value == null || value < _min || value > _max) {
      setState(() => _hint = 'Enter a number between $_min and $_max.');
      return;
    }

    _attempts++;
    setState(() {
      if (value == _target) {
        _over = true;
        _hint = 'Correct! 🎉 You got it in $_attempts tries.';
        _history.insert(0, '$value ✅');
      } else {
        final tooLow = value < _target;
        _history.insert(0, '$value ${tooLow ? '⬆️ too low' : '⬇️ too high'}');
        if (_attempts >= _maxAttempts) {
          _over = true;
          _hint = 'Out of tries! The number was $_target.';
        } else {
          _hint = tooLow ? 'Too low! Try higher.' : 'Too high! Try lower.';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guess the Number')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    _hint,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Attempts: $_attempts / $_maxAttempts',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!_over) ...[
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium,
                onSubmitted: (_) => _guess(),
                decoration: const InputDecoration(
                  hintText: 'Enter your guess',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guess,
                  child: const Text('Guess'),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Play Again'),
                ),
              ),
            const SizedBox(height: 20),
            if (_history.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Your guesses',
                    style: AppTextStyles.labelMedium),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _history.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(_history[index],
                        style: AppTextStyles.bodyLarge),
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
