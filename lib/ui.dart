import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/healthicons.dart';
import 'package:intl/intl.dart';
import 'package:lifestyle_companion/ShowLoggingScreen.dart';
import 'package:lifestyle_companion/SleepEntry.dart';
import 'package:lifestyle_companion/SleepNotifier.dart';
import 'package:lifestyle_companion/achievements.dart';
import 'package:lifestyle_companion/activities_idea.dart';
import 'package:lifestyle_companion/create_habit.dart';
import 'package:lifestyle_companion/exercise.dart';
import 'package:lifestyle_companion/item.dart';

import 'package:lifestyle_companion/groq_service.dart';
import 'package:lifestyle_companion/saved_habit.dart';
import 'package:lifestyle_companion/select_pref.dart';
import 'package:lifestyle_companion/steps_ui.dart';
import 'package:lifestyle_companion/widget.dart';
import 'package:lottie/lottie.dart';

import 'package:replog_icons/replog_icons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/fa6_solid.dart';   // Font Awesome solid
import 'package:iconify_flutter/icons/fa6_regular.dart'; // Font Awesome regular
import 'package:iconify_flutter/icons/mdi.dart'; 
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:pedometer/pedometer.dart';
import 'exercise.dart';
import 'exercise_api.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:health/health.dart';
import 'package:daily_pedometer/daily_pedometer.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';



class UiWidget extends StatefulWidget {
  const UiWidget({super.key});

  @override
  State<UiWidget> createState() => _UiWidgetState();
}

class _UiWidgetState extends State<UiWidget> with WidgetsBindingObserver,SingleTickerProviderStateMixin {
  String result = ""; // store calculation result
  String target = "";
  TextEditingController controller = TextEditingController();
  TextEditingController controllerheight = TextEditingController();
  TextEditingController calburn = TextEditingController();
  TextEditingController habit = TextEditingController();
  bool isCalculate = false;

  double waterval = 0;
  String bedtimeText = '';
  String wakeupText = '';
   String napText = '';
  String totalSleepText = '';
  final boxItem = Hive.box('items');
  final habitBox = Hive.box('habit');
  final savedHabit = Hive.box('savehabit');
  final prefBox = Hive.box('pref');
  final sleepBox = Hive.box('sleep');
  final dayBox = Hive.box('day');
  final steps = Hive.box('steps');
  String _response = "Loading repsone...";
  String _sleepResponse = "Loading reponse...";

    Future<void> _getResponse(String query) async {
    try {
    
      final reply = await GroqService.askGroq(
       query
      );
      setState(() => _response = reply);
    } catch (e) {
      setState(() => _response = 'Error: $e');
    }
  }

  Future<void> _getSleepResponse(String query) async {
    try {
    
      final reply = await GroqService.askGroq(
       query
      );
      setState(() => _sleepResponse = reply);
    } catch (e) {
      setState(() => _sleepResponse = 'Error: $e');
    }
  }

  late Future<List<Exercise>> _futureExercises;

  // starting point
  int stepsToday = 0;
  bool showList = false;
  bool expand = false;

  final box = Hive.box('waterintake');



  void preference(){
    if(prefBox.isNotEmpty){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>ItemWidget()));
    }else{
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>SelectPref()));
    }
  }

  
  

int liveSteps = 0;
int historicalSteps = 0;
int totalSteps = 0;


  /// Background service to persist steps continuously
  void initBackgroundService() {
    final service = FlutterBackgroundService();
    service.configure(
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'step_counter_channel',
        initialNotificationTitle: 'Step Counter Running',
        initialNotificationContent: 'Tracking your steps in the background',
        foregroundServiceNotificationId: 888, onStart: onStartBackground,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStartBackground,
        onBackground: onStartBackground,
      ),
    );
    service.startService();
  }
   

   FutureOr<bool> onStartBackground(ServiceInstance service) async {
  final pedometer = Pedometer.stepCountStream;
  pedometer.listen((event) {
    final box = Hive.box('steps');
    int storedInitial = box.get('initialSteps', defaultValue: event.steps);
    int live = event.steps - storedInitial;

    box.put('initialSteps', storedInitial);
    box.put('liveSteps', live);
  }).onError((error) {
    print("Background Pedometer Error: $error");
  });

  return true; // <-- important: return true
}




  final Health health = Health();

    /// Fetch historical steps from Google Fit / HealthKit
  Future<void> fetchHistoricalSteps() async {
    await Permission.activityRecognition.request();

    final types = [HealthDataType.STEPS];
    bool access = await health.requestAuthorization(types);

    if (!access) {
      if (mounted) {
     
      }
      return;
    }

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    List<HealthDataPoint> data = await health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: now,
    );

    int total = 0;
    for (var point in data) {
      if (point.type == HealthDataType.STEPS) {
        total += (point.value is int)
            ? point.value as int
            : (point.value as double).toInt();
      }
    }

    setState(() {
      historicalSteps = total;
    });
  }
   String formatDate(DateTime d) {
  return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}
