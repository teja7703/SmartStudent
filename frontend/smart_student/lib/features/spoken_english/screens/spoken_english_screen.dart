import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';

class _Phrase {
  final String english;
  final String telugu;
  const _Phrase(this.english, this.telugu);
}

class _Lesson {
  final String title;
  final IconData icon;
  final Color color;
  final List<_Phrase> phrases;
  const _Lesson(this.title, this.icon, this.color, this.phrases);
}

class SpokenEnglishScreen extends StatelessWidget {
  const SpokenEnglishScreen({super.key});

  static const List<_Lesson> _lessons = [
    _Lesson('Greetings', Icons.waving_hand_rounded, AppColors.primaryBlue, [
      _Phrase('Good morning!', 'శుభోదయం!'),
      _Phrase('How are you?', 'మీరు ఎలా ఉన్నారు?'),
      _Phrase('I am fine, thank you.', 'నేను బాగున్నాను, ధన్యవాదాలు.'),
      _Phrase('Nice to meet you.', 'మిమ్మల్ని కలవడం సంతోషంగా ఉంది.'),
      _Phrase('See you later!', 'మళ్ళీ కలుద్దాం!'),
    ]),
    _Lesson('At School', Icons.school_rounded, AppColors.secondaryGreen, [
      _Phrase('May I come in?', 'నేను లోపలికి రావచ్చా?'),
      _Phrase('I have a doubt.', 'నాకు ఒక సందేహం ఉంది.'),
      _Phrase('Please explain again.', 'దయచేసి మళ్ళీ వివరించండి.'),
      _Phrase('Can you help me?', 'మీరు నాకు సహాయం చేస్తారా?'),
      _Phrase('I have finished my work.', 'నా పని పూర్తి చేశాను.'),
    ]),
    _Lesson('Daily Conversations', Icons.chat_rounded, AppColors.accentPurple, [
      _Phrase('What is your name?', 'మీ పేరు ఏమిటి?'),
      _Phrase('Where do you live?', 'మీరు ఎక్కడ నివసిస్తారు?'),
      _Phrase('What are you doing?', 'మీరు ఏం చేస్తున్నారు?'),
      _Phrase('I do not understand.', 'నాకు అర్థం కావడం లేదు.'),
      _Phrase('Please wait a moment.', 'దయచేసి కొంచెం ఆగండి.'),
    ]),
    _Lesson('Asking for Help', Icons.help_rounded, AppColors.accentOrange, [
      _Phrase('Excuse me.', 'క్షమించండి.'),
      _Phrase('Could you repeat that?', 'మీరు దాన్ని మళ్ళీ చెప్పగలరా?'),
      _Phrase('How do I get there?', 'అక్కడికి ఎలా వెళ్ళాలి?'),
      _Phrase('Can you speak slowly?', 'మీరు నెమ్మదిగా మాట్లాడగలరా?'),
      _Phrase('Thank you so much.', 'చాలా ధన్యవాదాలు.'),
    ]),
    _Lesson('Confidence Phrases', Icons.bolt_rounded, AppColors.accentRed, [
      _Phrase('I can do it.', 'నేను దీన్ని చేయగలను.'),
      _Phrase('I am learning English.', 'నేను ఇంగ్లీష్ నేర్చుకుంటున్నాను.'),
      _Phrase('Practice makes perfect.', 'సాధనతో నైపుణ్యం వస్తుంది.'),
      _Phrase('I will try my best.', 'నేను నా శాయశక్తులా ప్రయత్నిస్తాను.'),
      _Phrase('Never give up.', 'ఎప్పుడూ వదులుకోవద్దు.'),
    ]),
    _Lesson('Introduce Yourself', Icons.person_rounded, AppColors.primaryBlueDark, [
      _Phrase('My name is Ravi.', 'నా పేరు రవి.'),
      _Phrase('I am from Andhra Pradesh.', 'నేను ఆంధ్రప్రదేశ్ నుండి వచ్చాను.'),
      _Phrase('I am a student.', 'నేను ఒక విద్యార్థిని.'),
      _Phrase('I study in 10th class.', 'నేను పదవ తరగతి చదువుతున్నాను.'),
      _Phrase('My hobby is reading books.', 'పుస్తకాలు చదవడం నా అభిరుచి.'),
      _Phrase('Nice to meet you all.', 'మీ అందరినీ కలవడం సంతోషంగా ఉంది.'),
    ]),
    _Lesson('Numbers & Time', Icons.schedule_rounded, AppColors.secondaryGreenDark, [
      _Phrase('What time is it now?', 'ఇప్పుడు సమయం ఎంత?'),
      _Phrase('It is ten o\'clock.', 'పది గంటలు అయింది.'),
      _Phrase('I wake up at six.', 'నేను ఆరు గంటలకు లేస్తాను.'),
      _Phrase('See you tomorrow.', 'రేపు కలుద్దాం.'),
      _Phrase('Today is Monday.', 'ఈ రోజు సోమవారం.'),
      _Phrase('Please come on time.', 'దయచేసి సమయానికి రండి.'),
    ]),
    _Lesson('At the Shop', Icons.shopping_bag_rounded, AppColors.accentOrange, [
      _Phrase('How much is this?', 'ఇది ఎంత?'),
      _Phrase('It is too expensive.', 'ఇది చాలా ఖరీదు.'),
      _Phrase('Can you give a discount?', 'మీరు తగ్గింపు ఇవ్వగలరా?'),
      _Phrase('I want to buy this.', 'నేను దీన్ని కొనాలనుకుంటున్నాను.'),
      _Phrase('Please give me a bag.', 'దయచేసి నాకు ఒక సంచి ఇవ్వండి.'),
      _Phrase('Here is the money.', 'ఇదిగో డబ్బు.'),
    ]),
    _Lesson('Travel & Directions', Icons.directions_rounded, AppColors.primaryBlue, [
      _Phrase('Where is the bus stop?', 'బస్ స్టాప్ ఎక్కడ ఉంది?'),
      _Phrase('How far is it?', 'అది ఎంత దూరం?'),
      _Phrase('Go straight ahead.', 'నేరుగా ముందుకు వెళ్ళండి.'),
      _Phrase('Turn left at the corner.', 'మూల వద్ద ఎడమవైపు తిరగండి.'),
      _Phrase('Please stop here.', 'దయచేసి ఇక్కడ ఆపండి.'),
      _Phrase('I am lost.', 'నేను దారి తప్పాను.'),
    ]),
    _Lesson('Health & Emergencies', Icons.health_and_safety_rounded, AppColors.accentRed, [
      _Phrase('I am not feeling well.', 'నాకు ఒంట్లో బాగాలేదు.'),
      _Phrase('I have a headache.', 'నాకు తలనొప్పిగా ఉంది.'),
      _Phrase('Please call a doctor.', 'దయచేసి ఒక డాక్టర్‌ని పిలవండి.'),
      _Phrase('I need help.', 'నాకు సహాయం కావాలి.'),
      _Phrase('Where is the hospital?', 'ఆసుపత్రి ఎక్కడ ఉంది?'),
      _Phrase('Take care of yourself.', 'జాగ్రత్తగా ఉండండి.'),
    ]),
    _Lesson('Polite Expressions', Icons.volunteer_activism_rounded, AppColors.accentPurple, [
      _Phrase('Please.', 'దయచేసి.'),
      _Phrase('Thank you very much.', 'చాలా ధన్యవాదాలు.'),
      _Phrase('You are welcome.', 'మీకు స్వాగతం.'),
      _Phrase('I am sorry.', 'క్షమించండి.'),
      _Phrase('No problem.', 'ఏ సమస్య లేదు.'),
      _Phrase('Congratulations!', 'అభినందనలు!'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spoken English')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.record_voice_over_rounded,
                    color: Colors.white, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learn to Speak English',
                        style: AppTextStyles.titleLarge
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Daily phrases with Telugu meaning. Practice a little every day!',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._lessons.map((lesson) => _LessonSection(lesson: lesson)),
        ],
      ),
    );
  }
}

class _LessonSection extends StatelessWidget {
  final _Lesson lesson;

  const _LessonSection({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.gradientFor(lesson.color),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(lesson.icon, color: Colors.white),
            ),
            title: Text(lesson.title, style: AppTextStyles.titleMedium),
            subtitle: Text('${lesson.phrases.length} phrases',
                style: AppTextStyles.labelMedium),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: lesson.phrases
                .map((p) => _PhraseTile(phrase: p, color: lesson.color))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _PhraseTile extends StatelessWidget {
  final _Phrase phrase;
  final Color color;

  const _PhraseTile({required this.phrase, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.volume_up_rounded, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(phrase.english, style: AppTextStyles.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(phrase.telugu, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}
