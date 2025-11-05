import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/fa6_solid.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:intl/intl.dart';
import 'package:lifestyle_companion/activities_idea.dart';
import 'package:lifestyle_companion/steps_ui.dart';
import 'package:lottie/lottie.dart';
import 'package:lifestyle_companion/achievements.dart';

/// ---------------- ✅ STEPS CARD ----------------
Widget stepWidget(
  BuildContext context,
  AnimationController controller,
  int totalSteps,
  bool pausePressed,
  VoidCallback onPauseToggle,
) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              StepsWidget(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    },
    child: Card(
      elevation: 8,
      color: const Color(0xFF1E1E1E),
      shadowColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Lottie.network(
                  'https://drive.google.com/uc?export=download&id=1HwHljZY88swuSyIhgHx2ytLbPMKllDAj',
                  width: 40,
                  height: 40,
                  fit: BoxFit.fill,
                ),
                SizedBox(width: 5),
                Text(
                  'Steps',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                buildLiveDot(controller),
                Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: totalSteps / 5000,
                        color: Colors.cyanAccent,
                        backgroundColor: const Color(0xFF2A2A2A),
                        strokeWidth: 10,
                      ),
                    ),
                    Text(
                      "${DateFormat('EEE').format(DateTime.now())}",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ],
            ),

            /// Steps Count
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(
                      sigmaX: pausePressed ? 3 : 0,
                      sigmaY: pausePressed ? 3 : 0),
                  child: Text(
                    "$totalSteps",
                    style: GoogleFonts.poppins(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),

                /// ✅ Pause toggle via callback
                IconButton(
                  onPressed: onPauseToggle,
                  icon: pausePressed
                      ? Icon(Icons.play_circle, color: Colors.white)
                      : Icon(Icons.pause, color: Colors.white),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.pending, color: Colors.white),
                ),
              ],
            ),

            Text(
              pausePressed ? "Paused" : "/6000",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: pausePressed ? Colors.deepOrange : Color(0xFFB0B0B0),
                fontWeight: FontWeight.bold,
              ),
            ),

            Row(
              children: [
                Spacer(),
                Text(
                  'Daily Average: 6234',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFFB0B0B0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// ---------------- ✅ ACHIEVEMENT HEADER ----------------
Widget achievementHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      children: [
        Lottie.network(
          'https://drive.google.com/uc?export=download&id=1qGQQ5RUwTfNGDWx6GnUoJuirG0YHLTu7',
          width: 50,
          height: 50,
        ),
        SizedBox(width: 5),
        Text(
          'Achievements',
          style: GoogleFonts.poppins(
            color: Color(0xFFE6BE8A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 800),
                pageBuilder: (context, a, b) => AchievementsWidget(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: animation.drive(
                        Tween(begin: Offset(1, 0), end: Offset.zero)),
                    child: child,
                  );
                },
              ),
            );
          },
          icon: Icon(Icons.arrow_forward_ios,
              size: 18, color: Color(0xFFB0BEC5)),
        ),
      ],
    ),
  );
}

/// ---------------- ✅ LIVE DOT ----------------
Widget buildLiveDot(AnimationController controller) {
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      double scale = 1 + (controller.value * 0.5);
      double blur = 4 + (controller.value * 0.5);

      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.redAccent,
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.8),
              blurRadius: blur,
              spreadRadius: 1,
            )
          ],
        ),
        transform: Matrix4.identity()..scale(scale),
      );
    },
  );
}