StreamSubscription<StepCount>? _stepSubscription;

void initPedometer() {
  final stepsBox = Hive.box('steps');

  _stepCountStream = Pedometer.stepCountStream;

  _stepSubscription?.cancel();

  _stepSubscription = _stepCountStream?.listen((StepCount event) {
    print('Pedometer event: ${event.steps} at ${DateTime.now()}');

    DateTime now = DateTime.now();
    String currentDate = formatDate(now);

    String lastDate = stepsBox.get('lastDate', defaultValue: currentDate);

    final baselineKey = 'baseline_$currentDate';

    // Create baseline if not exists
    if (!stepsBox.containsKey(baselineKey)) {
      stepsBox.put(baselineKey, event.steps);
      print('Baseline set for $currentDate => ${event.steps}');
    }

    int storedInitial = stepsBox.get(baselineKey, defaultValue: event.steps);

    // New day logic
    if (lastDate != currentDate) {
      int yesterdayLive = stepsBox.get('liveSteps', defaultValue: 0);

      DateTime parsedLast = DateTime.tryParse(lastDate) ?? DateTime.now();
      String weekdayName = getWeekdayName(parsedLast.weekday);

      stepsBox.put(weekdayName, yesterdayLive);
      stepsBox.put('lastDate', currentDate);
      stepsBox.put('liveSteps', 0);
      stepsBox.put(baselineKey, event.steps);
      storedInitial = event.steps;

      print('New day: baseline reset for $currentDate => ${event.steps}');
    }

    int live = event.steps - storedInitial;
    if (live < 0) live = 0;

    // Anti-cheat / sensor reset protection
    if (live > 500000) {
      stepsBox.put(baselineKey, event.steps);
      live = 0;
      print('Unrealistic jump detected, baseline adjusted.');
    }

    stepsBox.put('liveSteps', live);

    // ✅ Update notification live
    FlutterForegroundTask.updateService(
      notificationTitle: "Steps Tracking Active",
      notificationText: "Steps today: $live",
    );

    if (mounted) {
      setState(() => liveSteps = live);
    }
  }, onError: (error) {
    print("Pedometer Error: $error");
  });
}





  int getDaySinceInstall(){

    final box = Hive.box('appData');

    DateTime? installDate = box.get('installDate');

    if(installDate==null){
      installDate = DateTime.now();
      box.put('installDate', installDate);
    }

    final today = DateTime.now();
    final difference = today.difference(installDate).inDays;

    box.put('currentDays',difference);

    return difference;

  }

  String calculate(String weight) {
    int w = int.tryParse(weight) ?? 0;
    int calories = w * 24; // simple formula

    return "$calories";


  }
  String averageCaloriesBurnedString(String stepsStr, {double avgWeight = 70}) {
  // Convert steps safely
  double steps = double.tryParse(stepsStr) ?? 0.0;

  // Calories burned using average weight
  double caloriesBurned = steps * avgWeight * 0.0005;

  // Round to 1 decimal place and format as string
  return caloriesBurned.toStringAsFixed(1);
}

double burnedFractionDynamicDaily({
  required String weightStr,  // weight in kg
  required String stepsStr,   // steps walked
}) {
  // Convert strings safely
  double weight = double.tryParse(weightStr) ?? 0.0;
  double steps = double.tryParse(stepsStr) ?? 0.0;

  // Calculate dynamic daily average calories for this weight
  double dailyAverage = weight * 24;

  // Calculate calories burned from steps
  double caloriesBurned = steps * weight * 0.0005;

 double fraction = (caloriesBurned / dailyAverage).clamp(0.0, 1.0);

  // Round to 1 decimal place
  return double.parse(fraction.toStringAsFixed(2));
}

