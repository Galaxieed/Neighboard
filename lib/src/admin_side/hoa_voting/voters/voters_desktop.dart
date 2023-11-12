import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/models/election_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/models/voter_model.dart';
import 'package:neighboard/src/admin_side/hoa_voting/candidates/candidates_function.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_function.dart';
import 'package:neighboard/widgets/others/tab_header.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

class VotersDesktop extends StatefulWidget {
  const VotersDesktop(
      {super.key, required this.drawer, required this.deviceScreenType});
  final Function drawer;
  final DeviceScreenType deviceScreenType;
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
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    electionModels = await CandidatesFunctions.getAllElection() ?? [];
    electionModels.sort((a, b) => a.electionId.compareTo(b.electionId));
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
              (element) => !voterModels.any((v) => v.voterId == element.userId))
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
    super.initState();
    getAllUsers();
    getAllElection();
  }

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical:
              widget.deviceScreenType == DeviceScreenType.desktop ? 30.h : 15.h,
          horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.deviceScreenType == DeviceScreenType.desktop)
            TabHeader(
              title: "List of Voters",
              callback: () {
                widget.drawer();
              },
            ),
          if (widget.deviceScreenType == DeviceScreenType.desktop)
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mycontroller(context).index == 0
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    foregroundColor: mycontroller(context).index == 0
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mycontroller(context).index == 1
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    foregroundColor: mycontroller(context).index == 1
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text("Not Voted"),
                ),
                const Spacer(),
                if (widget.deviceScreenType == DeviceScreenType.desktop)
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
            if (widget.deviceScreenType != DeviceScreenType.desktop)
              Align(
                alignment: Alignment.centerRight,
                child: DropdownButton(
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
              ),
            if (widget.deviceScreenType == DeviceScreenType.desktop)
              const SizedBox(
                height: 20,
              ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  theTable(voted: true),
                  theTable(voted: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget theTable({required bool voted}) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: PaginatedDataTable(
        rowsPerPage: _rowsPerPage,
        availableRowsPerPage: const <int>[5, 10, 20],
        onRowsPerPageChanged: (value) {
          if (value != null) {
            setState(() {
              _rowsPerPage = value;
            });
          }
        },
        columns: [
          DataColumn(
            label: Text(
              "Voter ID",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "Name",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "Address",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (voted)
            DataColumn(
              label: Text(
                "Date",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
        ],
        source: VotersDataSource(voted, voterModels, notVotedUsersModel),
      ),
    );
  }
}

class VotersDataSource extends DataTableSource {
  final int _selectedCount = 0;
  final bool voted;
  final List<VoterModel> voterModels;
  final List<UserModel> notVotedUsersModel;
  VotersDataSource(this.voted, this.voterModels, this.notVotedUsersModel);

  @override
  DataRow? getRow(int index) {
    if (voted) {
      assert(index >= 0);
      if (index >= voterModels.length) return null;
      final VoterModel voterModel = voterModels[index];
      return DataRow.byIndex(
        index: index,
        selected: false,
        cells: [
          DataCell(Text(voterModel.voterId)),
          DataCell(Text(voterModel.name)),
          DataCell(Text(voterModel.address)),
          DataCell(Text(voterModel.timeVoted)),
        ],
      );
    } else {
      assert(index >= 0);
      if (index >= notVotedUsersModel.length) return null;
      final UserModel notVotedUser = notVotedUsersModel[index];
      return DataRow.byIndex(
        index: index,
        selected: false,
        cells: [
          DataCell(Text(notVotedUser.userId)),
          DataCell(Text("${notVotedUser.lastName}, ${notVotedUser.firstName}")),
          DataCell(Text(notVotedUser.address)),
        ],
      );
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => voted ? voterModels.length : notVotedUsersModel.length;

  @override
  int get selectedRowCount => _selectedCount;
}
