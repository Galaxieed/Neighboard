import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ccNavDrawerBGColor(context),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            //decoration: BoxDecoration(color: ccNavDrawerHeaderColor(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("NEIGHBOARD"),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Routes().navigate("Home", context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum),
            title: const Text("Forum"),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Routes().navigate("Forum", context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.announcement),
            title: const Text("Announcements"),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Routes().navigate("Announcements", context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text("Community Map"),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Routes().navigate("Community Map", context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.how_to_vote),
            title: const Text("HOA Voting"),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Routes().navigate("HOA Voting", context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text("Stores"),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Routes().navigate("Stores", context);
            },
          ),
          const Divider(),
          const LightDarkMode(),
          const ThemeColorPicker(),
        ],
      ),
    );
  }
}

class LightDarkMode extends StatefulWidget {
  const LightDarkMode({super.key});

  @override
  State<LightDarkMode> createState() => _LightDarkModeState();
}

class _LightDarkModeState extends State<LightDarkMode> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: isDarkMode
          ? const Icon(Icons.light_mode)
          : const Icon(Icons.dark_mode),
      trailing:
          AbsorbPointer(child: Switch(value: isDarkMode, onChanged: (val) {})),
      title: isDarkMode ? const Text("Light Mode") : const Text("Dark Mode"),
      onTap: () {
        isDarkMode = !isDarkMode;
        themeNotifier.value = themeNotifier.value == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light;
        setState(() {});
        SharedPrefHelper.saveThemeMode(isDarkMode);
      },
    );
  }
}

class ThemeColorPicker extends StatefulWidget {
  const ThemeColorPicker({super.key});

  @override
  State<ThemeColorPicker> createState() => _ThemeColorPickerState();
}

class _ThemeColorPickerState extends State<ThemeColorPicker> {
  Color pickerColor = const Color(0xffffc107);
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.color_lens),
      trailing: AbsorbPointer(
          child: CircleAvatar(
        backgroundColor: currentThemeColor,
      )),
      title: const Text("Change Theme"),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              // child: ColorPicker(
              //   pickerColor: pickerColor,
              //   onColorChanged: changeColor,
              // ),
              // child: MaterialPicker(
              //   pickerColor: pickerColor,
              //   onColorChanged: changeColor,
              //   enableLabel: true, // only on portrait mode
              // ),
              child: BlockPicker(
                pickerColor: currentThemeColor,
                onColorChanged: changeColor,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Got it'),
                onPressed: () {
                  currentThemeColor = pickerColor;
                  themeNotifier.value = currentThemeColor;
                  setState(() {});
                  SharedPrefHelper.saveThemeColor(currentThemeColor.value);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