double cpiValue(int calories){
   double cpi = calories/2000;

   return cpi;
}

String cpiValuestring(int calories){
   double cpi = calories/200;
   

   return cpi.toString();
}


double calcin(String weight) {
  double w = double.tryParse(weight) ?? 0.0;
  double calories = w * 24; // simple formula

  return calories;
}

Stream<StepCount>? _stepCountStream;



int _steps = 0;
int _stepsAtReset = 0;   // manual reset offset
        // daily baseline
bool pausePressed = false;
 int? _baseline;
 int _stepsx = 0;

  bool _firstTimeDialogShown = false;

  List<String> parts = [];
  int hour = 0;
  int minutes = 0;

    List<String> parts1 = [];
  int hour1 = 0;
  int minutes1 = 0;

     List<String> parts2 = [];
  int hour2 = 0;
  int minutes2 = 0;

  int hour3 = 0;
  int minutes3 = 0;

  String finalMinutes = '';

  void onStart(ServiceInstance service) {
  final pedometer = Pedometer.stepCountStream;
  pedometer.listen((event) {
    int storedSteps = Hive.box('steps').get('liveSteps', defaultValue: 0);
    int initial = Hive.box('steps').get('initialSteps', defaultValue: event.steps);
    int liveSteps = event.steps - initial;
    Hive.box('steps').put('liveSteps', liveSteps);
    Hive.box('steps').put('initialSteps', initial);
  });
}

/// Hybrid Step Tracking: Historical + Live
  void initStepTracking() async {
    await fetchHistoricalSteps();
    initPedometer();
    initBackgroundService();
  }

 int daysSince = 0;
 bool w = true;
 bool t = false;
 bool f = false;
 bool sat = false;
 bool sun = false;
 bool mon = false;
 bool tue = false;

 int rebootSteps = 0;

 late AnimationController _controller;

Future<void> askStepPermission() async {
  var act = await Permission.activityRecognition.request();
  var body = await Permission.sensors.request(); // BODY_SENSORS

  print("Activity Permission: $act");
  print("Body Sensor Permission: $body");

  if (act.isDenied || body.isDenied) {
    print("❌ Sensor permissions denied");
  }
}





@override
void initState() {
  super.initState();

   askStepPermission().then((_) {
    initPedometer(); // start after permission
  });

  
  WidgetsBinding.instance.addObserver(this);

  saveCurrentDay(); // keep
  checkAndResetSteps(); // ✅ keep only once here — remove second call

  // Show first-time dialog only once
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!_firstTimeDialogShown) {
      _firstTimeDialogShown = true;
      _showFirstTimeDialog();
    }
  });

  // Rebuild UI when habits change
  habit.addListener(() {
    setState(() {});
  });

  // Default workout API call
  _futureExercises = ExerciseApi.fetchExerciseByBodyPart("chest");

  // Load saved water intake
  final saved = box.get("water", defaultValue: 0.0);
  waterval = saved;

  // Load sleep data
  _updateSleepData();

  // Calculate app usage days
  daysSince = getDaySinceInstall();

 




  // Run diet AI response once
  _getResponse(
    "My daily intake is 1010 kcal, 115 g protein, and 41.4 g fat. "
    "Generate a personalized diet feedback. "
    "Response rules: "
    "- Keep it short and very concise (2–4 lines only) "
    "- No intro, no fillers, no questions "
    "- Direct bullet-like feedback "
    "- Use emojis instead of ** "
    "- Give overall nutrient summary at end "
    "- Do NOT say 'Okay' "
  );

  // Animation for UI glow
  _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);






}


  void saveCurrentDay() {
  final today = DateTime.now();
  steps.put('lastUpdateDay', today.day); // store only the day
}

