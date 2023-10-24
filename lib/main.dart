import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/firebase_options.dart';
import 'package:neighboard/models/site_model.dart';
import 'package:neighboard/screen_direct.dart';
import 'package:neighboard/shared_preferences/shared_preferences.dart';
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
                fontFamily: "Roboto",
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
                      fontFamily: 'Roboto',
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
  siteModel = await SiteSettingsFunction.getSiteSettings(
      'O8dElItKmsUJ5cvZg9FA1eTfi0q2');
  if (siteModel != null) {
    currentThemeColor = Color(siteModel!.siteThemeColor);
  } else {
    currentThemeColor = Colors.amber;
  }
  int currentSystemThemeColor = await SharedPrefHelper.loadThemeColor();
  if (currentSystemThemeColor != 0) {
    currentThemeColor = Color(currentSystemThemeColor);
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
