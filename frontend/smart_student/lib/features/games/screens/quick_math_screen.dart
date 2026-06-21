import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class QuickMathScreen extends StatefulWidget {
  const QuickMathScreen({super.key});

  @override
  State<QuickMathScreen> createState() => _QuickMathScreenState();
}

class _QuickMathScreenState extends State<QuickMathScreen> {
  final _random = Random();

  static const _gameSeconds = 60;

  Timer? _timer;
  int _secondsLeft = _gameSeconds;
  int _score = 0;
  int _best = 0;
  bool _playing = false;

  String _question = '';
  int _answer = 0;
  List<int> _options = const [];
  int? _picked;
  bool? _lastCorrect;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _score = 0;
    _secondsLeft = _gameSeconds;
    _playing = true;
    _newQuestion();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _endGame();
      } else {
        setState(() => _secondsLeft--);
      }
    });
    setState(() {});
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _playing = false;
      if (_score > _best) _best = _score;
    });
  }

  void _newQuestion() {
    final ops = ['+', '-', '×'];
    final op = ops[_random.nextInt(ops.length)];
    int a, b, result;
    switch (op) {
      case '+':
        a = _random.nextInt(50) + 1;
        b = _random.nextInt(50) + 1;
        result = a + b;
        break;
      case '-':
        a = _random.nextInt(50) + 10;
        b = _random.nextInt(a);
        result = a - b;
        break;
      default:
        a = _random.nextInt(12) + 1;
        b = _random.nextInt(12) + 1;
        result = a * b;
    }

    final options = <int>{result};
    while (options.length < 4) {
      final delta = _random.nextInt(10) - 5;
      final candidate = result + delta;
      if (candidate >= 0 && candidate != result) options.add(candidate);
    }
    final list = options.toList()..shuffle(_random);

    _question = '$a $op $b';
    _answer = result;
    _options = list;
    _picked = null;
    _lastCorrect = null;
  }

  void _pick(int value) {
    if (!_playing || _picked != null) return;
    final correct = value == _answer;
    setState(() {
      _picked = value;
      _lastCorrect = correct;
      if (correct) _score++;
    });
    Timer(const Duration(milliseconds: 300), () {
      if (!mounted || !_playing) return;
      setState(_newQuestion);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Math')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _playing ? _buildGame() : _buildStart(),
      ),
    );
  }

  Widget _buildStart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calculate_rounded,
              size: 72, color: AppColors.primaryBlue),
          const SizedBox(height: 16),
          Text('Quick Math Challenge',
              style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Solve as many as you can in $_gameSeconds seconds!',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (_best > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('Best score: $_best',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.secondaryGreen)),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _start,
              child: Text(_best > 0 ? 'Play Again' : 'Start'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Badge(
              icon: Icons.star_rounded,
              label: 'Score: $_score',
              color: AppColors.accentOrange,
            ),
            _Badge(
              icon: Icons.timer_rounded,
              label: '${_secondsLeft}s',
              color: _secondsLeft <= 10
                  ? AppColors.accentRed
                  : AppColors.primaryBlue,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _secondsLeft / _gameSeconds,
          minHeight: 6,
          borderRadius: BorderRadius.circular(6),
          backgroundColor: AppColors.divider,
          color: _secondsLeft <= 10
              ? AppColors.accentRed
              : AppColors.primaryBlue,
        ),
        const Spacer(),
        Text(_question, style: AppTextStyles.displayLarge),
        const SizedBox(height: 8),
        Text('= ?', style: AppTextStyles.headlineMedium),
        const Spacer(),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: _options.map(_optionButton).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _optionButton(int value) {
    Color bg = AppColors.surfaceLight;
    Color fg = AppColors.textPrimary;
    Color border = AppColors.divider;

    if (_picked != null && value == _picked) {
      final correct = _lastCorrect == true;
      bg = (correct ? AppColors.secondaryGreen : AppColors.accentRed)
          .withValues(alpha: 0.15);
      fg = correct ? AppColors.secondaryGreenDark : AppColors.accentRed;
      border = correct ? AppColors.secondaryGreen : AppColors.accentRed;
    } else if (_picked != null && value == _answer) {
      bg = AppColors.secondaryGreen.withValues(alpha: 0.15);
      border = AppColors.secondaryGreen;
    }

    return GestureDetector(
      onTap: () => _pick(value),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.4),
        ),
        alignment: Alignment.center,
        child: Text('$value',
            style: AppTextStyles.headlineMedium.copyWith(color: fg)),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.labelLarge.copyWith(color: color)),
        ],
      ),
    );
  }
}
