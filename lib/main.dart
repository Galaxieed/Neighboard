import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/firebase_options.dart';
import 'package:neighboard/models/candidates_model.dart';
import 'package:neighboard/models/election_model.dart';
import 'package:neighboard/models/site_model.dart';
import 'package:neighboard/screen_direct.dart';
import 'package:neighboard/shared_preferences/shared_preferences.dart';
import 'package:neighboard/src/admin_side/hoa_voting/candidates/candidates_function.dart';
import 'package:neighboard/src/admin_side/site_settings/site_settings_function.dart';

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await getTheme();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(builder: ((context, child) {
      return ValueListenableBuilder(
          valueListenable: themeNotifier,
          builder: (_, currentMode, __) {
            return MaterialApp(
              scrollBehavior: MyCustomScrollBehavior(),
              debugShowCheckedModeBanner: false,
              title: 'Neighboard',
              theme: ThemeData(
                fontFamily: "Montserrat",
                colorScheme: ColorScheme.fromSeed(seedColor: currentThemeColor),
                useMaterial3: true,
                scaffoldBackgroundColor: Colors.grey[100],
                cardTheme: CardTheme(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              darkTheme: ThemeData.dark(
                useMaterial3: true,
              ).copyWith(
                textTheme: ThemeData.dark().textTheme.apply(
                      fontFamily: 'Montserrat',
                    ),
              ),
              themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const ScreenDirect(),
            );
          });
    }));
  }
}

final ValueNotifier themeNotifier = ValueNotifier(ThemeMode.system);

Color currentThemeColor = Colors.amber;
SiteModel? siteModel;
bool isDarkMode = false;

Future<void> getTheme() async {
  isDarkMode = await SharedPrefHelper.loadThemeMode();
  //TODO: change this id based on admin id
  siteModel = await SiteSettingsFunction.getSiteSettings(siteAdminId);
  if (siteModel != null) {
    currentThemeColor = Color(siteModel!.siteThemeColor);
    await initializeOfficers();
  } else {
    currentThemeColor = Colors.amber;
  }
  int currentSystemThemeColor = await SharedPrefHelper.loadThemeColor();
  if (currentSystemThemeColor != 0) {
    currentThemeColor = Color(currentSystemThemeColor);
  }
}

//check if election is not ongoing
bool mainIsElectionOngoing = false;
ElectionModel? mainElectionModel;
mainCheckIfElectionOngoing() async {
  mainElectionModel = await CandidatesFunctions.getLatestElection();
  if (mainElectionModel != null) {
    DateTime elecStartDate =
        DateTime.parse(mainElectionModel!.electionStartDate);
    DateTime elecEndDate = DateTime.parse(mainElectionModel!.electionEndDate);
    DateTime now = DateTime.now();
    elecStartDate =
        DateTime(elecStartDate.year, elecStartDate.month, elecStartDate.day);
    elecEndDate =
        DateTime(elecEndDate.year, elecEndDate.month, elecEndDate.day);
    now = DateTime(now.year, now.month, now.day);

    if (now.isAfter(elecStartDate) && now.isBefore(elecEndDate)) {
      // print('The date is within the range');
      mainIsElectionOngoing = true;
    } else if (now.isAtSameMomentAs(elecStartDate) ||
        now.isAtSameMomentAs(elecEndDate)) {
      // print('The date is within the range');
      mainIsElectionOngoing = true;
    } else {
      // print('The date is not within the range');
      mainIsElectionOngoing = false;
    }
  }
}

List<CandidateModel> mainCandidateModels = [];

mainGetAllCandidates(String electionId) async {
  mainCandidateModels =
      await CandidatesFunctions.getAllCandidate(electionId) ?? [];
  mainCandidateModels.sort(((a, b) => b.noOfVotes.compareTo(a.noOfVotes)));
}

//set the latest officers to new collection of site settings so that admin can edit it anytime
setOfficers() async {
  //Pres
  final CandidateModel pres = mainCandidateModels
      .where((element) => element.position == "PRESIDENT")
      .take(1)
      .toList()[0];
  //VP
  final CandidateModel vp = mainCandidateModels
      .where((element) => element.position == "VICE PRESIDENT")
      .take(1)
      .toList()[0];
  //Sec
  final CandidateModel sec = mainCandidateModels
      .where((element) => element.position == "SECRETARY")
      .take(1)
      .toList()[0];
  //Ast Sec
  final CandidateModel astSec = mainCandidateModels
      .where((element) => element.position == "ASSISTANT SECRETARY")
      .take(1)
      .toList()[0];
  //Tres
  final CandidateModel tres = mainCandidateModels
      .where((element) => element.position == "TREASURER")
      .take(1)
      .toList()[0];
  //Aud
  final CandidateModel aud = mainCandidateModels
      .where((element) => element.position == "AUDITOR")
      .take(1)
      .toList()[0];
  //Ast Aud
  final CandidateModel astAud = mainCandidateModels
      .where((element) => element.position == "ASSISTANT AUDITOR")
      .take(1)
      .toList()[0];
  //BOD
  final List<CandidateModel> bod = mainCandidateModels
      .where((element) => element.position == "BOARD OF DIRECTORS")
      .take(8)
      .toList();
  //place as officers
  await SiteSettingsFunction.setOfficers(
      adminId: siteAdminId,
      pres: pres,
      vp: vp,
      sec: sec,
      astSec: astSec,
      tres: tres,
      aud: aud,
      astAud: astAud,
      bod: bod);
}

//get the officers in that collection and place it in a variable to use it in landpage

//if ongoing, empty the officers variable
deleteOfficers() async {
  await SiteSettingsFunction.deleteOfficers(siteAdminId);
}

//if there is no atleast one election happened, empty the officers variable.

initializeOfficers() async {
  //check if election is not ongoing
  await mainCheckIfElectionOngoing();
  //check if there was any election
  if (mainElectionModel != null) {
    if (!mainIsElectionOngoing) {
      //get candidates sorted on noOfVotes
      await mainGetAllCandidates(mainElectionModel!.electionId);
      //assign them as officers based on who has more votes
      await setOfficers();

      //the Officers will be then used in LandingPage display
    } else {
      await deleteOfficers();
    }
  } else {
    await deleteOfficers();
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
