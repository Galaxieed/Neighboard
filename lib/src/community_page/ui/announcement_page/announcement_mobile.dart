import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/announcement_data.dart';
import 'package:neighboard/models/announcement_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AnnouncementMobile extends StatefulWidget {
  const AnnouncementMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  State<AnnouncementMobile> createState() => _AnnouncementMobileState();
}

class _AnnouncementMobileState extends State<AnnouncementMobile> {
  Widget mainAnnouncementWidget = Container();
  _mainAnnouncementWidget() {
    for (AnnouncementModel announcementModel in announcements) {
      if (announcementModel.isMainAnnouncement) {
        mainAnnouncementWidget = MainAnnouncement(
          announcementModel: announcementModel,
        );
        break;
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mainAnnouncementWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
        centerTitle: true,
        actions: [
          //TODO: replace with SORT? instead of Filter
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_alt),
            tooltip: "Filter",
          ),
          NavBarCircularImageDropDownButton(callback: Routes().navigate),
          SizedBox(
            width: 2.5.w,
          )
        ],
      ),
      drawer: widget.deviceScreenType == DeviceScreenType.mobile
          ? const NavDrawer()
          : null,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const SizedBox(
            //   height: 15,
            // ),
            // Text(
            //   'Announcements',
            //   style: Theme.of(context).textTheme.headlineLarge,
            // ),
            // Row(
            //   mainAxisSize: MainAxisSize.max,
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     ElevatedButton.icon(
            //       onPressed: () {},
            //       icon: const Icon(Icons.filter_alt),
            //       label: const Text('Filter'),
            //     )
            //   ],
            // ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        announcements.sort((a, b) => b.isMainAnnouncement
                            .toString()
                            .compareTo(a.isMainAnnouncement.toString()));
                        var model = announcements[index];
                        if (model.isMainAnnouncement) {
                          return Column(
                            children: [
                              const Divider(),
                              Text(
                                "Main Announcement!",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Divider(),
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 2,
                                child: mainAnnouncementWidget,
                              ),
                              const Divider(),
                              Text(
                                "Other Announcements!",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Divider(),
                            ],
                          );
                        }
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
            decoration: const BoxDecoration(
              color: ccMainAnnouncementBannerColor,
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
                    color: ccOtherAnnouncementBannerColor,
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
