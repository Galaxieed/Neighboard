import 'dart:ui';

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
  });

  final String header, subHeader, about, bgImage, aboutImage;

  @override
  Widget build(BuildContext context) {
    return PageView(
      clipBehavior: Clip.antiAlias,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      children: [
        HomePage(
          header: header,
          subHeader: subHeader,
          bgImage: bgImage,
        ),
        AboutPage(
          header: 'ABOUT',
          subHeader: about,
          aboutImage: aboutImage,
        ),
      ],
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
      child: ClipRRect(
        child: Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    LandPageHeader(header: header),
                    SizedBox(
                      height: 30.h,
                    ),
                    LandPageHeaderSmall(
                      header: subHeader,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 60.h,
                    ),
                    LandPageButton(
                        label: 'Explore', callback: Routes().navigate),
                  ],
                ),
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
        fontSize: 20.sp,
        color: color,
      ),
      textAlign: TextAlign.center,
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
          letterSpacing: 5,
          wordSpacing: 2,
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
    return Container(
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
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                LandPageHeader(header: header),
                const SizedBox(
                  height: 20,
                ),
                LandPageHeaderSmall(
                  header: subHeader,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