void checkAndResetSteps() {
  final today = DateTime.now();
  final todayKey = formatDate(today); // <-- use same function everywhere

  final lastDateKey = steps.get('lastDate');

  if (lastDateKey == null) {
    steps.put('lastDate', todayKey);
    steps.put('liveSteps', 0);
    return;
  }

  DateTime lastDate = DateTime.tryParse(lastDateKey) ?? today;

  if (!isSameDate(lastDate, today)) {
    final yesterdaySteps = steps.get('liveSteps', defaultValue: 0);
    final weekdayName = getWeekdayName(lastDate.weekday);

    steps.put(weekdayName, yesterdaySteps);
    steps.put('liveSteps', 0);
    steps.put('lastDate', todayKey);
  }
}


 int getSteps(String day) {
    return steps.get(day, defaultValue: 0) as int;
  }

// Helper to compare dates
bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// Helper to get weekday name
String getWeekdayName(int weekday) {
  switch (weekday) {
    case 1:
      return 'Mon';
    case 2:
      return 'Tue';
    case 3:
      return 'Wed';
    case 4:
      return 'Thu';
    case 5:
      return 'Fri';
    case 6:
      return 'Sat';
    case 7:
      return 'Sun';
    default:
      return '';
  }
}


Map<String, dynamic> getStepsForDate(DateTime date) {
  final key = "${date.year}-${date.month}-${date.day}";
  final data = steps.get(key, defaultValue: {'steps': 0, 'weekday': date.weekday});
  return Map<String, dynamic>.from(data);
}




  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchHistoricalSteps(); // fetch again when app comes to foreground
    }
  }

/// Update local variables whenever sleepBox changes
void _updateSleepData() {
  if (sleepBox.isNotEmpty) {
    final lastSleep = sleepBox.getAt(sleepBox.length - 1);

    if (lastSleep is Map) {
      setState(() {
        bedtimeText = (lastSleep['bedtime'] ?? '').toString();
        wakeupText = (lastSleep['wakeup'] ?? '').toString();
        napText = (lastSleep['nap'] ?? '').toString();
        totalSleepText = (lastSleep['total'] ?? '').toString();

        _getSleepResponse( "Nap duration: $napText hours, Total sleep: $totalSleepText hours. "
    "Analyze if the nap duration is beneficial or excessive and if total sleep is below, within, or above the healthy adult range (7–9 hours). "
    "If total sleep exceeds the limit, clearly mention it as excessive. "
    "Respond with exactly 3 to 4 short bullet points, each only one concise line STRICTLY AT MAX. "
    "No introduction, no summary, no extra text — just the feedback points."
    "Use emoji's for better look and understanding instead of *");

        // Parse hours and minutes
        parts = bedtimeText.split(':');
        hour = int.tryParse(parts[0]) ?? 0;
        minutes = int.tryParse(parts[1]) ?? 0;

        parts1 = wakeupText.split(':');
        hour1 = int.tryParse(parts1[0]) ?? 0;
        minutes1 = int.tryParse(parts1[1]) ?? 0;

        hour2 = int.tryParse(napText) ?? 0;

        final parts2 = totalSleepText.split('h');
        hour3 = int.tryParse(parts2[0]) ?? 0;
        finalMinutes = parts2.length > 1 ? parts2[1] : '0';
      });
    }
  }
}


@override
void dispose(){
   WidgetsBinding.instance.removeObserver(this);
  sleepBox.listenable().removeListener(_updateSleepData);
  _controller.dispose();
   _stepCountStream?.listen(null)?.cancel();
  super.dispose();
}



int getStepsForWeekday(int weekday) {
  final box = Hive.box('steps');
  int total = 0;

  for (var key in box.keys) {
    final data = box.get(key);
    if (data is Map && data['weekday'] == weekday) {
      total += (data['steps'] as int? ?? 0);
    }
  }

  return total;
}

   void _showFirstTimeDialog() {
   showDialog(
  context: context,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20), // Rounded corners
    ),
    child: ConstrainedBox(
      // Constrain the width of the dialog to expand horizontally
      constraints: BoxConstraints(
        maxWidth: 400, // You can adjust this value for wider screens
        minWidth: 300, // Ensures minimum width for small devices
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content vertically
          children: [
            // Icon at the top
            Icon(Icons.bedtime, size: 60, color: Colors.blueAccent),
            SizedBox(height: 15),

            // Title text
            Text(
              'Sleep Tracker (New Launches!)',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

            // Description text
            Text(
              'Log your bedtime and wake-up time to see your sleep patterns and get helpful insights.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 25),

            // Buttons in a column to make them full width
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Expand buttons horizontally
              children: [
                // "Maybe Later" TextButton
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16), // Increase tap area
                  ),
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
               
                
                SizedBox(height: 10), // Space between buttons

                // "Log My First Sleep" ElevatedButton
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16), // Increase tap area
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded edges
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Showloggingscreen()),
                    );
                    _updateSleepData();
                  },
                  child: Text(
                    'Log My First Sleep',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);

  }

