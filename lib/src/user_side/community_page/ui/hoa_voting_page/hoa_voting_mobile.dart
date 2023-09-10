import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HOAVotingMobile extends StatefulWidget {
  const HOAVotingMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  State<HOAVotingMobile> createState() => _HOAVotingMobileState();
}

class _HOAVotingMobileState extends State<HOAVotingMobile> {
  String? chosenPresident;
  String? chosenVicePresident;
  String? chosenBoardOfDirector;
  TabController controller(context) => DefaultTabController.of(context);

  @override
  void dispose() {
    // TODO: implement dispose
    controller(context).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Board of Directors Election"),
        centerTitle: true,
        actions: [
          NavBarCircularImageDropDownButton(
            callback: Routes().navigate,
            isAdmin: false,
          ),
          SizedBox(
            width: 2.5.w,
          )
        ],
      ),
      drawer: widget.deviceScreenType == DeviceScreenType.mobile
          ? const NavDrawer()
          : null,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: DefaultTabController(
                initialIndex: 0,
                length: 3,
                child: Builder(
                  builder: (BuildContext context) => Column(
                    children: [
                      Expanded(
                        child: TabBarView(
                          children: [
                            presidentTab("PRESIDENT"),
                            presidentTab("VICE PRESIDENT"),
                            presidentTab("BOARD OF DIRECTORS"),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: controller(context).index > 0,
                            child: ElevatedButton(
                              onPressed: () {
                                TabController ctrl = controller(context);
                                if (!ctrl.indexIsChanging && (ctrl.index > 0)) {
                                  ctrl.animateTo(ctrl.index - 1);
                                  setState(() {});
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    ccHOANextButtonBGColor(context),
                                foregroundColor:
                                    ccHOANextButtonFGColor(context),
                              ),
                              child: const Text("Back"),
                            ),
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              TabController ctrl = controller(context);
                              if (!ctrl.indexIsChanging && ctrl.index < 2) {
                                ctrl.animateTo(ctrl.index + 1);
                                setState(() {});
                              }
                              if (!ctrl.indexIsChanging && ctrl.index == 2) {
                                print("save");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ccHOANextButtonBGColor(context),
                              foregroundColor: ccHOANextButtonFGColor(context),
                            ),
                            child: Text(controller(context).index < 2
                                ? "Next"
                                : "Save"),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container hoaTitleBanner(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      color: ccHOATitleBannerColor(context),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget presidentTab(String title) {
    return Column(
      children: [
        hoaTitleBanner(context, title),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.only(
                left: 15.w, right: 15.w, bottom: 15.h, top: 15.h),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              childAspectRatio: 350 / 350,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
            ),
            itemCount: 15,
            itemBuilder: (context, index) {
              return candidatesCard(index, context, title);
            },
          ),
        ),
      ],
    );
  }

  Widget candidatesCard(int index, BuildContext context, String position) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (position == "PRESIDENT") {
            chosenPresident = index.toString();
          }
          if (position == "VICE PRESIDENT") {
            chosenVicePresident = index.toString();
          }
          if (position == "BOARD OF DIRECTORS") {
            chosenBoardOfDirector = index.toString();
          }
          setState(() {});
        },
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Radio(
                value: index.toString(),
                groupValue: position == "PRESIDENT"
                    ? chosenPresident
                    : position == "VICE PRESIDENT"
                        ? chosenVicePresident
                        : position == "BOARD OF DIRECTORS"
                            ? chosenBoardOfDirector
                            : null,
                onChanged: (val) {
                  if (position == "PRESIDENT") {
                    chosenPresident = val.toString();
                  }
                  if (position == "VICE PRESIDENT") {
                    chosenVicePresident = val.toString();
                  }
                  if (position == "BOARD OF DIRECTORS") {
                    chosenBoardOfDirector = val.toString();
                  }
                  setState(() {});
                },
              ),
            ),
            const Expanded(
              child: FittedBox(
                child: CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              "Sample Name",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              "Blk 12 Lot 18, Zaragoza St.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(
              height: 25.h,
            ),
          ],
        ),
      ),
    );
  }
}
