import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// Note: Ensure you have added these dependencies to your pubspec.yaml
// google_fonts, url_launcher, cloud_firestore, firebase_core, intl

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HostelApp());
}

// Main App Widget
class HostelApp extends StatelessWidget {
  const HostelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return MaterialApp(
      title: 'AroundFAST',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        textTheme: textTheme,
      ),
      home: const CampusSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- App-wide Constants ---
class AppColors {
  static const Color background = Color(0xFF1A1A1A);
  static const Color card = Color(0xFF252525);
  static const Color accent = Color(0xFF38B6FF);
  static const Color textPrimary = Color(0xFFEAEAEA);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF6E6E6E);
  static const Color border = Color(0xFF333333);
  static const Color success = Color(0xFF2ECC71);
}

// -----------------------------------------------------------------
// Campus Selection Screen
// -----------------------------------------------------------------

class CampusSelectionScreen extends StatefulWidget {
  const CampusSelectionScreen({super.key});

  @override
  State<CampusSelectionScreen> createState() => _CampusSelectionScreenState();
}

class _CampusSelectionScreenState extends State<CampusSelectionScreen> {
  // **FIXED**: Corrected the syntax error in the list.
  static const List<Map<String, dynamic>> campuses = [
    {'name': 'FAST Lahore', 'icon': Icons.fort_outlined},
    {'name': 'FAST Peshawar', 'icon': Icons.location_city_outlined},
    {'name': 'FAST Islamabad', 'icon': Icons.mosque_outlined},
    {
      'name': 'FAST Faisalabad',
      'icon': Icons.corporate_fare, // Corrected: Removed stray quote
      'note':
      'FAST Faisalabad has its own internal hostel facilities. Please refer to the official website for more information.'
    },
    {'name': 'FAST Karachi', 'icon': Icons.waves_outlined},
    {
      'name': 'FAST Multan',
      'icon': Icons.business_outlined,
      'note':
      'FAST Multan provides internal hostel accommodations. Kindly check the official website for accurate details.'
    },
  ];

  static const List<int> cityIndexMapping = [3, 2, 0, -1, 1, -1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.background, Color(0xFF1E1E1E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Text('AroundFast',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('Select Your Campus',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: -0.5)),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final campus = campuses[index];
                  final cityIndex = cityIndexMapping[index];
                  final isEnabled = cityIndex != -1;

                  return CampusCard(
                    campusName: campus['name'],
                    icon: campus['icon'],
                    isEnabled: isEnabled,
                    onTap: () {
                      if (isEnabled) {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => HostelHomePage(
                                cityName: _getCityNameFromIndex(cityIndex))));
                      } else {
                        final note = campus['note'] ??
                            'Data for this campus is not available yet.';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(note,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                    color: AppColors.textPrimary)),
                            backgroundColor: AppColors.card,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  );
                },
                childCount: campuses.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCityNameFromIndex(int index) {
    const cities = ['Islamabad', 'Karachi', 'Peshawar', 'Lahore'];
    return cities[index];
  }
}

class CampusCard extends StatefulWidget {
  final String campusName;
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const CampusCard(
      {super.key,
        required this.campusName,
        required this.icon,
        required this.isEnabled,
        required this.onTap});

  @override
  State<CampusCard> createState() => _CampusCardState();
}

