import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/widgets/others/tab_header.dart';

class CandidatesDesktop extends StatefulWidget {
  const CandidatesDesktop({super.key, required this.drawer});

  final Function drawer;

  @override
  State<CandidatesDesktop> createState() => _CandidatesDesktopState();
}

class _CandidatesDesktopState extends State<CandidatesDesktop> {
  TabController controller(context) => DefaultTabController.of(context);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabHeader(
            title: "Candidates List",
            callback: () {
              widget.drawer();
            },
          ),
          SizedBox(
            height: 20.h,
          ),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Builder(
                builder: (BuildContext context) => Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        children: [
                          hoaAdminTab(context, "PRESIDENT"),
                          hoaAdminTab(context, "VICE PRESIDENT"),
                          hoaAdminTab(context, "BOARD OF DIRECTORS"),
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
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ccHOANextButtonBGColor(context),
                            foregroundColor: ccHOANextButtonFGColor(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                              controller(context).index < 2 ? "Next" : "Save"),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Column hoaAdminTab(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_add_alt),
          label: const Text("Add Candidate"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
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
              return candidatesCard(context);
            },
          ),
        ),
      ],
    );
  }

  Widget candidatesCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SizedBox(
            height: 25.h,
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
            height: 5.h,
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            label: const Text("Edit"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(
            height: 25.h,
          ),
        ],
      ),
    );
  }
}
