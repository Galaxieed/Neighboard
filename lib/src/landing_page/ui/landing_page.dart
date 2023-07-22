import 'package:flutter/material.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/constants/constants.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: PageView(
          clipBehavior: Clip.antiAlias,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          children: const [
            HomePage(
                header: 'LA ALDEA \nCOMMUNITY \nFORUM',
                subHeader:
                    'A place where you can freely share your thoughts with one'
                    ' another.\nShare your ideas and ask your fellow '
                    'residents, Ka-Aldea!'),
            AboutPage(
                header: 'ABOUT',
                subHeader: 'La Aldea Subdivision is situated along McArthur'
                    ' Highway in the so-called Golden Triangle in'
                    ' Guiguinto, Bulacan which serves as the center'
                    ' of Bulacan. \n\nHighly accessible having '
                    'the distinct advantage of being located at '
                    'a short distance (approximately 1.5kms) from '
                    'the convergence of Bulacan\'s three major '
                    'national road networks, otherwise known as '
                    'the Central Bulacan Interchange.'),
          ]),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({
    super.key,
    required this.header,
    required this.subHeader,
  });

  final String header, subHeader;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, bottom: 60, left: 60),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
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
                        image: AssetImage(homeImage), fit: BoxFit.cover)),
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
  });

  final String header, subHeader;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(homepageImage),
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          opacity: 50,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 60),
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
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LandPageButton(
                        label: 'Explore Forum!', callback: Routes().navigate),
                    const SizedBox(
                      height: 150,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.headlineSmall,
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
      style: Theme.of(context).textTheme.headlineSmall,
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
      style: Theme.of(context).textTheme.displayLarge,
      softWrap: true,
    );
  }
}