class _CampusCardState extends State<CampusCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        if (widget.isEnabled) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.isEnabled) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (widget.isEnabled) setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  AppColors.accent.withOpacity(0.1),
                  AppColors.card.withOpacity(0.1)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  size: 48,
                  color:
                  widget.isEnabled ? AppColors.accent : AppColors.textDisabled),
              const SizedBox(height: 16),
              Text(
                widget.campusName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.isEnabled
                        ? AppColors.textPrimary
                        : AppColors.textDisabled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// Hostel Home Page - NOW WITH DYNAMIC RATINGS
// -----------------------------------------------------------------

class HostelHomePage extends StatefulWidget {
  final String cityName;
  const HostelHomePage({super.key, required this.cityName});

  @override
  State<HostelHomePage> createState() => _HostelHomePageState();
}

class _HostelHomePageState extends State<HostelHomePage> {
  String _gender = 'girls';
  Stream<Map<String, double>>? _ratingsStream;

  static const Map<String, Map<String, List<Map<String, String>>>> _data = {
    'Islamabad': {
      'girls': [
        {
          'name': 'Neena girls hostel',
          'location': 'I10-2',
          'distance': '5-10 min',
          'rent': 'Rs.18-22k',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry',
          'rating': '4',
          'contact': '03335223673',
          'notes': 'Walking distance sometimes.'
        },
        {
          'name': 'Elysian girls hostel',
          'location': 'I-10/2',
          'distance': 'Walking',
          'rent': 'Rs.15-18k',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry, transport',
          'rating': '1',
          'contact': '+92 333 5223673',
          'notes': 'Its amazing hostel'
        },
        {
          'name': 'AK Girls hostel',
          'location': 'I11',
          'distance': '5-10 min',
          'rent': 'Rs.18-22k',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry, transport',
          'rating': '3',
          'contact': '',
          'notes': ''
        },
        {
          'name': 'AFNS hostel PAF Base',
          'location': 'Air HQ E-9',
          'distance': '10-20 min',
          'rent': 'Under Rs.15k',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry',
          'rating': '5',
          'contact': '',
          'notes': ''
        },
        {
          'name': 'Girls Residency',
          'location': 'G10/2 St16 House330F',
          'distance': '10-20 min',
          'rent': 'Rs.22k+',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry, transport',
          'rating': '5',
          'contact': '+92 348 5497805',
          'notes': ''
        },
        {
          'name': 'Islamia Girls Hostel',
          'location': 'H-11/4 back of Barq Pharmacy',
          'distance': 'Walking',
          'rent': 'Rs.22k+',
          'facilities': 'Meals, cleaning, Wi-Fi',
          'rating': '4',
          'contact': '+92 312 5332647',
          'notes': 'Rooms from 2-6 seaters'
        },
        {
          'name': 'Student girls hostel G10',
          'location': 'G10/2 House330F',
          'distance': '10-20 min',
          'rent': 'Rs.22k+',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry, transport',
          'rating': '5',
          'contact': '',
          'notes': 'Im shifting there'
        },
        {
          'name': 'Ss girls hostel',
          'location': 'G13/4 St142 House21',
          'distance': '10-20 min',
          'rent': 'Rs.22k+',
          'facilities': 'Meals, cleaning, Wi-Fi',
          'rating': '5',
          'contact': '03332686070',
          'notes': ''
        },
      ],
      'boys': [
        {
          'name': 'Student Shelter Boys Hostel',
          'location': 'House12, Service Road North, I-11/2',
          'distance': '5-10 min',
          'rent': 'Rs.18-22k',
          'facilities': 'Meals, cleaning, Wi-Fi',
          'rating': '4',
          'contact': ''
        },
        {
          'name': 'Munawar boys hostel',
          'location': 'G-12/1 near SLS school',
          'distance': '10-20 min',
          'rent': 'Rs.15-18k',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry',
          'rating': '4',
          'contact': 'Not available'
        },
        {
          'name': 'Elysian girls hostel (boys section)',
          'location': 'I-10/2',
          'distance': 'Walking',
          'rent': 'Rs.15-18k',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry, transport',
          'rating': '1',
          'contact': '+92 333 5223673'
        },
        {
          'name': 'Shibli boys hostel',
          'location': 'G-12 front of NUST Metro',
          'distance': '5-10 min',
          'rent': 'Rs.18-22k',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry',
          'rating': '3',
          'contact': '03104716447'
        },
        {
          'name': 'I-11 Boys Hostel',
          'location': 'House1550 St7 Near Inayat Market',
          'distance': '5-10 min',
          'rent': 'Rs.18-22k',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry',
          'rating': '4',
          'contact': '0300-6070921'
        },
        {
          'name': 'Professional Lodges',
          'location': 'G-10/1 Sawan Road',
          'distance': '5-10 min',
          'rent': 'Rs.22k+',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry',
          'rating': '3',
          'contact': '+92 301 5614493',
          'notes': 'Food quality varied'
        },
        {
          'name': 'Live with Style boys hostel',
          'location': 'G-12 service Road near signal',
          'distance': '10-20 min',
          'rent': 'Rs.18-22k',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry',
          'rating': '4',
          'contact': '',
          'notes': 'Geyser charge, meals just okay'
        },
        {
          'name': 'Al-Ghazali boys hostel G-11',
          'location': 'G-11/2 Ibn-e-Sina Rd',
          'distance': '10-20 min',
          'rent': 'Rs.18-22k',
          'facilities': 'Meals, cleaning, Wi-Fi',
          'rating': '2',
          'contact': ''
        },
        {
          'name': 'Personal flat',
          'location': 'I-11/2 St8',
          'distance': '5-10 min',
          'rent': 'Under Rs.15k',
          'facilities': 'Cleaning, Wi-Fi, laundry',
          'rating': '5',
          'contact': '+44 7476 440581',
          'notes': 'Only FASTians'
        },
        {
          'name': 'Shandoor Boys Hostel',
          'location': 'G-12/1',
          'distance': '5-10 min',
          'rent': 'Rs.15-18k',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry',
          'rating': '2',
          'contact': ''
        },
        {
          'name': 'Shaheen Boys Hostel G-11',
          'location': 'Police signal G-11',
          'distance': '5-10 min',
          'rent': 'Rs.22k+',
          'facilities': 'Meals, cleaning, Wi-Fi, laundry',
          'rating': '4',
          'contact': '',
          'notes': 'Near police signal'
        },
      ],
    },
    'Karachi': {
      'girls': [
        {
          'name': 'Girls Hostel near FAST',
          'rent': '22k-90k',
          'facilities': 'AC, Wi-Fi, meals, CCTV, laundry',
          'contact': '0321 4448228',
        },
        {
          'name': 'United Girls Hostel',
          'rent': '12k-35k',
          'facilities': 'Mess, AC, Wi-Fi, laundry',
          'contact': '0315 2470554',
        },
        {
          'name': 'The Paradise Girls Hostel',
          'rent': '~19k',
          'facilities': '3 meals, AC, CCTV, secure',
          'contact': '0333 5558877',
        },
        {
          'name': 'QaimKhani / Lodge Girls Hostel',
          'rent': '10k-15k',
          'facilities': 'AC, mess, attach/shared bath',
          'contact': '0300 5559988',
        },
        {
          'name': 'Jaiden Girls Hostel',
          'rent': '~10k',
          'facilities': '3-time mess, furnished',
          'contact': '0312 6667788',
        },
        {
          'name': 'The Nations Girls Hostel',
          'rent': '10k-15k',
          'facilities': 'Dorm-style, optional mess',
          'contact': '0300 8312761',
        },
      ],
      'boys': [
        {
          'name': 'United Boys Hostel (Waze)',
          'rent': 'Not listed',
          'facilities': 'Secure, common hostel',
          'contact': '0300 2001190',
        },
        {
          'name': 'Stargate Boys Hostel',
          'rent': '10k',
          'facilities': 'Mess, Wi-Fi, kitchen, parking',
          'contact': '0302 1234567',
        },
        {
          'name': 'SBN Boys Hostel',
          'rent': '11-15k',
          'facilities': 'Meals, laundry, Wi-Fi, parking',
          'contact': '0300 0926535 / 0304 1027977',
        },
        {
          'name': 'H.Y Boys Hostel',
          'rent': '10k',
          'facilities': 'Attach baths, Wi-Fi, CCTV, solar',
          'contact': '0312 9876543',
        },
        {
          'name': 'Friends Boys Hostel',
          'rent': '7-9k',
          'facilities': 'Furnished, attach bath, Wi-Fi',
          'contact': '0346 9766751',
        },
        {
          'name': 'Ibrahim Hostel (I-11)',
          'rent': '10-15k',
          'facilities': 'Cameras, laundry, water dispenser',
          'contact': 'via FAST groups',
        },
      ],
    },
    'Peshawar': {
      'girls': [
        {
          'name': 'National Hostel',
          'rent': '9500 + 4500 food + 5000 security',
          'facilities': 'Sector K1, Phase 3, Hayatabad',
          'contact': '0315-9444850',
        },
        {
          'name': 'Angels Hostel',
          'rent': '13k + 4k food + 8k security',
          'facilities': 'Sector J5, Phase 2, Hayatabad',
          'contact': '0336-6263710',
        },
        {
          'name': 'Hayatabad Hostel',
          'rent': '13k + 10k food + 10k security',
          'facilities': 'Sector H3, Phase 2, Hayatabad',
          'contact': '0334-9360636',
        },
        {
          'name': 'Bint-e-Hawa Hostel',
          'rent': 'N/A',
          'facilities': 'Phase 3, Hayatabad',
          'contact': '0335-9108330',
        },
        {
          'name': 'Ample Girls Hostel',
          'rent': '20k + 20k security',
          'facilities': 'Sector L1, Phase 3, Hayatabad',
          'contact': '0333-5962704',
        },
        {
          'name': 'National Hostel-2',
          'rent': '9500 + 4500 food + 2000 security',
          'facilities': 'Sector K1, Phase 3, Hayatabad',
          'contact': '0315-9444850',
        },
        {
          'name': 'National Hostel-3',
          'rent': '9500 + 4500 food + 2000 security',
          'facilities': 'Sector K2, Phase 3, Hayatabad',
          'contact': '0340-9110435',
        },
      ],
      'boys': [
        {
          'name': 'Punjab Hostel',
          'rent': '11k + 8k food + 10k security',
          'facilities': 'Sector G7, Phase 3, Hayatabad',
          'contact': '0340-9110435',
        },
        {
          'name': 'Army Hostel',
          'rent': '20k + 15k food + 10k security',
          'facilities': 'Sector H5, Phase 2, Hayatabad',
          'contact': '0334-1234567',
        },
        {
          'name': 'Youth Hostel',
          'rent': '15k + 10k food + 10k security',
          'facilities': 'Sector J4, Phase 2, Hayatabad',
          'contact': '0321-6549873',
        },
        {
          'name': 'Green Hostel',
          'rent': '9.5k + 7k food',
          'facilities': 'H128, Street 6A, Sector N4, Phase 4, Hayatabad',
          'contact': '0320-0298888, 0333-9313413',
        },
        {
          'name': 'National Hostel boys',
          'rent': '9.5k + 4.5k food + 5k security',
          'facilities': 'H23, Street 2, Sector J1, Phase 2, Hayatabad',
          'contact': '0332-9009916, 0316-1250692',
        },
        {
          'name': 'Durrani Hostel',
          'rent': '7k + 2k security',
          'facilities': 'Durrani paints industrial state, Peshawar',
          'contact': '0332-5988665',
        },
        {
          'name': 'Awais Hostel',
          'rent': '7.5k + 4.5k food + 5k security',
          'facilities': 'Achini chowk, Ring road Peshawar, opp rahat bakers',
          'contact': '0300-5894505, 0310-7617909',
        },
        {
          'name': 'Ajmal Hostel',
          'rent': '7k + 3k security',
          'facilities': '165, Industrial Estate, Peshawar',
          'contact': '0304-9014249',
        },
        {
          'name': 'Student House Hostel',
          'rent': '8k + 7k food + 1k security',
          'facilities': 'Lalazar Market, phase 1, Peshawar',
          'contact': '0312-9485078, 0306-8559006',
        },
        {
          'name': 'Space Hostel',
          'rent': '9.5k + 7k food',
          'facilities': 'Zamzama Tower, Karkhano market, Peshawar',
          'contact': '0320-0298888',
        },
      ],
    },
    'Lahore': {
      'girls': [
        {
          'company': 'Executive group of Hostels',
          'name': 'Faisal Town girls hostels',
          'rent': '11k to 15k, 3k to 5k security, 7k food',
          'facilities':
          'Air conditioned rooms, high speed internet, Parking, gaming zone and much more',
          'contact': '0336-7449182, 0300-7449182',
          'location': 'Plot 268, House # 85A'
        },
        {
          'company': 'Executive group of Hostels',
          'name': 'Model Town girls hostels',
          'rent': '11k to 15k, 3k to 5k security, 7k food',
          'facilities':
          'Air conditioned rooms, high speed internet, Parking, gaming zone and much more',
          'contact': '0336-7449182, 0300-7449182',
          'location': 'Plot 478, House # 478M',
        },
      ],
      'boys': [
        {
          'company': 'Executive group of Hostels',
          'name': 'Faisal Town boys hostel',
          'rent': '11k to 15k, 3k to 5k security, 7k food',
          'facilities':
          'Air conditioned rooms, high speed internet, Parking, gaming zone and much more',
          'contact': '0336-7449182, 0300-7449182',
          'location': 'Plot 385, House # 385B'
        },
        {
          'company': 'Executive group of Hostels',
          'name': 'Faisal Town boys hostel 2',
          'rent': '11k to 15k, 3k to 5k security, 7k food',
          'facilities':
          'Air conditioned rooms, high speed internet, Parking, gaming zone and much more',
          'contact': '0336-7449182, 0300-7449182',
          'location': 'Plot 557, House # 557A'
        },
        {
          'company': 'Executive group of Hostels',
          'name': 'Model Town boys hostel',
          'rent': '11k to 15k, 3k to 5k security, 7k food',
          'facilities':
          'Air conditioned rooms, high speed internet, Parking, gaming zone and much more',
          'contact': '0336-7449182, 0300-7449182',
          'location': 'Plot 545, House # 545A'
        },
        {
          'company': 'Executive group of Hostels',
          'name': 'Model Town boys hostel 2',
          'rent': '11k to 15k, 3k to 5k security, 7k food',
          'facilities':
          'Air conditioned rooms, high speed internet, Parking, gaming zone and much more',
          'contact': '0336-7449182, 0300-7449182',
          'location': 'Plot 279, House # 279M'
        },
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _setupRatingsStream();
  }

  void _setupRatingsStream() {
    final hostelIdsForCity = (_data[widget.cityName]?[_gender] ?? [])
        .map((hostel) => _generateHostelId(hostel))
        .toList();

    if (hostelIdsForCity.isEmpty) {
      setState(() => _ratingsStream = Stream.value({}));
      return;
    }

    final stream = FirebaseFirestore.instance
        .collection('reviews')
        .where('hostelId', whereIn: hostelIdsForCity)
        .snapshots()
        .map((snapshot) {
      final ratings = <String, List<int>>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final hostelId = data['hostelId'] as String;
        final rating = data['rating'] as int;
        if (ratings.containsKey(hostelId)) {
          ratings[hostelId]!.add(rating);
        } else {
          ratings[hostelId] = [rating];
        }
      }

      final averages = <String, double>{};
      ratings.forEach((hostelId, ratingList) {
        if (ratingList.isNotEmpty) {
          averages[hostelId] =
              ratingList.reduce((a, b) => a + b) / ratingList.length;
        }
      });
      return averages;
    });

    setState(() {
      _ratingsStream = stream;
    });
  }

  String _generateHostelId(Map<String, String> hostelData) {
    final name = hostelData['name'] ?? 'unknown';
    final location = hostelData['location'] ?? '';
    return '${widget.cityName}-$name-$location'
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final hostels = _data[widget.cityName]?[_gender] ?? [];
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cityName} Hostels'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'girls',
                    label: Text('Girls'),
                    icon: Icon(Icons.girl_outlined)),
                ButtonSegment(
                    value: 'boys',
                    label: Text('Boys'),
                    icon: Icon(Icons.boy_outlined)),
              ],
              selected: {_gender},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _gender = newSelection.first;
                  _setupRatingsStream();
                });
                HapticFeedback.lightImpact();
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: AppColors.card,
                foregroundColor: AppColors.textSecondary,
                selectedForegroundColor: AppColors.background,
                selectedBackgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<Map<String, double>>(
              stream: _ratingsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final averageRatings = snapshot.data ?? {};

                return hostels.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 64, color: AppColors.textDisabled),
                      const SizedBox(height: 16),
                      Text('No hostels found',
                          style: textTheme.headlineSmall
                              ?.copyWith(color: AppColors.textDisabled)),
                      const SizedBox(height: 8),
                      Text('Check back later for updates.',
                          style: textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textDisabled)),
                    ],
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: hostels.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final hostel = hostels[index];
                    final hostelId = _generateHostelId(hostel);
                    final avgRating = averageRatings[hostelId];

                    return HostelCard(
                      hostel: hostel,
                      averageRating: avgRating,
                      hostelId: hostelId,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// Hostel Card Widget
// -----------------------------------------------------------------

class HostelCard extends StatelessWidget {
  final Map<String, String> hostel;
  final String hostelId;
  final double? averageRating;

  const HostelCard({
    super.key,
    required this.hostel,
    required this.hostelId,
    this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final facilities = (hostel['facilities'] ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HostelDetailScreen(
              hostel: hostel,
              hostelId: hostelId,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hostel['name'] ?? 'Unknown Hostel',
                          style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      if (hostel.containsKey('company') &&
                          hostel['company']!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(hostel['company']!,
                            style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
                ),
                if (averageRating != null && averageRating! > 0) ...[
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        averageRating!.toStringAsFixed(1),
                        style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ],
                  ),
                ]
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),
            if (hostel.containsKey('location') &&
                hostel['location']!.isNotEmpty)
              _buildInfoRow(
                  textTheme, Icons.location_on_outlined, hostel['location']!),
            if (hostel.containsKey('distance') &&
                hostel['distance']!.isNotEmpty)
              _buildInfoRow(
                  textTheme, Icons.directions_walk_rounded, hostel['distance']!),
            if (hostel.containsKey('rent') && hostel['rent']!.isNotEmpty)
              _buildInfoRow(textTheme, Icons.wallet_outlined, hostel['rent']!),
            if (facilities.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                  facilities.map((facility) => TagChip(label: facility)).toList()),
            ],
            if (hostel.containsKey('notes') && hostel['notes']!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(hostel['notes']!,
                            style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary, height: 1.4))),
                  ],
                ),
              ),
            ],
            if (hostel.containsKey('contact') &&
                hostel['contact']!.isNotEmpty &&
                hostel['contact']!.toLowerCase() != 'not available') ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchPhone(hostel['contact']!),
                  icon: const Icon(Icons.phone_forwarded_rounded),
                  label: Text('Contact: ${hostel['contact']}'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.background,
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    textStyle: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rate_review_outlined,
                    color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 8),
                Text("Tap to see details and reviews",
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(TextTheme theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
              child: Text(text,
                  style: theme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _launchPhone(String phoneNumber) async {
    final sanitizedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: sanitizedNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      debugPrint("Failed to launch phone dialer: $e");
    }
  }
}

class TagChip extends StatelessWidget {
  final String label;
  const TagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.accent.withOpacity(0.3))),
      child: Text(label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.accent, fontWeight: FontWeight.w600)),
    );
  }
}

