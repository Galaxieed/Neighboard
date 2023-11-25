import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/candidates_model.dart';
import 'package:neighboard/models/election_model.dart';
import 'package:neighboard/src/admin_side/hoa_voting/candidates/candidates_function.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/widgets/others/tab_header.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

class VotingDesktop extends StatefulWidget {
  const VotingDesktop(
      {super.key, required this.drawer, required this.deviceScreenType});

  final Function drawer;
  final DeviceScreenType deviceScreenType;

  @override
  State<VotingDesktop> createState() => _VotingDesktopState();
}

class _VotingDesktopState extends State<VotingDesktop> {
  TabController mycontroller(context) => DefaultTabController.of(context);
  List<ElectionModel> electionModels = [];
  List<CandidateModel> candidateModels = [];
  List<DropdownMenuItem<String>> dropdownItems = [];
  String? selectedVal;

  bool isLoading = true;

  getAllCandidates(String electionId) async {
    candidateModels =
        await CandidatesFunctions.getAllCandidate(electionId) ?? [];
    candidateModels.sort(((a, b) => b.noOfVotes.compareTo(a.noOfVotes)));
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  getAllElection() async {
    electionModels = await CandidatesFunctions.getAllElection() ?? [];
    electionModels.sort((a, b) => a.electionId.compareTo(b.electionId));
    for (ElectionModel election in electionModels) {
      String dateText =
          DateFormat.yMMMd().format(DateTime.parse(election.electionStartDate));

      var newItem = DropdownMenuItem(
        value: election.electionId,
        child: Text(dateText),
      );
      dropdownItems.add(newItem);
      selectedVal = election.electionId;
      getAllCandidates(election.electionId);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllElection();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : Container(
            padding: EdgeInsets.symmetric(
                vertical: widget.deviceScreenType == DeviceScreenType.desktop
                    ? 30.h
                    : 15.h,
                horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.deviceScreenType == DeviceScreenType.desktop)
                  TabHeader(
                    title: "Voting Analytics",
                    callback: () {
                      widget.drawer();
                    },
                  ),
                if (widget.deviceScreenType == DeviceScreenType.desktop)
                  SizedBox(
                    height: 10.h,
                  ),
                Align(
                  alignment: Alignment.topRight,
                  child: DropdownButton(
                      underline: Container(),
                      hint: const Text("Election History"),
                      value: selectedVal,
                      items: dropdownItems,
                      onChanged: (String? value) {
                        getAllCandidates(value!);
                        setState(() {
                          selectedVal = value;
                        });
                      }),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Expanded(
                  child: candidatesTabs(),
                ),
              ],
            ),
          );
  }

  DefaultTabController candidatesTabs() {
    return DefaultTabController(
      initialIndex: 0,
      length: 8,
      child: Builder(
        builder: (context) => Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  hoaAdminTab(context, "PRESIDENT"),
                  hoaAdminTab(context, "VICE PRESIDENT"),
                  hoaAdminTab(context, "SECRETARY"),
                  hoaAdminTab(context, "ASSISTANT SECRETARY"),
                  hoaAdminTab(context, "TREASURER"),
                  hoaAdminTab(context, "AUDITOR"),
                  hoaAdminTab(context, "ASSISTANT AUDITOR"),
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
                  visible: mycontroller(context).index > 0,
                  child: ElevatedButton(
                    onPressed: () {
                      TabController ctrl = mycontroller(context);
                      if (!ctrl.indexIsChanging && ctrl.index > 0) {
                        ctrl.animateTo(ctrl.index - 1);
                        setState(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: ccHOANextButtonFGColor(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 1,
                    ),
                    child: const Text("Back"),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                mycontroller(context).index >= 7
                    ? Container()
                    : ElevatedButton(
                        onPressed: () {
                          TabController ctrl = mycontroller(context);
                          if (!ctrl.indexIsChanging && ctrl.index < 7) {
                            ctrl.animateTo(ctrl.index + 1);
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ccHOANextButtonBGColor(context),
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text("Next"))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Column hoaAdminTab(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            itemCount: candidateModels
                .where((element) => element.position == title)
                .length,
            itemBuilder: (context, index) {
              CandidateModel candidate = candidateModels
                  .where((element) => element.position == title)
                  .elementAt(index);
              return candidatesCard(context, title, candidate);
            },
          ),
        )
      ],
    );
  }

  Widget candidatesCard(
      BuildContext context, String position, CandidateModel candidate) {
    return Card(
      child: Column(
        children: [
          SizedBox(
            height: 25.h,
          ),
          Expanded(
            child: FittedBox(
              child: candidate.profilePicture == ''
                  ? const CircleAvatar(
                      child: Icon(Icons.person),
                    )
                  : CircleAvatar(
                      backgroundImage: NetworkImage(candidate.profilePicture),
                    ),
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            "${candidate.firstName} ${candidate.lastName}",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            candidate.address,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(
            height: 5.h,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              "Votes: ${candidate.noOfVotes}",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }
}
