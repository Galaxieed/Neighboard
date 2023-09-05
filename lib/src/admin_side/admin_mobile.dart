import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/src/admin_side/dashboard/dashboard.dart';
import 'package:neighboard/src/admin_side/navigation/navigation_drawer.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminMobile extends StatefulWidget {
  const AdminMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  State<AdminMobile> createState() => _AdminMobileState();
}

class _AdminMobileState extends State<AdminMobile> {
  callback(int i) {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: false,
        actions: [
          NavBarCircularImageDropDownButton(callback: Routes().navigate),
          SizedBox(
            width: 2.5.w,
          )
        ],
      ),
      drawer: const AdminNavDrawer(),
      body: Dashboard(
        callback: (i) {},
      ),
    );
  }
}
