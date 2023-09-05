import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';

class HOAVotingDesktop extends StatefulWidget {
  const HOAVotingDesktop({super.key});

  @override
  State<HOAVotingDesktop> createState() => _HOAVotingDesktopState();
}

class _HOAVotingDesktopState extends State<HOAVotingDesktop> {
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
      appBar: const NavBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 15,
            ),
            Text(
              'Board of Directors Election',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: gridOfCandidates(),
            ),
          ],
        ),
      ),
    );
  }

  DefaultTabController gridOfCandidates() {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Builder(
        builder: (BuildContext context) => Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  hoaTab("PRESIDENT"),
                  hoaTab("VICE PRESIDENT"),
                  hoaTab("BOARD OF DIRECTORS"),
                ],
              ),
            ),
            SizedBox(
              height: 15.h,
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
                      backgroundColor: ccHOANextButtonBGColor(context),
                      foregroundColor: ccHOANextButtonFGColor(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
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
                      //TODO: save the voted HOA
                      print("save");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ccHOANextButtonBGColor(context),
                    foregroundColor: ccHOANextButtonFGColor(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(controller(context).index < 2 ? "Next" : "Save"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget hoaTab(String title) {
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
              return voteCandidatesCard(index, context, title);
            },
          ),
        ),
      ],
    );
  }

  Widget voteCandidatesCard(int index, BuildContext context, String position) {
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
