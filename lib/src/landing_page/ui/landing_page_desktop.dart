import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
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
                    LandPageHeader(header: header),
                    const SizedBox(
                      height: 20,
                    ),
                    LandPageHeaderSmall(header: subHeader)
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
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(aboutImage), fit: BoxFit.cover)),
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
          image: AssetImage(bgImage),
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          opacity: 50,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.h, horizontal: 30.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LandPageHeader(header: header),
                      LandPageHeaderSmall(header: subHeader),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.h, horizontal: 30.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height / 2),
                      LandPageButton(
                          label: 'Explore', callback: Routes().navigate),
                    ],
                  ),
                ),
              ),
            ],
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
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        backgroundColor: ccExploreButtonBGColor(context),
        foregroundColor: ccExploreButtonFGColor(context),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 6.sp,
        ),
      ),
    );
  }
}

class LandPageHeaderSmall extends StatelessWidget {
  const LandPageHeaderSmall({
    super.key,
    required this.header,
  });

  final String header;

  @override
  Widget build(BuildContext context) {
    return Text(
      header,
      style: TextStyle(
        fontSize: 7.sp,
        color: ccSubHeaderFGColor(context),
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
        fontSize: 13.sp,
        color: ccHeaderFGColor(context),
      ),
      softWrap: true,
    );
  }
}