/// ---------------- ✅ SLEEP BUTTON ----------------
Widget buildSleepButton(
  IconData icon,
  String text,
  Color color,
  Color textColor,
  double size,
) {
  return ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.5)),
      ),
    ),
    icon: Icon(icon, color: Colors.white),
    onPressed: () {},
    label: Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: textColor,
        fontSize: size,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget sleepCard(int hour, int hour1, int hour2, int hour3, String bedtimeText, String wakeupText, String napText, String finalMinutes,String sleepResponse){
return Card(color: Colors.grey[900],

            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.bed, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        'Sleep Schedule',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                      Spacer(),
                      Icon(Icons.edit, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 13),
                  GridView.count(
                    padding: EdgeInsets.zero,
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3,
                    children: [
                      buildSleepButton(
                        Icons.bedtime,
                        hour >= 12
                            ? 'Bedtime $bedtimeText PM'
                            : 'Bedtime $bedtimeText AM',
                        Colors.grey[900]!,
                        Colors.white,
                        12,
                      ),
                      buildSleepButton(
                        Icons.bedtime_off,
                        hour1 >= 12
                            ? 'Wake-Up Time $wakeupText PM'
                            : 'Wake-Up Time $wakeupText AM',
                        Colors.grey[900]!,
                        Colors.white,
                        10,
                      ),
                      buildSleepButton(
                        Icons.bedtime_outlined,
                        'Nap Duration $napText hrs',
                        Colors.grey[900]!,
                        Colors.white,
                        10,
                      ),
                      buildSleepButton(
                        Icons.bed_rounded,
                        'Sleep Duration ${hour2 + hour3}h $finalMinutes',
                        Colors.grey[900]!,
                        Colors.white,
                        9,
                      ),
                    ],
                  ),

                  SizedBox(height: 10,),
                  Card(color: Colors.grey[900],elevation:8,child:
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,children:[
                        Row(
                          children: [
                            Text('AI Feedback',style: GoogleFonts.poppins(color: Colors.blueAccent,fontSize: 18,fontWeight: FontWeight.bold),),
                            SizedBox(width: 5,),
                             Lottie.network(
          'https://drive.google.com/uc?export=download&id=1zTkb7djw3YYQhDKMH0rV7g2wZ7sTNBXw',
          width: 50,
          height: 50,
          fit: BoxFit.fill,
        ),
                          ],
                        ),
                    SizedBox(height: 5,),
                    Text(sleepResponse,style: GoogleFonts.poppins(color: Colors.white,fontWeight: FontWeight.bold),)
                    ]),
                  ))
                 

                ],
              
                      
                  ),
            )
                );
}
Widget activitiesCard({
  required BuildContext context,
  required double Function(int) cpiValue,
}) {
  Widget activityItem(String kcal, IconData? icon, String iconifyName, double val) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: cpiValue(int.parse(kcal)),
              color: Colors.redAccent,
              backgroundColor: const Color(0xFF2A2A2A),
            ),
            icon != null
                ? Icon(icon, color: Colors.white, size: 28)
                : Iconify(iconifyName, color: Colors.white, size: 28),
          ],
        ),
        Text(
          '$kcal Kcal',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  return Card(
    elevation: 8,
    color: const Color(0xFF1E1E1E),
    shadowColor: Colors.grey[900],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          /// ------- Header -------
          Row(
            children: [
              Lottie.network(
                'https://drive.google.com/uc?export=download&id=1Et0tUBodBwXehGY91Y6yEOM9Y0U0v-eH',
                width: 50,
                height: 50,
              ),
              const SizedBox(width: 10),
              Text(
                'Activities',
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 800),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ActivitiesIdeaWidget(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0);
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(position: offsetAnimation, child: child);
                      },
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ------- Row 1 -------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              activityItem("220", null, Fa6Solid.dumbbell, 220),
              activityItem("600", null, Fa6Solid.person_running, 600),
              activityItem("500", null, Mdi.bicycle, 500),
              activityItem("500", null, Mdi.swim, 500),
            ],
          ),

          const SizedBox(height: 20),

          /// ------- Row 2 -------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              activityItem("700", null, Mdi.mixed_martial_arts, 700),
              activityItem("240", null, Mdi.yoga, 240),
              activityItem("550", null, Mdi.boxing_gloves, 550),
              activityItem("400", null, Mdi.cricket, 400),
            ],
          ),

          const SizedBox(height: 20),

          /// ------- Row 3 -------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              activityItem("650", null, Mdi.basketball, 650),
              activityItem("450", null, Mdi.volleyball, 450),
              activityItem("700", null, Mdi.football_pitch, 700),
              activityItem("600", null, Mdi.tennis, 600),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            '*Average Calories burn per hr',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFFB0B0B0),
            ),
          ),
        ],
      ),
    ),
  );
}
Widget habitTrackerCard({
  required BuildContext context,
  required TextEditingController habitController,
  required bool expand,
  required VoidCallback onToggleExpand,
  required VoidCallback onNavigateSavedHabits,
  required VoidCallback onAddHabit,
  required VoidCallback onNavigateCreateHabit,
  required VoidCallback onSetState, // used when selecting predefined habits
}) {
  return Card(
    color: const Color(0xFF1E1E1E),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title Row
          Row(
            children: [
              Text(
                'Habit Tracker',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
                onPressed: onNavigateSavedHabits,
                child: Text(
                  'Saved Habits',
                  style: GoogleFonts.poppins(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          /// Create Habit Card
          Card(
            color: const Color(0xFF2A2A2A),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Habit',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// Habit Input Field & Add Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: habitController.text.isEmpty ? 300 : 280,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: GoogleFonts.poppins(color: Colors.white),
                            controller: habitController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        /// Add Habit Button (only visible if text not empty)
                        if (habitController.text.isNotEmpty)
                          IconButton(
                            onPressed: onAddHabit,
                            icon: const Icon(Icons.add, color: Colors.blue),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// Habit Suggestions Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _habitSuggestion('Drink 8 glasses of water', habitController, onSetState),
                      _habitSuggestion('Do yoga', habitController, onSetState),
                      _habitSuggestion('Sleep 7-8 hrs', habitController, onSetState),
                      _habitSuggestion('Wake up early', habitController, onSetState),

                      /// Expand button
                      if (!expand)
                        IconButton(
                          onPressed: onToggleExpand,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                        ),

                      if (expand) ...[
                        _habitSuggestion('Meditate', habitController, onSetState),
                        _habitSuggestion('Eat Fruits', habitController, onSetState),
                        _habitSuggestion('Eat Vegetables', habitController, onSetState),
                        _habitSuggestion('Limit Sugar', habitController, onSetState),
                        _habitSuggestion('Limit Caffeine', habitController, onSetState),
                        _habitSuggestion('Cook at home', habitController, onSetState),
                        _habitSuggestion('No junk food today', habitController, onSetState),
                        _habitSuggestion('Take medicine', habitController, onSetState),

                        /// Collapse button
                        IconButton(
                          onPressed: onToggleExpand,
                          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.blue),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// ✅ Reusable habit suggestion button widget
Widget _habitSuggestion(
  String label,
  TextEditingController controller,
  VoidCallback onSetState,
) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    onPressed: () {
      controller.text = label;
      onSetState();
    },
    child: Text(
      label,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    ),
  );
}

Widget waterIntakeCard({
  required double waterval,
  required VoidCallback onAddWater, // triggers setState + box.put
}) {
  return Card(
    color: const Color(0xFF1E1E1E),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          /// Header
          Row(
            children: [
              const Icon(CupertinoIcons.drop_fill,
                  color: Color(0xFF3399FF), size: 32),
              const SizedBox(width: 5),
              Text(
                'Water Intake',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF3399FF),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Progress & intake amount
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Main circle indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 70,
                        width: 70,
                        child: CircularProgressIndicator(
                          strokeWidth: 8,
                          color: const Color(0xFF3399FF),
                          value: waterval,
                          backgroundColor: const Color(0xFF2A2A2A),
                        ),
                      ),
                      Column(
                        children: [
                          const Icon(Icons.water_drop,
                              color: Color(0xFF3399FF)),
                          Text(
                            '${(waterval * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  /// Text & add button
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: (waterval * 60).toStringAsFixed(0),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'fl oz',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '(UK)',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '/',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '60',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'fl oz',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '(UK)',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// Add water button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A2A2A),
                          ),
                          onPressed: onAddWater,
                          icon: const Icon(Icons.add, color: Color(0xFF3399FF)),
                          label: Text(
                            '6fl oz',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// Weekly progress mini indicators
             
            ],
          ),
        ],
      ),
    ),
  );
}



