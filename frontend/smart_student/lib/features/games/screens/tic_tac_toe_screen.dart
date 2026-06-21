import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  static const _player = 'X';
  static const _computer = 'O';

  List<String> _board = List.filled(9, '');
  bool _locked = false;
  String _status = 'Your turn (X)';
  int _wins = 0;
  int _losses = 0;
  int _draws = 0;

  static const _lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // cols
    [0, 4, 8], [2, 4, 6], // diagonals
  ];

  void _reset() {
    setState(() {
      _board = List.filled(9, '');
      _locked = false;
      _status = 'Your turn (X)';
    });
  }

  String? _winner(List<String> b) {
    for (final line in _lines) {
      final a = b[line[0]];
      if (a.isNotEmpty && a == b[line[1]] && a == b[line[2]]) return a;
    }
    if (!b.contains('')) return 'draw';
    return null;
  }

  void _onTap(int index) {
    if (_locked || _board[index].isNotEmpty) return;
    setState(() => _board[index] = _player);

    final result = _winner(_board);
    if (result != null) {
      _finish(result);
      return;
    }

    _locked = true;
    setState(() => _status = 'Computer thinking...');
    Timer(const Duration(milliseconds: 450), _computerMove);
  }

  void _computerMove() {
    if (!mounted) return;
    final move = _bestMove();
    if (move != -1) _board[move] = _computer;

    final result = _winner(_board);
    if (result != null) {
      _finish(result);
    } else {
      setState(() {
        _locked = false;
        _status = 'Your turn (X)';
      });
    }
  }

  int _bestMove() {
    // Win if possible.
    final win = _findLineMove(_computer);
    if (win != -1) return win;
    // Block the player.
    final block = _findLineMove(_player);
    if (block != -1) return block;
    // Center.
    if (_board[4].isEmpty) return 4;
    // A corner.
    final corners = [0, 2, 6, 8]..shuffle(Random());
    for (final c in corners) {
      if (_board[c].isEmpty) return c;
    }
    // Any remaining cell.
    final empty = [
      for (var i = 0; i < 9; i++)
        if (_board[i].isEmpty) i
    ];
    if (empty.isEmpty) return -1;
    return empty[Random().nextInt(empty.length)];
  }

  int _findLineMove(String mark) {
    for (final line in _lines) {
      final values = line.map((i) => _board[i]).toList();
      final marks = values.where((v) => v == mark).length;
      final empties = values.where((v) => v.isEmpty).length;
      if (marks == 2 && empties == 1) {
        return line[values.indexWhere((v) => v.isEmpty)];
      }
    }
    return -1;
  }

  void _finish(String result) {
    setState(() {
      _locked = true;
      if (result == 'draw') {
        _status = "It's a draw!";
        _draws++;
      } else if (result == _player) {
        _status = 'You win! 🎉';
        _wins++;
      } else {
        _status = 'Computer wins!';
        _losses++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameOver = _winner(_board) != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Score(label: 'Wins', value: _wins, color: AppColors.secondaryGreen),
                _Score(label: 'Draws', value: _draws, color: AppColors.textSecondary),
                _Score(label: 'Losses', value: _losses, color: AppColors.accentRed),
              ],
            ),
            const SizedBox(height: 20),
            Text(_status, style: AppTextStyles.headlineMedium),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  final mark = _board[index];
                  final isX = mark == _player;
                  return GestureDetector(
                    onTap: () => _onTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider, width: 1.4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        mark,
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: mark.isEmpty
                              ? Colors.transparent
                              : isX
                                  ? AppColors.primaryBlue
                                  : AppColors.accentOrange,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: gameOver
                  ? ElevatedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Play Again'),
                    )
                  : OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset Board'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Score extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _Score({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: AppTextStyles.headlineLarge.copyWith(color: color)),
        Text(label, style: AppTextStyles.labelMedium),
      ],
    );
  }
}
