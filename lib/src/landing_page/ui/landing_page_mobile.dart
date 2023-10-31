
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
            "ABOUT",
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
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
      height: 350,
      width: 300,
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
              radius: 60,
              child: Icon(
                icon,
                size: 65,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.w900),
              overflow: TextOverflow.fade,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              details,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!,
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
            //height: MediaQuery.of(context).size.height / 2.75,
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
