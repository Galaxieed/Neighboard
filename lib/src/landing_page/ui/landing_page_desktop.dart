import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';

import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/src/user_side/community_page/ui/announcement_page/announcement_page.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page.dart';
import 'package:page_transition/page_transition.dart';

class ScrollDetector extends StatelessWidget {
  final void Function(PointerScrollEvent event) onPointerScroll;
  final Widget child;

  const ScrollDetector({
    Key? key,
    required this.onPointerScroll,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) onPointerScroll(pointerSignal);
      },
      child: child,
    );
  }
}

class LandingPageDesktop extends StatefulWidget {
  const LandingPageDesktop({
    super.key,
    required this.header,
    required this.subHeader,
    required this.about,
    required this.bgImage,
    required this.aboutImage,
    required this.subdName,
  });

  final String subdName, header, subHeader, about, bgImage, aboutImage;

  @override
  State<LandingPageDesktop> createState() => _LandingPageDesktopState();
}

class _LandingPageDesktopState extends State<LandingPageDesktop> {
  final PageController _controller = PageController(initialPage: 0);
  final ScrollController _scrollController = ScrollController();

  bool isLastPage = false;

  goToPage(page) {
    _scrollController
        .animateTo(
          0.0,
          duration: const Duration(milliseconds: 1150),
          curve: Curves.ease,
        )
        .then((value) => _controller.animateToPage(
              page,
              duration: const Duration(milliseconds: 2150),
              curve: Curves.ease,
            ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollDetector(
      onPointerScroll: (PointerScrollEvent event) {
        if (event.scrollDelta.dy > 0) {
          if (_controller.page!.round() != _controller.page) {
            return; // Check if it's not already animating
          }
          if (_controller.page! + 1 < _controller.position.maxScrollExtent) {
            _controller.nextPage(
                duration: const Duration(milliseconds: 2150),
                curve: Curves.ease);
            if (_controller.page!.round() == 2) {
              isLastPage = true;
              // _scrollController.jumpTo(
              //   _scrollController.position.maxScrollExtent,
              // );
              if (!_scrollController.position.isScrollingNotifier.value) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 2150),
                  curve: Curves.ease,
                );
              }
            }
          }
        } else if (event.scrollDelta.dy < 0) {
          if (_controller.page!.round() != _controller.page) {
            return; // Check if it's not already animating
          }
          if (_controller.page! - 1 >= _controller.position.minScrollExtent) {
            if (_scrollController.position.pixels != 0 && isLastPage) {
              // _scrollController.jumpTo(0.0);
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 2150),
                curve: Curves.ease,
              );
            } else {
              if (!_scrollController.position.isScrollingNotifier.value) {
                _controller.previousPage(
                    duration: const Duration(milliseconds: 2150),
                    curve: Curves.ease);
              }
            }
          }
          isLastPage = false;
        }
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height,
              child: PageView(
                controller: _controller,
                pageSnapping: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: [
                  HomePage(
                    header: widget.header,
                    subHeader: widget.subHeader,
                    bgImage: widget.bgImage,
                  ),
                  const OffersPage(),
                  AboutPage(
                    header: widget.subdName,
                    subHeader: widget.about,
                    aboutImage: widget.aboutImage,
                  ),
                ],
              ),
            ),
            footer(context),
          ],
        ),
      ),
    );
  }

  Container footer(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.w, bottom: 8.w),
      color: Theme.of(context).colorScheme.inversePrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "OFFICE ADDRESS",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 5.sp),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Block 17 Lot 02, Abaño Street, Villa Roma Phase 5, Lias, Marilao, Bulacan, \n3019 Philippines",
                      style: TextStyle(fontSize: 4.sp),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Mobile Phone Number: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 4.sp),
                        ),
                        Text(
                          "(0906) 279-3960 | (0933) 694-2699",
                          style: TextStyle(fontSize: 4.sp),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        goToPage(0);
                      },
                      child: Text(
                        "Home",
                        style: TextStyle(fontSize: 4.sp),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        goToPage(2);
                      },
                      child: Text(
                        "About Us",
                        style: TextStyle(fontSize: 4.sp),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(PageTransition(
                            duration: const Duration(milliseconds: 500),
                            child: const ForumPage(),
                            type: PageTransitionType.fade));
                      },
                      child: Text(
                        "Forum",
                        style: TextStyle(fontSize: 4.sp),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(PageTransition(
                            duration: const Duration(milliseconds: 500),
                            child: const AnnouncementPage(),
                            type: PageTransitionType.fade));
                      },
                      child: Text(
                        "Announcements",
                        style: TextStyle(fontSize: 4.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Divider(
            color: Theme.of(context).colorScheme.onBackground,
          ),
          SizedBox(
            height: 8.w,
          ),
          const Text("Copyright © 2023 Neighboard. All rights reserved.")
        ],
      ),
    );
  }
}