final sleepProvider =
    StateNotifierProvider<SleepNotifier, List<SleepEntry>>((ref) {
  return SleepNotifier();
});


  @override
  Widget build(BuildContext context) {

  

    int totalSteps = historicalSteps+liveSteps;

    Hive.box('LiveSteps').put('live', totalSteps);
    final nowTime = DateTime.now();

    final todayData = getStepsForDate(DateTime.now());

    double totalMinutes = totalSteps/100;

    int hours = (totalMinutes/60).toInt();
    int minutes = (totalMinutes%60).toInt();

      int? _lastKcal;
  int? _lastProtein;
  double? _lastFat;

  


     
    return Scaffold(
      
      backgroundColor: const Color(0xFF121212), // dark background to see cards
      body: SingleChildScrollView(
        child: Column(
          children: [
             const SizedBox(height: 20),
             achievementHeader(context),
             stepWidget(context, _controller, totalSteps, pausePressed, () => setState(() => pausePressed = !pausePressed)),
            Visibility(visible:sleepBox.isNotEmpty,
              child:  
  GestureDetector(
          onTap: () async {
              await Navigator.push(context, PageRouteBuilder(transitionDuration: Duration(milliseconds: 800),pageBuilder: (context,animation,secondaryAnimation)=>
                           Showloggingscreen(),
                           transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1, 0);
                            const end = Offset.zero;
                            const curve= Curves.ease;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(position: offsetAnimation,child: child,);
                           },
                        ));

                         _updateSleepData();
          },
          child: sleepCard(hour, hour1, hour2, hour3, bedtimeText, wakeupText, napText, finalMinutes, _sleepResponse),
              ),
            ),
            const SizedBox(height: 5),
           Card(
  elevation: 8,
  color: const Color(0xFF1E1E1E), // dark gray background
  shadowColor: Colors.grey[900],   // softer shadow
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.directions_run,
              color: Colors.deepOrange, // accent icon
            ),
            SizedBox(width: 5),
            Text(
              'Exercise',
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10,),
            buildLiveDot(_controller)
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  "${(totalSteps*0.04).toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                    color: Colors.orangeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kcal',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '${hours}h ${minutes}m',
                  style: GoogleFonts.poppins(
                    color: Colors.orangeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Time',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '${(totalSteps*0.0008).toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    color: Colors.orangeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Km',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ),
),
            const SizedBox(height: 5,),

           activitiesCard(context: context, cpiValue: cpiValue),

            Card(color: const Color(0xFF1E1E1E),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Calories and Nutrition',style: GoogleFonts.poppins(fontSize: 24,color: Colors.white, fontWeight: FontWeight.bold))
                      ],
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                      Text('Calories Consumed',style: GoogleFonts.poppins(fontSize: 18,color: Colors.white, fontWeight: FontWeight.bold)),
                      
                      
                      ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor:const Color(0xFF1E1E1E)),onPressed: ()
                      => preference()
                      , label: Text('Add Item',style: GoogleFonts.poppins(fontSize: 16,color: Colors.blue, fontWeight: FontWeight.bold)))
                    ],),
                    Row(children: [
                      Text('Added Items:',style: GoogleFonts.poppins(fontSize: 18,color: Colors.white, fontWeight: FontWeight.bold)),
                     
                    ],),

 ValueListenableBuilder(
  valueListenable: boxItem.listenable(),
  builder: (context, Box box, _) {
    if (box.isEmpty) {
      return Center(child: Text("No items yet", style: GoogleFonts.poppins(color: Colors.white)));
    }

   // 🔹 Compute cumulative totals
    int totalKcal = 0;
    int totalProtein = 0;
    double totalFat = 0.0;

    for (int i = 0; i < box.length; i++) {
      final task = box.getAt(i) as Map? ?? {};

      totalKcal += (task['kcal'] ?? 0) as int;
      totalProtein += (task['protein'] ?? 0) as int;
      totalFat += (task['fat'] ?? 0.0) as double;

    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Summary section
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                color: Colors.blueGrey[900],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Daily Totals", style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(totalKcal>2000?"Calories: $totalKcal kcal 🔼":"Calories: $totalKcal kcal 🔻", style: GoogleFonts.poppins(color: Colors.white)),
                      Text(totalProtein>60?"Protein: $totalProtein g 🔼":"Protein: $totalProtein g 🔻", style: GoogleFonts.poppins(color: Colors.white)),
                      Text(totalFat<65?"Fat: ${totalFat.toStringAsFixed(1)} g 🔻":"Fat: ${totalFat.toStringAsFixed(1)} g 🔼", style: GoogleFonts.poppins(color: Colors.white)),
                    ],
                  ),
                ),
              ),
                   Card(
                color: Colors.blueGrey[900],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                   
                    children: [
                     
                  Icon(totalKcal>2000 && totalProtein>60 && totalFat>65?Icons.emoji_emotions:Icons.sentiment_dissatisfied,color: Colors.yellow,size: 70,),
                  Text(totalKcal>2000 && totalProtein>60 && totalFat>65?'Excellent Choice':'Poor Choice',style: GoogleFonts.poppins(color: Colors.white,),)
                    ],
                  ),
                ),
              ),

            ],

          ),
          

          Card(elevation: 8,color: Colors.grey[900],child: 
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [

              Row(
                children: [
                  Text('AI Feedback',style: GoogleFonts.poppins(color: Colors.blueAccent,fontSize: 20,fontWeight: FontWeight.bold),),
                  SizedBox(width: 5,),
                  Lottie.network(
          'https://drive.google.com/uc?export=download&id=1zTkb7djw3YYQhDKMH0rV7g2wZ7sTNBXw',
          width: 50,
          height: 50,
          fit: BoxFit.fill,
        ),
                ],
              ),
              SizedBox(height: 10,),
            Text(_response,style: GoogleFonts.poppins(color: Colors.white,fontWeight: FontWeight.bold),)
            
            ],),
          ),),

          ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900]),icon: Icon(Icons.arrow_drop_down,color: Colors.red,),onPressed: (){
            setState(() {
              showList=!showList;
            });
          },label: Text(showList?'Hide Diet':'Show Saved Diet',style: GoogleFonts.poppins(color: Colors.white,fontWeight: FontWeight.bold),),),

          // 🔹 List of items
          if(showList)
          ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, value, child) {
              return ListView.builder(
                padding:EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: box.length,
                itemBuilder: (context, index) {
                  final task = box.getAt(index) as Map? ?? {};
                  final counter = task['counter'] ?? '';
                  final filtItem = task['filteredItem'] ?? '';
                  final nutri = task['nutritionalValues'] ?? '';
              
                  return Card(
                    color: Colors.black,
                    child: ListTile(
                      
                      title: Text(
                        '$counter × $filtItem',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      subtitle: Text(
                        nutri,
                        style: GoogleFonts.poppins(color: Colors.blue),
                      ),
                      trailing: IconButton(icon: Icon(Icons.delete,color: Colors.red,
                      ), onPressed: () { 
                        box.deleteAt(index);
                       },),
                    ),
                  );
                },
              );
            }
          ),
          
        ],
      ),
    );
  },
)

,
         ],
                ),
              ),
            ),
     
    habitTrackerCard(
  context: context,
  habitController: habit,
  expand: expand,
  onToggleExpand: () => setState(() => expand = !expand),
  onNavigateSavedHabits: () {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SavedHabitWidget()));
  },
  onAddHabit: () async {
    await habitBox.clear();
    habitBox.add({'habitText': habit.text});
    Navigator.push(context, MaterialPageRoute(builder: (_) => CreateHabitWidget()));
  },
  onNavigateCreateHabit: () {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CreateHabitWidget()));
  },
  onSetState: () => setState(() {}),
)
,
waterIntakeCard(
  waterval: waterval,
  onAddWater: () {
    setState(() {
      waterval += 0.1;
      box.put("water", waterval);
    });
  },
),

],
        ),
      ),
    );
  }
}
