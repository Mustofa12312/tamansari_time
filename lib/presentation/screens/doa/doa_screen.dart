import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_strings.dart';
import 'package:flutter/services.dart';

class DoaScreen extends StatefulWidget {
  const DoaScreen({super.key});

  @override
  State<DoaScreen> createState() => _DoaScreenState();
}

class _DoaScreenState extends State<DoaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "Semua";

  final List<String> _categories = [
    "Semua",
    "Harian",
    "Shalat",
    "Bepergian",
    "Perlindungan",
  ];

  final List<Map<String, String>> _allDoas = const [
    {
      'title': 'Doa Sebelum Makan',
      'category': 'Harian',
      'arabic': 'بِسْمِ اللَّهِ',
      'latin': 'Bismillah',
      'translation': 'Dengan menyebut nama Allah',
    },
    {
      'title': 'Doa Sesudah Makan',
      'category': 'Harian',
      'arabic':
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
      'latin':
          'Alhamdulillahilladzi ath\'amana wa saqona wa ja\'alana muslimin',
      'translation':
          'Segala puji bagi Allah yang memberi kami makan dan minum serta menjadikan kami orang-orang muslim',
    },
    {
      'title': 'Doa Sebelum Tidur',
      'category': 'Harian',
      'arabic': 'بِسْمِكَ اللَّهُمَّ أَحْيَا وَأَمُوتُ',
      'latin': 'Bismikallahumma ahya wa amutu',
      'translation': 'Dengan nama-Mu Ya Allah aku hidup dan mati',
    },
    {
      'title': 'Doa Bangun Tidur',
      'category': 'Harian',
      'arabic':
          'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      'latin':
          'Alhamdulillahilladzi ahyana ba\'da ma amatana wa ilaihin nusyur',
      'translation':
          'Segala puji bagi Allah yang telah menghidupkan kami setelah kami mati (tidur) dan hanya kepada-Nya kami dikembalikan',
    },
    {
      'title': 'Doa Masuk Masjid',
      'category': 'Shalat',
      'arabic': 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      'latin': 'Allahummaftahli abwaba rahmatik',
      'translation': 'Ya Allah, bukakanlah bagiku pintu-pintu rahmat-Mu',
    },
    {
      'title': 'Doa Keluar Masjid',
      'category': 'Shalat',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      'latin': 'Allahumma inni as-aluka min fadlik',
      'translation': 'Ya Allah, sesungguhnya aku memohon keutamaan dari-Mu',
    },
    {
      'title': 'Doa Naik Kendaraan',
      'category': 'Bepergian',
      'arabic':
          'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
      'latin':
          'Subhanalladzi sakhkhara lana hadza wa ma kunna lahu muqrinin wa inna ila rabbina lamunqalibun',
      'translation':
          'Maha Suci Allah yang telah menundukkan semua ini bagi kami padahal kami sebelumnya tidak mampu menguasainya, dan sesungguhnya kami akan kembali kepada Tuhan kami',
    },
    {
      'title': 'Doa Sapu Jagad',
      'category': 'Perlindungan',
      'arabic':
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      'latin':
          'Rabbana atina fiddunya hasanah wa fil akhirati hasanah wa qina adzaban nar',
      'translation':
          'Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat dan peliharalah kami dari siksa neraka',
    },
  ];

  List<Map<String, String>> get _filteredDoas {
    return _allDoas.where((doa) {
      final matchesSearch = doa['title']!.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == "Semua" || doa['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildCategoryList()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildDoaCard(_filteredDoas[index]),
                childCount: _filteredDoas.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned(
              bottom: -20,
              right: -20,
              child: Icon(
                Icons.menu_book_rounded,
                size: 150,
                color: AppColors.textPrimary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        title: Text(
          AppStrings.navDoa,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.textPrimary.withValues(alpha: 0.1),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Cari doa...',
                hintStyle: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.5),
                ),
                icon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedCategory = cat);
                }
              },
              selectedColor: AppColors.textPrimary.withValues(alpha: 0.2),
              backgroundColor: AppColors.textPrimary.withValues(alpha: 0.1),
              labelStyle: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.textPrimary.withValues(alpha: 0.5)
                    : AppColors.textPrimary.withValues(alpha: 0.1),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoaCard(Map<String, String> doa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  doa['category']!,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  size: 20,
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                ),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text:
                          "${doa['arabic']}\n${doa['latin']}\n${doa['translation']}",
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Doa disalin ke clipboard'),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            doa['title']!,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            doa['arabic']!,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'Amiri',
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            doa['latin']!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              doa['translation']!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
