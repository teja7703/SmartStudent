import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class _Riddle {
  final String question;
  final String answer;
  const _Riddle(this.question, this.answer);
}

class RiddlesScreen extends StatefulWidget {
  const RiddlesScreen({super.key});

  @override
  State<RiddlesScreen> createState() => _RiddlesScreenState();
}

class _RiddlesScreenState extends State<RiddlesScreen> {
  static const _riddles = [
    _Riddle(
        'What has hands but cannot clap?', 'A clock.'),
    _Riddle(
        'What has to be broken before you can use it?', 'An egg.'),
    _Riddle(
        'I am tall when I am young and short when I am old. What am I?',
        'A candle.'),
    _Riddle(
        'What has keys but opens no locks?', 'A piano (or a keyboard).'),
    _Riddle(
        'What gets wetter the more it dries?', 'A towel.'),
    _Riddle(
        'What has a head and a tail but no body?', 'A coin.'),
    _Riddle(
        'The more you take, the more you leave behind. What are they?',
        'Footsteps.'),
    _Riddle(
        'What has many teeth but cannot bite?', 'A comb.'),
    _Riddle(
        'What can travel around the world while staying in a corner?',
        'A postage stamp.'),
    _Riddle(
        'What goes up but never comes down?', 'Your age.'),
    _Riddle(
        'What has one eye but cannot see?', 'A needle.'),
    _Riddle(
        'What runs but never walks, has a bed but never sleeps?',
        'A river.'),
  ];

  final Set<int> _revealed = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riddles')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _riddles.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final riddle = _riddles[index];
          final shown = _revealed.contains(index);
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text('${index + 1}',
                          style: AppTextStyles.labelLarge
                              .copyWith(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(riddle.question,
                          style: AppTextStyles.bodyLarge),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: shown
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.greenTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.secondaryGreen, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(riddle.answer,
                                style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.secondaryGreenDark)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  secondChild: const SizedBox(width: double.infinity),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      if (shown) {
                        _revealed.remove(index);
                      } else {
                        _revealed.add(index);
                      }
                    }),
                    icon: Icon(shown
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded),
                    label: Text(shown ? 'Hide answer' : 'Show answer'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