// -----------------------------------------------------------------
// Hostel Detail Screen
// -----------------------------------------------------------------

class HostelDetailScreen extends StatefulWidget {
  final Map<String, String> hostel;
  final String hostelId;

  const HostelDetailScreen(
      {super.key, required this.hostel, required this.hostelId});

  @override
  State<HostelDetailScreen> createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends State<HostelDetailScreen> {
  void _showAddReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: AddReviewForm(hostelId: widget.hostelId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.hostel['name'] ?? 'Hostel Details')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReviewSheet,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text("Add Review"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Text("User Reviews",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('hostelId', isEqualTo: widget.hostelId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.no_accounts_outlined,
                            size: 60, color: AppColors.textDisabled),
                        const SizedBox(height: 16),
                        Text("No reviews yet",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text("Be the first to add one!",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textDisabled)),
                      ],
                    ),
                  );
                }
                final reviews = snapshot.data!.docs;
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final reviewData =
                    reviews[index].data() as Map<String, dynamic>;
                    return ReviewCard(reviewData: reviewData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// Review Card & Add Review Form
// -----------------------------------------------------------------

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> reviewData;
  const ReviewCard({super.key, required this.reviewData});

  @override
  Widget build(BuildContext context) {
    final int rating = reviewData['rating'] ?? 0;
    final String reviewText =
        reviewData['reviewText'] ?? 'No comment provided.';
    final String userName = reviewData['userName'] ?? 'Anonymous';
    final String userAvatarText = reviewData['userAvatarText'] ?? '?';
    final Timestamp? timestamp = reviewData['timestamp'];
    String formattedDate = 'Just now';
    if (timestamp != null) {
      formattedDate = DateFormat.yMMMMd().format(timestamp.toDate());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  child: Text(userAvatarText,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(userName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary))),
              Row(
                  children: List.generate(
                      5,
                          (index) => Icon(
                          index < rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 20))),
            ],
          ),
          const SizedBox(height: 16),
          if (reviewText.isNotEmpty)
            Text(reviewText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary, height: 1.5)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Posted on: $formattedDate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ),
    );
  }
}

