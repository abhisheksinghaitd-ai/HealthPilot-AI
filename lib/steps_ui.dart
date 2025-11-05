import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lifestyle_companion/groq_service.dart';
import 'package:lottie/lottie.dart';


class StepsWidget extends StatefulWidget {
  const StepsWidget({super.key});

  @override
  State<StepsWidget> createState() => _StepsWidgetState();
}

class _StepsWidgetState extends State<StepsWidget> with SingleTickerProviderStateMixin {
  final Box stepsBox = Hive.box('LiveSteps');

  String _response = 'Loading response...';
  bool _isLoading = false;
  String ques = "hi";

    late AnimationController _controller;
  late Animation<double> _animation;

   Future<void> _getResponse() async {
    try {
          final int totalSteps = stepsBox.get('live', defaultValue: 0) as int;

         
if (totalSteps < 2000) {
  ques = """
User walked $totalSteps steps. Provide professional, concise feedback in a single paragraph with 3-4 sentences, each under 25 words. Focus on actionable tips to improve step count. Do not use bullets, emojis, highlights, introductions, or extra text.
""";
} else if (totalSteps >= 2000 && totalSteps < 5000) {
  ques = """
User walked $totalSteps steps. Provide professional motivational feedback in 3-4 sentences, each under 25 words. Focus on encouraging more walking. Do not use bullets, emojis, highlights, introductions, or extra text.
""";
} else if (totalSteps >= 5000 && totalSteps < 10000) {
  ques = """
User walked $totalSteps steps. Provide professional praise and actionable feedback in 3-4 sentences, each under 25 words. Focus on reaching the daily goal. Do not use bullets, emojis, highlights, introductions, or extra text.
""";
} else if (totalSteps >= 10000 && totalSteps < 15000) {
  ques = """
User walked $totalSteps steps. Provide professional congratulatory feedback in 3-4 sentences, each under 25 words. Focus on maintaining or improving performance. Do not use bullets, emojis, highlights, introductions, or extra text.
""";
} else {
  ques = """
User walked $totalSteps steps. Provide professional celebratory feedback in 3-4 sentences, each under 25 words. Focus on sustaining outstanding achievement. Do not use bullets, emojis, highlights, introductions, or extra text.
""";
}



      final reply = await GroqService.askGroq(
        ques,
      );
      setState(() => _response = reply);
    } catch (e) {
      setState(() => _response = 'Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getResponse();

    _controller = AnimationController(
      vsync:  this,
      duration: const Duration(seconds: 2),


    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
  }
Widget geminiAiLogo({double size = 40}) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.95, end: 1.05),
    duration: const Duration(seconds: 2),
    curve: Curves.easeInOut,
    builder: (context, scale, child) {
      return Transform.scale(
        scale: scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow circle
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Inner layered shape
            Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withOpacity(0.4),
                    Colors.deepPurple.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // AI text in minimal futuristic style
            Text(
              "AI",
              style: TextStyle(
                color: Colors.purple.shade100.withOpacity(0.9),
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      );
    },
  );
}

  



  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.white),
        title: Text(
          'Steps Analysis',
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: stepsBox.listenable(),
        builder: (context, Box box, _) {
          final int totalSteps = box.get('live', defaultValue: 0) as int;

      
          // Approx calories (0.04 per step) and time estimate
          final double calories = totalSteps * 0.04;
          final double walkTimeMinutes = totalSteps / 100; // rough 100 steps/min

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Current Steps Card
                Card(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(FontAwesomeIcons.shoePrints,
                            color: Colors.blue, size: 32),
                        const SizedBox(height: 10),
                        Text(
                          '$totalSteps',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total Steps Today',
                          style: GoogleFonts.poppins(
                              color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text('${calories.toStringAsFixed(1)} kcal',
                                    style: GoogleFonts.poppins(
                                        color: Colors.orangeAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Text('Calories Burned',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                            Column(
                              children: [
                                Text('${walkTimeMinutes.toStringAsFixed(0)} min',
                                    style: GoogleFonts.poppins(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Text('Walking Time',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Detailed Feedback Card
                Card(
                  color: Colors.black,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: 
                   
                  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Row(
  children: [
    const Icon(FontAwesomeIcons.chartLine, color: Colors.blueAccent),
    const SizedBox(width: 10),
    Text(
      'Step Analysis',
      style: GoogleFonts.poppins(
        color: Colors.blueAccent,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(width: 10),

 
       Lottie.network(
          'https://drive.google.com/uc?export=download&id=1zTkb7djw3YYQhDKMH0rV7g2wZ7sTNBXw',
          width: 50,
          height: 50,
          fit: BoxFit.fill,
        ),
  ],
),


    const SizedBox(height: 10), // spacing between header and response

    // Response section
    if (_response != null && _response.isNotEmpty)
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _response,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
  ],
)

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
