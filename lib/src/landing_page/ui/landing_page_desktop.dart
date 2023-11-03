import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';

import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/src/user_side/community_page/ui/announcement_page/announcement_page.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';

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
  final ScrollController _officerScrollController = ScrollController();

  bool isLastPage = false;
  bool isOnFooter = false;

  goToPage(page) {
    _scrollController
        .animateTo(
          0.0,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.ease,
        )
        .then((value) => _controller.animateToPage(
              page,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.ease,
            ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _officerScrollController.dispose();
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
                duration: const Duration(milliseconds: 1000),
                curve: Curves.ease);
            if (_controller.page!.round() == 3) {
              isLastPage = true;
              if (!_scrollController.position.isScrollingNotifier.value &&
                  _officerScrollController.position.atEdge &&
                  !(_officerScrollController.position.pixels == 0)) {
                isOnFooter = true;
                setState(() {});
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 1000),
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
              isOnFooter = false;
              setState(() {});
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.ease,
              );
            } else {
              if (!_scrollController.position.isScrollingNotifier.value &&
                  !_officerScrollController.hasClients) {
                _controller.previousPage(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.ease,
                );
              } else {
                if (_officerScrollController.position.atEdge &&
                    _officerScrollController.position.pixels == 0) {
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.ease,
                  );
                }
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
                  MyOfficers(
                    isOnFooter: isOnFooter,
                    officerScrollController: _officerScrollController,
                  ),
                ],
              ),
            ),
            MyFooter(
              goToPage: goToPage,
            ),
          ],
        ),
      ),
    );
  }
}

class MyOfficers extends StatelessWidget {
  const MyOfficers(
      {super.key,
      required this.officerScrollController,
      required this.isOnFooter});
  final ScrollController officerScrollController;
  final bool isOnFooter;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40.h, left: 15.w, right: 15.w),
      child: Column(
        children: [
          Text(
            "MEET THE OFFICERS",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Text(
            "The responsible officers who keeps our environment safe and reputable.",
            style: TextStyle(
              fontSize: 4.sp,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: GridView(
              physics: isOnFooter ? const NeverScrollableScrollPhysics() : null,
              controller: officerScrollController,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                childAspectRatio: 250 / 250,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              children: const [
                OfficerAvatar(
                  name: "Redentor Reyes",
                  position: "President",
                  image:
                      "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FPresident.png?alt=media&token=353b7b9f-d648-4468-86a8-848d8e53c175",
                ),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FVice%20President.png?alt=media&token=c41b0ee9-de63-4efa-86c9-3a449d09a9f1",
                    name: "Armino Ipapo",
                    position: "Vice President"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FSecretary.png?alt=media&token=e3987afb-e491-4e1b-aab9-f032ad8562a1",
                    name: "Pamela Bueno",
                    position: "Secretary"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FAssistant%20Sec.png?alt=media&token=05f0b6d4-2596-4a70-b8e0-5d0c2cb1bbd0",
                    name: "Ravinia Garcia",
                    position: "Assistant Secretary"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FTreasurer.png?alt=media&token=be7fcaec-8f32-4f7b-bbc7-5a8b68b75b23",
                    name: "Mila Prado",
                    position: "Treasurer"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FAuditor.png?alt=media&token=b9ea5d4d-4e7f-44c0-bf25-2d566e815aa2",
                    name: "Josephine Abad",
                    position: "Auditor"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FAssistant%20Aud.png?alt=media&token=638919ec-099b-4293-a07a-aabae2fe2fba",
                    name: "Revelyn Villegas",
                    position: "Assistant Auditor"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FLilian%20Rose.png?alt=media&token=2dff7783-5393-4b96-a2bd-140ad43dfb85",
                    name: "Lilian Rose Cruz",
                    position: "Board of Director"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FAnnabel.png?alt=media&token=8b0122f7-906e-4f6b-9d2b-37bb33ae6038",
                    name: "Annabel Sulleza",
                    position: "Board of Director"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FRowena.png?alt=media&token=bd27155d-07c0-4e3b-bced-3c040733442f",
                    name: "Rowena Dizon",
                    position: "Board of Director"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FRey.png?alt=media&token=2c865c07-a2ee-4c44-899f-4e05084c4917",
                    name: "Rey Del Rosario",
                    position: "Board of Director"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FYolando.png?alt=media&token=c32e6306-72e4-420e-a62a-8060fcf862af",
                    name: "Yolando Gatus",
                    position: "Board of Director"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FGabriel.png?alt=media&token=12e3fea7-6552-42df-86ea-3c687feb339f",
                    name: "Gabriel Pilongo",
                    position: "Board of Director"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FVic.png?alt=media&token=70ec415f-416d-41b3-a29d-29d4853b77fe",
                    name: "Vic Lesiguez",
                    position: "Board of Director"),
                OfficerAvatar(
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/project-neighboard.appspot.com/o/images%2FKeith.png?alt=media&token=8c4fe44e-e6a5-460b-93e4-9f803efda6fb",
                    name: "Keith Vista",
                    position: "Board of Director"),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

class OfficerAvatar extends StatefulWidget {
  const OfficerAvatar({
    super.key,
    required this.image,
    required this.name,
    required this.position,
  });

  final String image;
  final String name;
  final String position;

  @override
  State<OfficerAvatar> createState() => _OfficerAvatarState();
}

class _OfficerAvatarState extends State<OfficerAvatar> {
  bool _isHovering = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: CircleAvatar(
            radius: 100,
            backgroundColor: _isHovering
                ? Theme.of(context).colorScheme.inversePrimary
                : null,
            child: ClipOval(
              child: CircleAvatar(
                radius: 95,
                child: widget.image == ""
                    ? Image.asset(guestIcon)
                    : FadeInImage.assetNetwork(
                        placeholder: guestIcon, image: widget.image),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          widget.name,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          widget.position,
          style: Theme.of(context).textTheme.titleMedium!,
        ),
      ],
    );
  }
}

class MyFooter extends StatelessWidget {
  const MyFooter({
    super.key,
    required this.goToPage,
  });
  final Function goToPage;

  shareNeighboard() async {
    Share.share(
        'Hello, let\'s connect here!\nhttps://project-neighboard.web.app',
        subject: 'Let\'s Connect!');
  }

  @override
  Widget build(BuildContext context) {
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
              ElevatedButton.icon(
                onPressed: shareNeighboard,
                icon: const Icon(Icons.share),
                label: const Text("Share"),
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    foregroundColor:
                        Theme.of(context).colorScheme.onBackground),
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
          "ABOUT VILLA V",
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
        const SizedBox(
          height: 20,
        ),
        Text(
          "The quality of living that you deserve to have",
          style: Theme.of(context).textTheme.titleMedium!,
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
