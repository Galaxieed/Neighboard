import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/models/election_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/models/voter_model.dart';
import 'package:neighboard/src/admin_side/hoa_voting/candidates/candidates_function.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_function.dart';
import 'package:neighboard/widgets/others/tab_header.dart';
import 'package:intl/intl.dart';

class VotersDesktop extends StatefulWidget {
  const VotersDesktop({super.key, required this.drawer});
  final Function drawer;
  @override
  State<VotersDesktop> createState() => _VotersDesktopState();
}

class _VotersDesktopState extends State<VotersDesktop> {
  TabController mycontroller(context) => DefaultTabController.of(context);
  List<VoterModel> voterModels = [];
  List<ElectionModel> electionModels = [];
  List<UserModel> userModels = [];
  List<UserModel> notVotedUsersModel = [];

  List<DropdownMenuItem<String>> dropdownItems = [];
  String? selectedVal;
  bool isLoading = true;

  getAllElection() async {
    electionModels = await CandidatesFunctions.getAllElection() ?? [];
    electionModels.sort((a, b) => b.electionId.compareTo(a.electionId));
    for (ElectionModel election in electionModels) {
      String dateText =
          '${DateFormat.yMMMd().format(DateTime.parse(election.electionStartDate))} - ${DateFormat.yMMMd().format(DateTime.parse(election.electionEndDate))}';
      var newItem = DropdownMenuItem(
        value: election.electionId,
        child: Text(dateText),
      );
      dropdownItems.add(newItem);
      selectedVal = election.electionId;
      getAllVoters(election.electionId);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  getAllVoters(String electionId) async {
    voterModels = await VotersFunction.getAllVoters(electionId) ?? [];

    //remove the admin from the list of users
    userModels =
        userModels.where((element) => element.role != "ADMIN").toList();

    //deduct the voter to users then save to not voted
    if (voterModels.isEmpty) {
      notVotedUsersModel = userModels;
    } else {
      notVotedUsersModel = userModels
          .where(
              (element) => voterModels.any((v) => v.voterId != element.userId))
          .toList();
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  getAllUsers() async {
    userModels = await VotersFunction.getAllUsers() ?? [];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllUsers();
    getAllElection();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabHeader(
            title: "List of Voters",
            callback: () {
              widget.drawer();
            },
          ),
          SizedBox(
            height: 10.h,
          ),
          Expanded(child: tableTabs()),
        ],
      ),
    );
  }

  DefaultTabController tableTabs() {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Builder(
        builder: (context) => Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    TabController ctrl = mycontroller(context);
                    if (!ctrl.indexIsChanging && ctrl.index > 0) {
                      ctrl.animateTo(ctrl.index - 1);
                      setState(() {});
                    }
                  },
                  style: mycontroller(context).index == 0
                      ? ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
                        )
                      : null,
                  child: const Text("Voted"),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    TabController ctrl = mycontroller(context);
                    if (!ctrl.indexIsChanging && ctrl.index < 1) {
                      ctrl.animateTo(ctrl.index + 1);
                      setState(() {});
                    }
                  },
                  style: mycontroller(context).index == 1
                      ? ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
                        )
                      : null,
                  child: const Text("Not Voted"),
                ),
                const Spacer(),
                DropdownButton(
                  underline: Container(),
                  hint: const Text("Election History"),
                  value: selectedVal,
                  items: dropdownItems,
                  onChanged: (String? value) {
                    getAllVoters(value!);
                    setState(() {
                      selectedVal = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  myTable(voted: true),
                  myTable(voted: false),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Table myTable({required bool voted}) {
    return Table(
      border: TableBorder.all(style: BorderStyle.solid),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.withOpacity(.5)),
          children: [
            tableHeaderText("Voter ID"),
            tableHeaderText("Name"),
            tableHeaderText("Address"),
            if (voted) tableHeaderText("Date"),
          ],
        ),
        if (voted)
          for (VoterModel v in voterModels)
            TableRow(
              children: [
                tableContextText(v.voterId),
                tableContextText(v.name),
                tableContextText(v.address),
                tableContextText(v.timeVoted),
              ],
            )
        else
          for (UserModel u in notVotedUsersModel)
            TableRow(
              children: [
                tableContextText(u.userId),
                tableContextText("${u.lastName}, ${u.firstName}"),
                tableContextText(u.address),
              ],
            ),
      ],
    );
  }

  Widget tableContextText(String text) => Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(text),
      );

  Widget tableHeaderText(String text) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
      );
}
