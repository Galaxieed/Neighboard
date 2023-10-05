import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';

import 'package:neighboard/routes/routes.dart';

class LandingPageDesktop extends StatelessWidget {
  const LandingPageDesktop({
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
      padding: EdgeInsets.only(top: 30.h, bottom: 30.h, left: 15.w),
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
                      header,
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
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
                flipX: true,
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
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 30.w),
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
                  // Expanded(
                  //   flex: 2,
                  //   child: Container(
                  //     padding:
                  //         EdgeInsets.symmetric(vertical: 5.h, horizontal: 30.w),
                  //     child: Column(
                  //       mainAxisSize: MainAxisSize.max,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [],
                  //     ),
                  //   ),
                  // ),
                  // Expanded(
                  //   flex: 1,
                  //   child: Padding(
                  //     padding:
                  //         EdgeInsets.symmetric(vertical: 5.h, horizontal: 30.w),
                  //     child: Column(
                  //       mainAxisSize: MainAxisSize.max,
                  //       mainAxisAlignment: MainAxisAlignment.end,
                  //       children: [
                  //         SizedBox(height: MediaQuery.sizeOf(context).height / 2),
                  //       ],
                  //     ),
                  //   ),
                  // ),
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
