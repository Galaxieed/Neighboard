import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/candidates_model.dart';
import 'package:neighboard/routes/routes.dart';

class LandingPageMobile extends StatefulWidget {
  const LandingPageMobile({
    super.key,
    required this.header,
    required this.subHeader,
    required this.about,
    required this.bgImage,
    required this.aboutImage,
    required this.subdName,
    required this.officers,
  });

  final String subdName, header, subHeader, about, bgImage, aboutImage;
  final List<CandidateModel> officers;

  @override
  State<LandingPageMobile> createState() => _LandingPageMobileState();
}

class _LandingPageMobileState extends State<LandingPageMobile> {
  CandidateModel? presModel,
      vpModel,
      secModel,
      astSecModel,
      tresModel,
      audModel,
      astAudModel;
  List<CandidateModel> bodModels = [];
  getOfficers() async {
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
    // TODO: implement initState
    super.initState();
    getOfficers();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: const PageScrollPhysics(),
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
          ),
      ],
    );
  }
}

class MyOfficers extends StatelessWidget {
  const MyOfficers({
    super.key,
    required this.pres,
    required this.vp,
    required this.sec,
    required this.astSec,
    required this.tres,
    required this.aud,
    required this.astAud,
    required this.bodModels,
  });
  final CandidateModel pres, vp, sec, astSec, tres, aud, astAud;
  final List<CandidateModel> bodModels;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40.h, left: 15.w, right: 15.w),
      child: Column(
        children: [
          Text(
            "HOA Officers",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: GridView(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 200 / 300,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: CircleAvatar(
            radius: 75,
            backgroundColor: _isHovering
                ? Theme.of(context).colorScheme.inversePrimary
                : null,
            child: ClipOval(
              child: CircleAvatar(
                radius: 70,
                child: widget.image == ""
                    ? Image.asset(guestIcon)
                    : FadeInImage.assetNetwork(
                        placeholder: guestIcon, image: widget.image),
              ),
            ),
          ),
        ),
        Text(
          widget.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          widget.position,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall!,
        ),
      ],
    );
  }
}

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 50,
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
          const Spacer(),
          Text(
            "Quality of Living",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                offersCard(
                  context,
                  Icons.location_city_outlined,
                  "Close to Town",
                  "There are various establishments, such as mall, churches, and resort within the the area.",
                ),
                const SizedBox(width: 20),
                offersCard(
                  context,
                  Icons.nature_people_rounded,
                  "Clean Environment",
                  "Subdivision is surrounded by trees and plants, and the streets are kept clean.",
                ),
                const SizedBox(width: 20),
                offersCard(
                  context,
                  Icons.security_outlined,
                  "Secured Community",
                  "The subdivision is secured due to their 24hrs duty of security guards and curfew hours.",
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
          // const Spacer(),
          // Text(
          //   "The quality of living \nthat you deserve to have",
          //   textAlign: TextAlign.center,
          //   style: Theme.of(context).textTheme.titleMedium!,
          // ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 50,
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
      ),
    );
  }

  Container offersCard(
    BuildContext context,
    IconData icon,
    String title,
    String details,
  ) {
    return Container(
      height: 275,
      width: 250,
      padding: const EdgeInsets.all(16),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(30),
      //   color: Theme.of(context).colorScheme.inversePrimary,
      // ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 50,
              child: Icon(
                icon,
                size: 55,
                color: Theme.of(context).colorScheme.background,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.w900),
              overflow: TextOverflow.fade,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              details,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall!,
            ),
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
    return Stack(
      children: [
        Positioned(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(180),
                bottomRight: Radius.circular(180)),
            child: Container(
              height: MediaQuery.of(context).size.height / 2.5,
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
            ),
          ),
        ),
        Positioned(
          child: ClipRRect(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: 20.sp, right: 20.sp, left: 20.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    height: 30.h,
                  ),
                  LandPageHeader(header: header),
                  SizedBox(
                    height: 30.h,
                  ),
                  LandPageHeaderSmall(
                    header: subHeader,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  LandPageButton(label: 'Explore', callback: Routes().navigate),
                  SizedBox(
                    height: 30.h,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
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
    return Column(
      children: [
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    header,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
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
                  LandPageHeaderSmall(
                    header: subHeader,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: aboutImage == ''
                    ? const AssetImage(noImage) as ImageProvider
                    : NetworkImage(aboutImage),
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                opacity: ccLandPageBGOpacity,
              ),
            ),
          ),
        ),
      ],
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
    return ElevatedButton(
      onPressed: () {
        callback('Forum', context);
      },
      style: ElevatedButton.styleFrom(
          //padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
          backgroundColor: ccExploreButtonBGColor(context),
          foregroundColor: ccExploreButtonFGColor(context),
          minimumSize: Size(double.infinity, 40.h)),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20.sp,
        ),
      ),
    );
  }
}

class LandPageHeaderSmall extends StatelessWidget {
  const LandPageHeaderSmall({
    super.key,
    required this.header,
    required this.color,
  });

  final String header;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      header,
      style: TextStyle(
        fontSize: 18.sp,
        color: color,
      ),
      textAlign: TextAlign.left,
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
          fontSize: 37.sp,
          color: ccHeaderFGColor(context),
          letterSpacing: 3,
          wordSpacing: 1,
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
              offset: const Offset(3.0, 3.0),
              blurRadius: 3.0,
              color: isDarkMode
                  ? const Color.fromARGB(50, 255, 255, 255)
                  : const Color.fromARGB(90, 0, 0, 0),
            ),
            Shadow(
              offset: const Offset(3.0, 3.0),
              blurRadius: 3.0,
              color: isDarkMode
                  ? const Color.fromARGB(50, 255, 255, 255)
                  : const Color.fromARGB(90, 0, 0, 0),
            ),
          ]),
      textAlign: TextAlign.center,
      softWrap: true,
    );
  }
}
