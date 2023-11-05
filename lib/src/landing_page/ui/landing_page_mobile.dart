import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/routes/routes.dart';

class LandingPageMobile extends StatelessWidget {
  const LandingPageMobile({
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
  Widget build(BuildContext context) {
    return PageView(
      physics: const PageScrollPhysics(),
      scrollDirection: Axis.vertical,
      children: [
        HomePage(
          header: header,
          subHeader: subHeader,
          bgImage: bgImage,
        ),
        const OffersPage(),
        AboutPage(
          header: subdName,
          subHeader: about,
          aboutImage: aboutImage,
        ),
        const MyOfficers(),
      ],
    );
  }
}

class MyOfficers extends StatefulWidget {
  const MyOfficers({
    super.key,
  });

  @override
  State<MyOfficers> createState() => _MyOfficersState();
}

class _MyOfficersState extends State<MyOfficers> {
  final gridController = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    gridController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40.h, left: 15.w, right: 15.w),
      child: Column(
        children: [
          Text(
            "MEET THE OFFICERS",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
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
              controller: gridController,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 200 / 300,
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
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          widget.position,
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
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.bold),
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
              backgroundColor: Theme.of(context).primaryColor,
              radius: 50,
              child: Icon(
                icon,
                size: 55,
                color: Colors.white,
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
                  LandPageHeader(header: header),
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
      textAlign: TextAlign.center,
      softWrap: true,
    );
  }
}