class OffersPage extends StatelessWidget {
  const OffersPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Text(
          "ABOUT",
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            offersCard(
              context,
              Icons.location_city_outlined,
              "Close to Town",
              "There are various establishments, such as mall, churches, and resort within the the area.",
            ),
            offersCard(
              context,
              Icons.nature_people_rounded,
              "Clean Environment",
              "Subdivision is surrounded by trees and plants, and the streets are kept clean.",
            ),
            offersCard(
              context,
              Icons.security_outlined,
              "Secured Community",
              "The subdivision is secured due to their 24hrs duty of security guards and curfew hours.",
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          height: 30.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.inversePrimary,
                Theme.of(context).colorScheme.primary,
              ],
              //stops: const [0.3, 0.6, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Container offersCard(
    BuildContext context,
    IconData icon,
    String title,
    String details,
  ) {
    return Container(
      height: 90.w,
      width: 80.w,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 15.w,
              child: Icon(
                icon,
                size: 20.w,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 5.sp),
              overflow: TextOverflow.fade,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              details,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 4.sp),
              overflow: TextOverflow.fade,
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({
    super.key,
    required this.header,
    required this.subHeader,
    required this.aboutImage,
  });

  final String header, subHeader, aboutImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40.h, bottom: 40.h, left: 15.w),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      header.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    LandPageHeaderSmall(
                      header: subHeader,
                      size: 6,
                      color: ccSubHeaderFGColor(context),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 60,
            ),
            Expanded(
                child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(90),
                  bottomLeft: Radius.circular(90)),
              child: Transform.flip(
                flipX: false,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: aboutImage == ''
                            ? const AssetImage(noImage) as ImageProvider
                            : NetworkImage(aboutImage),
                        fit: BoxFit.cover),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.header,
    required this.subHeader,
    required this.bgImage,
  });

  final String header, subHeader, bgImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: bgImage == ''
              ? const AssetImage(noImage) as ImageProvider
              : NetworkImage(bgImage),
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          opacity: ccLandPageBGOpacity,
        ),
      ),
      child: Center(
        child: ClipRRect(
          //TODO: Add backdropFilter to blur
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  LandPageHeader(header: header),
                  LandPageHeaderSmall(
                    header: subHeader,
                    size: 5,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  LandPageButton(label: 'Explore', callback: Routes().navigate),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LandPageButton extends StatelessWidget {
  const LandPageButton({
    super.key,
    required this.label,
    required this.callback,
  });

  final String label;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.inversePrimary,
            Colors.white24
          ],
        ),
        borderRadius: BorderRadius.circular(45),
      ),
      child: ElevatedButton(
        onPressed: () {
          callback('Forum', context);
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 6.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}

class LandPageHeaderSmall extends StatelessWidget {
  const LandPageHeaderSmall({
    super.key,
    required this.header,
    required this.size,
    required this.color,
  });
  final Color color;
  final String header;
  final int size;

  @override
  Widget build(BuildContext context) {
    return Text(
      header,
      style: TextStyle(
        fontSize: size.sp,
        color: color,
      ),
      softWrap: true,
    );
  }
}

class LandPageHeader extends StatelessWidget {
  const LandPageHeader({
    super.key,
    required this.header,
  });

  final String header;

  @override
  Widget build(BuildContext context) {
    return Text(
      header,
      style: TextStyle(
          fontSize: 18.sp,
          color: ccHeaderFGColor(context),
          letterSpacing: 10,
          wordSpacing: 10,
          fontWeight: FontWeight.w800,
          fontFamily: "Lexend Deca",
          shadows: const [
            Shadow(
                // bottomLeft
                offset: Offset(-1.5, -1.5),
                color: Colors.white),
            Shadow(
                // bottomRight
                offset: Offset(1.5, -1.5),
                color: Colors.white),
            Shadow(
                // topRight
                offset: Offset(1.5, 1.5),
                color: Colors.white),
            Shadow(
                // topLeft
                offset: Offset(-1.5, 1.5),
                color: Colors.white),
          ]),
      softWrap: true,
    );
  }
}
