import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/announcement_data.dart';
import 'package:neighboard/models/announcement_model.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';

class AnnouncementDesktop extends StatefulWidget {
  const AnnouncementDesktop({super.key});

  @override
  State<AnnouncementDesktop> createState() => _AnnouncementDesktopState();
}

class _AnnouncementDesktopState extends State<AnnouncementDesktop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 15,
            ),
            Text(
              'Announcements',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Filter'),
                )
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: () {
                      Widget widget = Container();
                      for (AnnouncementModel announcementModel
                          in announcements) {
                        if (announcementModel.isMainAnnouncement) {
                          widget = MainAnnouncement(
                            announcementModel: announcementModel,
                          );
                          break;
                        } else {
                          widget = Container();
                        }
                      }
                      return widget;
                    }(),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Expanded(
                    flex: 3,
                    child: ListView.builder(
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        var model = announcements[index];
                        if (!model.isMainAnnouncement) {
                          return OtherAnnouncement(announcementModel: model);
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainAnnouncement extends StatelessWidget {
  const MainAnnouncement({super.key, required this.announcementModel});
  final AnnouncementModel announcementModel;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(announcementModel.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: ccMainAnnouncementBannerColor(context),
            ),
            child: Padding(
              padding: EdgeInsets.all(3.7.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcementModel.title.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        announcementModel.timeStamp,
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    ],
                  ),
                  Text(
                    'View Details..',
                    style: Theme.of(context).textTheme.titleMedium,
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class OtherAnnouncement extends StatelessWidget {
  const OtherAnnouncement({super.key, required this.announcementModel});
  final AnnouncementModel announcementModel;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(announcementModel.image),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 100.h,
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: ccOtherAnnouncementBannerColor(context),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.all(3.5.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcementModel.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            announcementModel.timeStamp,
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        ],
                      ),
                      Text(
                        'View Details..',
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
