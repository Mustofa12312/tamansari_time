import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_strings.dart';

class DoaScreen extends StatelessWidget {
  const DoaScreen({super.key});

  final List<Map<String, String>> _doas = const [
    {
      'title': 'Doa Sebelum Makan',
      'arabic': 'بِسْمِ اللَّهِ',
      'latin': 'Bismillah',
      'translation': 'Dengan menyebut nama Allah',
    },
    {
      'title': 'Doa Sesudah Makan',
      'arabic':
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
      'latin':
          'Alhamdulillahilladzi ath\'amana wa saqona wa ja\'alana muslimin',
      'translation':
          'Segala puji bagi Allah yang memberi kami makan dan minum serta menjadikan kami orang-orang muslim',
    },
    {
      'title': 'Doa Sebelum Tidur',
      'arabic': 'بِسْمِكَ اللَّهُمَّ أَحْيَا وَأَمُوتُ',
      'latin': 'Bismikallahumma ahya wa amutu',
      'translation': 'Dengan nama-Mu Ya Allah aku hidup dan mati',
    },
    {
      'title': 'Doa Bangun Tidur',
      'arabic':
          'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      'latin':
          'Alhamdulillahilladzi ahyana ba\'da ma amatana wa ilaihin nusyur',
      'translation':
          'Segala puji bagi Allah yang telah menghidupkan kami setelah kami mati (tidur) dan hanya kepada-Nya kami dikembalikan',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(AppStrings.navDoa, style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _doas.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doa = _doas[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doa['title']!,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    doa['arabic']!,
                    style: AppTypography.headlineSmall,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  doa['latin']!,
                  style: AppTypography.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(doa['translation']!, style: AppTypography.bodySmall),
              ],
            ),
          );
        },
      ),
    );
  }
}
