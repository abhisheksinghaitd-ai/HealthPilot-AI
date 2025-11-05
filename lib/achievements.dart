import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:pedometer/pedometer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Achievements Demo',
      theme: ThemeData.dark(),
      home:  AchievementsWidget(),
    );
  }
}



class AchievementsWidget extends StatefulWidget {
  AchievementsWidget({super.key});

 

  @override
  State<AchievementsWidget> createState() => _AchievementsWidgetState();
}
int rebootSteps = 0;

class _AchievementsWidgetState extends State<AchievementsWidget> {
  final achievementsBox = Hive.box('achievements');

@override
void initState() {
  super.initState();

  // Load saved unlocked achievements on app start
  for (var badge in _badges) {
    bool savedUnlocked = achievementsBox.get(badge['steps'].toString(), defaultValue: false);
    badge['unlocked'] = savedUnlocked;
  }

  listenStepsSinceReboot((steps) {
    setState(() {
      rebootSteps = steps;

      for (var badge in _badges) {
        if (rebootSteps >= badge['steps']) {
          badge['unlocked'] = true;

          // ✅ Save in Hive so reboot won't clear it
          achievementsBox.put(badge['steps'].toString(), true);
        }
      }
    });
  });
}


  StreamSubscription<StepCount>? _rebootStepSub;

int _stepsSinceReboot = 0;

/// 📌 Use this function to read steps since device reboot
void listenStepsSinceReboot(Function(int steps) onStepsUpdated) {
  _rebootStepSub?.cancel();

  _rebootStepSub = Pedometer.stepCountStream.listen((StepCount event) {
    _stepsSinceReboot = event.steps;
    onStepsUpdated(_stepsSinceReboot);
  }, onError: (error) {
    print("Reboot Step Error: $error");
  });
}

/// 📌 Getter to pull the latest value manually if needed
int getStepsSinceReboot() {
  return _stepsSinceReboot;
}



static final List<Map<String, dynamic>> _badges = [
  {'steps': 3000,  'title': 'Away From Sofa',     'unlocked': false},
  {'steps': 5000,  'title': 'Getting Stronger',   'unlocked': false},
  {'steps': 7000,  'title': 'On the Move',        'unlocked': false},
  {'steps': 10000, 'title': 'Step Master',        'unlocked': false},
  {'steps': 15000, 'title': 'Road Runner',        'unlocked': false},
  {'steps': 20000, 'title': 'Marathon Mindset',   'unlocked': false},
  {'steps': 30000, 'title': 'Legend Walker',      'unlocked': false},
  {'steps': 50000, 'title': 'Step King',          'unlocked': false},
  {'steps': 100000,'title': 'Ultimate Walker',    'unlocked': false},
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Achievements',
          style:
              GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
           
        
        Text('Current Level',style: GoogleFonts.poppins(color: Colors.grey[900],fontSize:12)),
        SizedBox(height: 10,),

         Row(
           children: [
             Text('On the Move',style: GoogleFonts.poppins(color: Colors.white,fontSize:18)),
             Spacer(),
             
           ],
         ),

           SizedBox(height: 8),
            // Grid of badges (3 columns)
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 18,
                childAspectRatio: 0.58, // tweak to get look similar to your design
                 children: _badges.map((b) {
  int steps = b['steps'] as int;
  String displaySteps = steps >= 1000 ? "${steps ~/ 1000}K" : "$steps";

  return StepsBadgeColumn(
    steps: displaySteps,
    title: b['title'] as String,
    unlocked: b['unlocked'] as bool,
  );
}).toList(),

              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small widget that composes the badge (rounded rectangle) + title below it
class StepsBadgeColumn extends StatelessWidget {
  final String steps;
  final String title;
  final bool unlocked;

  const StepsBadgeColumn({
    super.key,
    required this.steps,
    required this.title,
    this.unlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    // badge container itself
    Widget badge = _buildBadgeContainer();

    // if locked -> apply the same blur you used before
    if (!unlocked) {
      badge = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Opacity(opacity: 0.85, child: badge),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // make the badge fill the grid cell's width
        SizedBox(
          width: double.infinity,
          child: Center(child: SizedBox(width: 80, child: badge)),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // extracted builder for the badge visual
  Widget _buildBadgeContainer() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1C1C1E), // dark top
            Color(0xFF2E2E30), // slightly lighter bottom
          ],
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 4,
        ),
        boxShadow: [
          // subtle inner highlight (optional)
          BoxShadow(
            color: Colors.white.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, -2),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // stars row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Icon(Icons.star, color: Colors.white, size: 14),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // big steps text
          Text(
            steps,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // small 'STEPS' text
          Text(
            'STEPS',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