class AddReviewForm extends StatefulWidget {
  final String hostelId;
  const AddReviewForm({super.key, required this.hostelId});

  @override
  State<AddReviewForm> createState() => _AddReviewFormState();
}

class _AddReviewFormState extends State<AddReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  int _rating = 0;
  bool _isLoading = false;
  final List<String> _mockUserNames = [
    'Helpful Student',
    'FASTian Reviewer',
    'Senior Batchmate',
    'New Joinee',
    'Valuable Contributor',
    'Campus Explorer'
  ];

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a star rating.'),
          backgroundColor: Colors.redAccent));
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final randomUserName =
      _mockUserNames[Random().nextInt(_mockUserNames.length)];
      final userAvatarText =
      randomUserName.isNotEmpty ? randomUserName[0].toUpperCase() : '?';

      try {
        await FirebaseFirestore.instance.collection('reviews').add({
          'hostelId': widget.hostelId,
          'rating': _rating,
          'reviewText': _reviewController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'userName': randomUserName,
          'userAvatarText': userAvatarText,
        });
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Thank you for your review!'),
              backgroundColor: AppColors.success));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to submit review: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rate this hostel",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                        (index) => IconButton(
                        onPressed: () => setState(() => _rating = index + 1),
                        icon: Icon(
                            index < _rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 36)))),
            const SizedBox(height: 24),
            TextFormField(
              controller: _reviewController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: AppColors.accent, width: 2)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3))
                    : Text('Submit Review',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}