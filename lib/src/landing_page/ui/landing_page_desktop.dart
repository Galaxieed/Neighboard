import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/candidates_model.dart';

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
    required this.officers,
    required this.officeAddress,
    required this.contactNo,
  });

  final String subdName,
      header,
      subHeader,
      about,
      bgImage,
      aboutImage,
      officeAddress,
      contactNo;
  final List<CandidateModel> officers;

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
    setState(() {
      isOnFooter = false;
    });
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

  CandidateModel? presModel,
      vpModel,
      secModel,
      astSecModel,
      tresModel,
      audModel,
      astAudModel;
  List<CandidateModel> bodModels = [];

  void getOfficers() {
    if (widget.officers.isNotEmpty) {
      presModel = widget.officers
          .where((element) => element.position == "PRESIDENT")
          .take(1)
          .toList()[0];
      vpModel = widget.officers
          .where((element) => element.position == "VICE PRESIDENT")
          .take(1)
          .toList()[0];
      secModel = widget.officers
          .where((element) => element.position == "SECRETARY")
          .take(1)
          .toList()[0];
      astSecModel = widget.officers
          .where((element) => element.position == "ASSISTANT SECRETARY")
          .take(1)
          .toList()[0];
      tresModel = widget.officers
          .where((element) => element.position == "TREASURER")
          .take(1)
          .toList()[0];
      audModel = widget.officers
          .where((element) => element.position == "AUDITOR")
          .take(1)
          .toList()[0];
      astAudModel = widget.officers
          .where((element) => element.position == "ASSISTANT AUDITOR")
          .take(1)
          .toList()[0];
      bodModels = widget.officers
          .where((element) => element.position == "BOARD OF DIRECTORS")
          .take(8)
          .toList();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getOfficers();
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
            //PageView nextPage
            _controller.nextPage(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.ease);
            //check if nextpage has officers or not in lastpage
            if (_controller.page!.round() ==
                (widget.officers.isNotEmpty ? 3 : 2)) {
              isLastPage = true;
              if (!_scrollController.position.isScrollingNotifier.value) {
                //if there is officers
                if (_officerScrollController.hasClients) {
                  //checks if officer is at the edge of scrolling
                  if (_officerScrollController.position.atEdge &&
                      !(_officerScrollController.position.pixels == 0)) {
                    isOnFooter = true;
                    setState(() {});
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.ease,
                    );
                  }
                  //if there is no officers
                } else {
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
          }
        } else if (event.scrollDelta.dy < 0) {
          if (_controller.page!.round() != _controller.page) {
            return; // Check if it's not already animating
          }
          if (_controller.page! - 1 >= _controller.position.minScrollExtent) {
            if (_scrollController.position.pixels != 0 && isLastPage) {
              //closes footer
              // _scrollController.jumpTo(0.0);
              isOnFooter = false;
              setState(() {});
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.ease,
              );
            } else {
              //scrollup while footer is not shown
              if (!_scrollController.position.isScrollingNotifier.value &&
                  !_officerScrollController.hasClients) {
                //scroll up while officer tab is not showing
                _controller.previousPage(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.ease,
                );
              } else {
                if (_officerScrollController.hasClients) {
                  //on footer with officers
                  if (_officerScrollController.position.atEdge &&
                      _officerScrollController.position.pixels == 0) {
                    _controller.previousPage(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.ease,
                    );
                  }
                } else {
                  //on footer without officers
                  if (!_scrollController.position.isScrollingNotifier.value) {
                    _controller.previousPage(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.ease,
                    );
                  }
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
                  if (widget.officers.isNotEmpty)
                    MyOfficers(
                      pres: presModel!,
                      vp: vpModel!,
                      sec: secModel!,
                      astSec: astSecModel!,
                      tres: tresModel!,
                      aud: audModel!,
                      astAud: astAudModel!,
                      bodModels: bodModels,
                      isOnFooter: isOnFooter,
                      officerScrollController: _officerScrollController,
                    ),
                ],
              ),
            ),
            MyFooter(
              goToPage: goToPage,
              officeAddress: widget.officeAddress,
              contactNo: widget.contactNo,
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
      required this.isOnFooter,
      required this.pres,
      required this.vp,
      required this.sec,
      required this.astSec,
      required this.tres,
      required this.aud,
      required this.astAud,
      required this.bodModels});
  final ScrollController officerScrollController;
  final bool isOnFooter;
  final CandidateModel pres, vp, sec, astSec, tres, aud, astAud;
  final List<CandidateModel> bodModels;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 40.h,
      ),
      child: Column(
        children: [
          Text(
            "HOA Officers",
            style: TextStyle(
              fontSize: 10.sp,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
              shadows: [
                Shadow(
                  offset: const Offset(1.0, 1.0),
                  blurRadius: 1.0,
                  color: isDarkMode
                      ? const Color.fromARGB(50, 255, 255, 255)
                      : const Color.fromARGB(90, 0, 0, 0),
                ),
                Shadow(
                  offset: const Offset(1.0, 1.0),
                  blurRadius: 1.0,
                  color: isDarkMode
                      ? const Color.fromARGB(50, 255, 255, 255)
                      : const Color.fromARGB(90, 0, 0, 0),
                ),
              ],
            ),
          ),
          Text(
            "The responsible officers who keeps our environment safe and reputable.",
            style: TextStyle(
              fontSize: 5.sp,
            ),
          ),
          Expanded(
            child: GridView(
              padding:
                  EdgeInsets.only(top: 50, bottom: 50, left: 15.w, right: 15.w),
              physics: isOnFooter ? const NeverScrollableScrollPhysics() : null,
              controller: officerScrollController,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                childAspectRatio: 250 / 250,
                mainAxisSpacing: 75,
                crossAxisSpacing: 10,
              ),
              children: [
                OfficerAvatar(
                  image: pres.profilePicture,
                  name: "${pres.firstName} ${pres.lastName}",
                  position: "President",
                ),
                OfficerAvatar(
                  image: vp.profilePicture,
                  name: "${vp.firstName} ${vp.lastName}",
                  position: "Vice President",
                ),
                OfficerAvatar(
                  image: sec.profilePicture,
                  name: "${sec.firstName} ${sec.lastName}",
                  position: "Secretary",
                ),
                OfficerAvatar(
                  image: astSec.profilePicture,
                  name: "${astSec.firstName} ${astSec.lastName}",
                  position: "Assistant Secretary",
                ),
                OfficerAvatar(
                  image: tres.profilePicture,
                  name: "${tres.firstName} ${tres.lastName}",
                  position: "Treasurer",
                ),
                OfficerAvatar(
                  image: aud.profilePicture,
                  name: "${aud.firstName} ${aud.lastName}",
                  position: "Auditor",
                ),
                OfficerAvatar(
                  image: astAud.profilePicture,
                  name: "${astAud.firstName} ${astAud.lastName}",
                  position: "Assistant Auditor",
                ),
                OfficerAvatar(
                  image: bodModels[0].profilePicture,
                  name: "${bodModels[0].firstName} ${bodModels[0].lastName}",
                  position: "Board of Director",
                ),
                OfficerAvatar(
                  image: bodModels[1].profilePicture,
                  name: "${bodModels[1].firstName} ${bodModels[1].lastName}",
                  position: "Board of Director",
                ),
                OfficerAvatar(
                  image: bodModels[2].profilePicture,
                  name: "${bodModels[2].firstName} ${bodModels[2].lastName}",
                  position: "Board of Director",
                ),
                OfficerAvatar(
                  image: bodModels[3].profilePicture,
                  name: "${bodModels[3].firstName} ${bodModels[3].lastName}",
                  position: "Board of Director",
                ),
                OfficerAvatar(
                  image: bodModels[4].profilePicture,
                  name: "${bodModels[4].firstName} ${bodModels[4].lastName}",
                  position: "Board of Director",
                ),
                OfficerAvatar(
                  image: bodModels[5].profilePicture,
                  name: "${bodModels[5].firstName} ${bodModels[5].lastName}",
                  position: "Board of Director",
                ),
                OfficerAvatar(
                  image: bodModels[6].profilePicture,
                  name: "${bodModels[6].firstName} ${bodModels[6].lastName}",
                  position: "Board of Director",
                ),
                OfficerAvatar(
                  image: bodModels[7].profilePicture,
                  name: "${bodModels[7].firstName} ${bodModels[7].lastName}",
                  position: "Board of Director",
                ),
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
    required this.officeAddress,
    required this.contactNo,
  });
  final Function goToPage;
  final String officeAddress, contactNo;

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
                      officeAddress,
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
                          contactNo,
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
          SizedBox(
            height: 8.w,
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
          "Quality of Living",
          style: TextStyle(
            fontSize: 10.sp,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
            shadows: [
              Shadow(
                offset: const Offset(1.0, 1.0),
                blurRadius: 1.0,
                color: isDarkMode
                    ? const Color.fromARGB(50, 255, 255, 255)
                    : const Color.fromARGB(90, 0, 0, 0),
              ),
              Shadow(
                offset: const Offset(1.0, 1.0),
                blurRadius: 1.0,
                color: isDarkMode
                    ? const Color.fromARGB(50, 255, 255, 255)
                    : const Color.fromARGB(90, 0, 0, 0),
              ),
            ],
          ),
        ),
        const Spacer(),
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
        // const SizedBox(
        //   height: 20,
        // ),
        // Text(
        //   "The quality of living that you deserve to have",
        //   style: Theme.of(context).textTheme.titleMedium!,
        // ),
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
      width: 90.w,
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 15.w,
              child: Icon(icon,
                  size: 20.w, color: Theme.of(context).colorScheme.background),
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
              style: TextStyle(fontSize: 5.sp),
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
                      "ABOUT",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      header,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        shadows: [
                          Shadow(
                            offset: const Offset(1.0, 1.0),
                            blurRadius: 1.0,
                            color: isDarkMode
                                ? const Color.fromARGB(50, 255, 255, 255)
                                : const Color.fromARGB(90, 0, 0, 0),
                          ),
                          Shadow(
                            offset: const Offset(1.0, 1.0),
                            blurRadius: 1.0,
                            color: isDarkMode
                                ? const Color.fromARGB(50, 255, 255, 255)
                                : const Color.fromARGB(90, 0, 0, 0),
                          ),
                        ],
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
          shadows: [
            // Shadow(
            //     // bottomLeft
            //     offset: Offset(-1.5, -1.5),
            //     color: Colors.white),
            // Shadow(
            //     // bottomRight
            //     offset: Offset(1.5, -1.5),
            //     color: Colors.white),
            // Shadow(
            //     // topRight
            //     offset: Offset(1.5, 1.5),
            //     color: Colors.white),
            // Shadow(
            //     // topLeft
            //     offset: Offset(-1.5, 1.5),
            //     color: Colors.white),
            Shadow(
              offset: const Offset(5.0, 5.0),
              blurRadius: 3.0,
              color: isDarkMode
                  ? const Color.fromARGB(50, 255, 255, 255)
                  : const Color.fromARGB(90, 0, 0, 0),
            ),
            Shadow(
              offset: const Offset(5.0, 5.0),
              blurRadius: 3.0,
              color: isDarkMode
                  ? const Color.fromARGB(50, 255, 255, 255)
                  : const Color.fromARGB(90, 0, 0, 0),
            ),
          ]),
      softWrap: true,
    );
  }
}
