import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:responsive_builder/responsive_builder.dart';

class Dashboard extends StatelessWidget {
  const Dashboard(
      {super.key,
      required this.callback,
      required this.deviceScreenType,
      this.currentUser});

  final Function callback;
  final DeviceScreenType deviceScreenType;
  final UserModel? currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: deviceScreenType == DeviceScreenType.mobile
                  ? Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      )
                  : Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
              children: <TextSpan>[
                const TextSpan(
                    text: 'Welcome back, ',
                    style: TextStyle(color: Colors.grey)),
                TextSpan(text: ' ${currentUser!.firstName}! 👋'),
              ],
            ),
          ),
          SizedBox(
            height: 30.h,
          ),
          Expanded(
            child: GridView(
              gridDelegate: deviceScreenType == DeviceScreenType.mobile
                  ? const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 200 / 150,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                    )
                  : const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 400 / 300,
                      mainAxisSpacing: 30,
                      crossAxisSpacing: 30,
                    ),
              children: [
                dashboardCards(
                  context,
                  Colors.orangeAccent.withAlpha(150),
                  Icons.forum_outlined,
                  "Forum",
                  () {
                    callback(2);
                  },
                ),
                dashboardCards(
                  context,
                  Colors.yellowAccent.withAlpha(150),
                  Icons.announcement_outlined,
                  "Announcement",
                  () {
                    callback(3);
                  },
                ),
                dashboardCards(
                  context,
                  Colors.blueAccent.withAlpha(150),
                  Icons.map_outlined,
                  "Community Map",
                  () {
                    callback(4);
                  },
                ),
                dashboardCards(
                  context,
                  Colors.redAccent.withAlpha(150),
                  Icons.store_outlined,
                  "Stores",
                  () {
                    callback(5);
                  },
                ),
                dashboardCards(
                  context,
                  Colors.greenAccent.withAlpha(150),
                  Icons.how_to_vote_outlined,
                  "HOA Voting",
                  () {
                    callback(7);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Card dashboardCards(
    BuildContext context,
    Color color,
    IconData icon,
    String text,
    Function callback,
  ) {
    return Card(
      elevation: 5,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          callback();
        },
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 25.sp,
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              style: deviceScreenType == DeviceScreenType.mobile
                  ? Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold)
                  : Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
