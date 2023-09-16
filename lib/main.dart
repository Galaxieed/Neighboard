import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/firebase_options.dart';
import 'package:neighboard/shared_preferences/shared_preferences.dart';
import 'package:neighboard/src/admin_side/admin_side.dart';
import 'package:neighboard/src/landing_page/ui/landing_page.dart';

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
              debugShowCheckedModeBanner: false,
              title: 'Neighboard | Home',
              theme: ThemeData(
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
              ),
              themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const AdminSide(),
              //home: const LandingPage(),
            );
          });
    }));
  }
}

final ValueNotifier themeNotifier = ValueNotifier(ThemeMode.system);

Color currentThemeColor = Colors.amber;
bool isDarkMode = false;

Future<void> getTheme() async {
  isDarkMode = await SharedPrefHelper.loadThemeMode();
  currentThemeColor = Color(await SharedPrefHelper.loadThemeColor());
}
