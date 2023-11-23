import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/candidates_model.dart';
import 'package:neighboard/models/election_model.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/services/notification/notification.dart';
import 'package:neighboard/src/admin_side/hoa_voting/candidates/candidates_function.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_function.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:neighboard/widgets/others/tab_header.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

class CandidatesDesktop extends StatefulWidget {
  const CandidatesDesktop(
      {super.key, required this.drawer, required this.deviceScreenType});

  final Function drawer;
  final DeviceScreenType deviceScreenType;

  @override
  State<CandidatesDesktop> createState() => _CandidatesDesktopState();
}

class _CandidatesDesktopState extends State<CandidatesDesktop> {
  TabController controller(context) => DefaultTabController.of(context);
  TextEditingController tcNote = TextEditingController();
  TextEditingController tcName = TextEditingController();
  TextEditingController tcUsername = TextEditingController();
  TextEditingController tcGender = TextEditingController();
  TextEditingController tcAddress = TextEditingController();

  UserModel? candidateUser;
  List<CandidateModel> candidateModels = [];
  CandidateModel? candidateModel;
  ElectionModel? electionModel;

  String profileImageUrl = "";

  bool isTherePres = false, isThereVP = false;
  bool isThereSec = false, isThereAssistSec = false;
  bool isThereTres = false;
  bool isThereAudit = false, isThereAssistAudit = false;
  bool isThereBD = false;
  bool isLoading = true;
  bool isElectionOngoing = false;

  void onStartElection() async {
    setState(() {
      isLoading = true;
    });
    electionModel = ElectionModel(
      electionId: '$startingDate-$endingDate',
      electionStartDate: startingDate,
      electionEndDate: endingDate,
      electionNote: tcNote.text,
    );

    bool isSuccessful = await CandidatesFunctions.startElection(electionModel!);

    if (isSuccessful) {
      //save the candidate 1 by 1
      try {
        for (int i = 0; i < candidateModels.length; i++) {
          //save the candidate in firebase
          await CandidatesFunctions.addCandidate(
            electionModel!.electionId,
            candidateModels[i],
          );
        }
        mainIsElectionOngoing = true;
        isElectionOngoing = true;
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        // ignore: use_build_context_synchronously
        successMessage(
            title: "Success!",
            desc: "Election successfully started",
            context: context);
        await sendNotifToAll();
      } catch (e) {
        // ignore: use_build_context_synchronously
        errorMessage(
            title: "Error!", desc: "Something went wrong..", context: context);
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  //first collect all data then add all at the end

  String startingDate = '';
  String endingDate = '';

  Future<void> setStartDate(String newDate) async {
    setState(() {
      startingDate = newDate;
    });
  }

  Future<void> setEndDate(String newDate) async {
    setState(() {
      endingDate = newDate;
    });
  }

  void onClearForm() {
    profileImageUrl = '';
    candidateModel = null;
    candidateUser = null;
    tcAddress.clear();
    tcGender.clear();
    tcName.clear();
    tcUsername.clear();
  }

  int nextYear = DateTime.parse(DateTime.now().toString()).year + 1;
  int thisMonth = DateTime.parse(DateTime.now().toString()).month;
  int thisDay = DateTime.parse(DateTime.now().toString()).day;

  checkIfElectionOngoing() async {
    electionModel = await CandidatesFunctions.getLatestElection();
    if (electionModel != null) {
      DateTime elecStartDate = DateTime.parse(electionModel!.electionStartDate);
      DateTime elecEndDate = DateTime.parse(electionModel!.electionEndDate);
      DateTime now = DateTime.now();
      elecStartDate =
          DateTime(elecStartDate.year, elecStartDate.month, elecStartDate.day);
      elecEndDate =
          DateTime(elecEndDate.year, elecEndDate.month, elecEndDate.day);
      now = DateTime(now.year, now.month, now.day);

      if (now.isAfter(elecStartDate) && now.isBefore(elecEndDate)) {
        // print('The date is within the range');
        setState(() {
          isElectionOngoing = true;
        });
      } else if (now.isAtSameMomentAs(elecStartDate) ||
          now.isAtSameMomentAs(elecEndDate)) {
        // print('The date is within the range');
        setState(() {
          isElectionOngoing = true;
        });
      } else {
        // print('The date is not within the range');
        setState(() {
          isElectionOngoing = false;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  List<UserModel> allUsers = [];
  getAllUsers() async {
    allUsers = await VotersFunction.getAllUsers() ?? [];
    //remove the admin from the list of users
    allUsers = allUsers.where((element) => element.role != "ADMIN").toList();
  }

  //send notif to one
  Future<void> sendNotificaton(UserModel user) async {
    await MyNotification().sendPushMessage(
      user.deviceToken,
      "New Election has added: ",
      '${DateFormat.yMMMd().format(DateTime.parse(startingDate))} - ${DateFormat.yMMMd().format(DateTime.parse(endingDate))}',
    );

    //ADD sa notification TAB
    NotificationModel notificationModel = NotificationModel(
      notifId: DateTime.now().toIso8601String(),
      notifTitle: "New Election has added: ",
      notifBody:
          '${DateFormat.yMMMd().format(DateTime.parse(startingDate))} - ${DateFormat.yMMMd().format(DateTime.parse(endingDate))}',
      notifTime: formattedDate(),
      notifLocation: "ELECTION",
      isRead: false,
      isArchived: false,
    );

    await NotificationFunction.addNotification(notificationModel, user.userId);
  }

  //send notif to all at once
  sendNotifToAll() async {
    await Future.forEach(allUsers, sendNotificaton);
  }

  @override
  void initState() {
    super.initState();
    getAllUsers();
    checkIfElectionOngoing();
  }

  @override
  void dispose() {
    tcAddress.dispose();
    tcName.dispose();
    tcUsername.dispose();
    tcGender.dispose();
    tcNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            padding: EdgeInsets.symmetric(
                vertical: widget.deviceScreenType == DeviceScreenType.mobile
                    ? 15.h
                    : 30.h,
                horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.deviceScreenType == DeviceScreenType.desktop)
                  TabHeader(
                    title: "Candidates List",
                    callback: () {
                      widget.drawer();
                    },
                  ),
                if (widget.deviceScreenType == DeviceScreenType.desktop)
                  SizedBox(
                    height: 20.h,
                  ),
                Expanded(
                  child: isElectionOngoing
                      ? Center(
                          child: Column(
                            children: [
                              Image.asset(
                                electionImg,
                                height: 300,
                                width: 300,
                              ),
                              const Text("Election is ongoing!"),
                            ],
                          ),
                        )
                      : DefaultTabController(
                          length: 9,
                          child: Builder(
                            builder: (BuildContext context) => Column(
                              children: [
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      hoaAdminTab(context, "PRESIDENT"),
                                      hoaAdminTab(context, "VICE PRESIDENT"),
                                      hoaAdminTab(context, "SECRETARY"),
                                      hoaAdminTab(
                                          context, "ASSISTANT SECRETARY"),
                                      hoaAdminTab(context, "TREASURER"),
                                      hoaAdminTab(context, "AUDITOR"),
                                      hoaAdminTab(context, "ASSISTANT AUDITOR"),
                                      hoaAdminTab(
                                          context, "BOARD OF DIRECTORS"),
                                      hoaAdminTab(context, "VOTING DETAILS"),
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
                                          TabController ctrl =
                                              controller(context);
                                          if (!ctrl.indexIsChanging &&
                                              (ctrl.index > 0)) {
                                            ctrl.animateTo(ctrl.index - 1);
                                            setState(() {});
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor:
                                              ccHOANextButtonFGColor(context),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          elevation: 1,
                                        ),
                                        child: const Text("Back"),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2.w,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        TabController ctrl =
                                            controller(context);
                                        if (!ctrl.indexIsChanging &&
                                            ctrl.index < 8) {
                                          if (ctrl.index == 0 && isTherePres) {
                                            ctrl.animateTo(1);
                                            setState(() {});
                                            return;
                                          } else if (ctrl.index == 0) {
                                            infoMessage(
                                                title: "Put candidate",
                                                desc: "Put President candidate",
                                                context: context);
                                          }
                                          if (ctrl.index == 1 && isThereVP) {
                                            ctrl.animateTo(2);
                                            setState(() {});
                                            return;
                                          } else if (ctrl.index == 1) {
                                            infoMessage(
                                                title: "Put candidate",
                                                desc:
                                                    "Put V.President candidate",
                                                context: context);
                                          }
                                          if (ctrl.index == 2 && isThereSec) {
                                            ctrl.animateTo(3);
                                            setState(() {});
                                            return;
                                          } else if (ctrl.index == 2) {
                                            infoMessage(
                                                title: "Put candidate",
                                                desc: "Put Secretary candidate",
                                                context: context);
                                          }
                                          if (ctrl.index == 3 &&
                                              isThereAssistSec) {
                                            ctrl.animateTo(4);
                                            setState(() {});
                                            return;
                                          } else if (ctrl.index == 3) {
                                            infoMessage(
                                                title: "Put candidate",
                                                desc:
                                                    "Put Asst. Sec. candidate",
                                                context: context);
                                          }
                                          if (ctrl.index == 4 && isThereTres) {
                                            ctrl.animateTo(5);
                                            setState(() {});
                                            return;
                                          } else if (ctrl.index == 4) {
                                            infoMessage(
                                                title: "Put candidate",
                                                desc: "Put Treasurer candidate",
                                                context: context);
                                          }
                                          if (ctrl.index == 5 && isThereAudit) {
                                            ctrl.animateTo(6);
                                            setState(() {});
                                            return;
                                          } else if (ctrl.index == 5) {
                                            infoMessage(
                                                title: "Put candidate",
                                                desc: "Put Auditor candidate",
                                                context: context);
                                          }
                                          if (ctrl.index == 6 &&
                                              isThereAssistAudit) {
                                            ctrl.animateTo(7);
                                            setState(() {});
                                            return;
                                          } else if (ctrl.index == 6) {
                                            infoMessage(
                                                title: "Put candidate",
                                                desc:
                                                    "Put Asst. Auditor candidate",
                                                context: context);
                                          }
                                          if (ctrl.index == 7 && isThereBD) {
                                            ctrl.animateTo(8);
                                            setState(() {});
                                            return;
                                          } else if (ctrl.index == 7) {
                                            infoMessage(
                                                title: "Put candidate",
                                                desc: "Put B.O.D. candidate",
                                                context: context);
                                          }
                                        }
                                        if (!ctrl.indexIsChanging &&
                                            ctrl.index == 8) {
                                          if (candidateModels != [] &&
                                              startingDate != '' &&
                                              endingDate != '') {
                                            onStartElection();
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ccHOANextButtonBGColor(context),
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      child: Text(controller(context).index < 8
                                          ? "Next"
                                          : "Save"),
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
        if (title != 'VOTING DETAILS')
          ElevatedButton.icon(
            onPressed: () {
              widget.deviceScreenType == DeviceScreenType.mobile
                  ? showModalBottomSheet(
                      isScrollControlled: true,
                      useSafeArea: true,
                      showDragHandle: true,
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                          padding: MediaQuery.of(context).viewInsets,
                          child: addCandidateMobileModal(title),
                        );
                      },
                    )
                  : showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: addCandidateModal(title),
                          ),
                        );
                      },
                    );
            },
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
        if (title != 'VOTING DETAILS')
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
                var list = candidateModels
                    .where((element) => element.position == title);
                CandidateModel candidate = list.elementAt(index);
                return candidatesCard(context, candidate, index, title);
              },
            ),
          )
        else
          Expanded(
            child: Padding(
                padding: EdgeInsets.all(8.sp),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            showDateRangePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(nextYear, thisMonth, thisDay),
                            ).then(
                              (value) {
                                if (value != null) {
                                  DateTimeRange fromRange = DateTimeRange(
                                      start: DateTime.now(),
                                      end: DateTime.now());
                                  fromRange = value;
                                  // String startDate = DateFormat.yMMMd()
                                  //     .format(fromRange.start);
                                  // String endDate =
                                  //     DateFormat.yMMMd().format(fromRange.end);
                                  setStartDate(fromRange.start.toString());
                                  setEndDate(fromRange.end.toString());
                                }
                              },
                            );
                          },
                          icon: const Icon(Icons.date_range_outlined),
                          label: const Text("Set Election Date Range"),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if ((startingDate != '' || endingDate != '') &&
                            widget.deviceScreenType != DeviceScreenType.mobile)
                          Text(
                              '${DateFormat.yMMMd().format(DateTime.parse(startingDate))} - ${DateFormat.yMMMd().format(DateTime.parse(endingDate))}'),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if ((startingDate != '' || endingDate != '') &&
                        widget.deviceScreenType == DeviceScreenType.mobile)
                      Text(
                          '${DateFormat.yMMMd().format(DateTime.parse(startingDate))} - ${DateFormat.yMMMd().format(DateTime.parse(endingDate))}'),
                    Expanded(
                      child: TextField(
                        controller: tcNote,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Write some note here.. (Optional)",
                          alignLabelWithHint: true,
                        ),
                        maxLines: 10,
                      ),
                    )
                  ],
                )),
          ),
      ],
    );
  }

  StatefulBuilder addCandidateModal(String title) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter mySetState) => Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(50.0),
            width: 700,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Select Candidate",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                            DropdownSearch<UserModel>(
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: const TextFieldProps(
                                    decoration: InputDecoration(
                                        hintText: "Search Here...")),
                                searchDelay: const Duration(milliseconds: 100),
                                disabledItemFn: (item) {
                                  return candidateModels
                                      .where((element) =>
                                          element.firstName.trim() ==
                                              item.firstName.trim() &&
                                          element.lastName.trim() ==
                                              item.lastName.trim())
                                      .toList()
                                      .isNotEmpty;
                                },
                              ),
                              items: allUsers,
                              selectedItem: candidateUser,
                              filterFn: (item, filter) {
                                filter = filter.toLowerCase();
                                if (filter.isEmpty) return true;
                                return item.firstName
                                        .toLowerCase()
                                        .contains(filter) ||
                                    item.lastName
                                        .toLowerCase()
                                        .contains(filter);
                              },
                              itemAsString: (UserModel u) =>
                                  "${u.firstName} ${u.lastName}",
                              onChanged: (UserModel? data) => mySetState(() {
                                candidateUser = data;
                                tcName.text =
                                    "${candidateUser?.firstName ?? ""} ${candidateUser?.lastName ?? ""}";
                                tcUsername.text = candidateUser?.username ?? "";
                                tcGender.text = candidateUser?.gender ?? "";
                                tcAddress.text = candidateUser?.address ?? "";
                                profileImageUrl =
                                    candidateUser?.profilePicture ?? "";
                                setState(() {});
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      Expanded(
                        child: Center(
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: candidateUser == null ||
                                    profileImageUrl.isEmpty
                                ? const AssetImage(guestIcon) as ImageProvider
                                : NetworkImage(candidateUser!.profilePicture),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: myTextFormField(tcName, "Candidate Name"),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      Expanded(child: myTextFormField(tcUsername, "Username")),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(child: myTextFormField(tcGender, "Gender")),
                      const SizedBox(
                        width: 50,
                      ),
                      Expanded(child: myTextFormField(tcAddress, "Address")),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          mySetState(() {
                            onClearForm();
                            setState(() {});
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          foregroundColor: Colors.red,
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Discard"),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (candidateUser != null) {
                            var candidateId = DateTime.now().toIso8601String();
                            candidateModel = CandidateModel(
                              candidateId: candidateId,
                              firstName: candidateUser?.firstName.trim() ?? "",
                              lastName: candidateUser?.lastName.trim() ?? "",
                              username: candidateUser?.username.trim() ?? "",
                              gender: candidateUser?.gender.trim() ?? "",
                              profilePicture:
                                  candidateUser?.profilePicture.trim() ?? "",
                              address: candidateUser?.address.trim() ?? "",
                              position: () {
                                if (title == "PRESIDENT") {
                                  return "PRESIDENT";
                                } else if (title == "VICE PRESIDENT") {
                                  return "VICE PRESIDENT";
                                } else if (title == "SECRETARY") {
                                  return "SECRETARY";
                                } else if (title == "ASSISTANT SECRETARY") {
                                  return "ASSISTANT SECRETARY";
                                } else if (title == "TREASURER") {
                                  return "TREASURER";
                                } else if (title == "AUDITOR") {
                                  return "AUDITOR";
                                } else if (title == "ASSISTANT AUDITOR") {
                                  return "ASSISTANT AUDITOR";
                                } else if (title == "BOARD OF DIRECTORS") {
                                  return "BOARD OF DIRECTORS";
                                } else {
                                  return "";
                                }
                              }(),
                              noOfVotes: 0,
                            );
                            if (candidateModel != null) {
                              candidateModels.add(candidateModel!);
                              setState(() {
                                if (title == "PRESIDENT") {
                                  isTherePres = true;
                                } else if (title == "VICE PRESIDENT") {
                                  isThereVP = true;
                                } else if (title == "SECRETARY") {
                                  isThereSec = true;
                                } else if (title == "ASSISTANT SECRETARY") {
                                  isThereAssistSec = true;
                                } else if (title == "TREASURER") {
                                  isThereTres = true;
                                } else if (title == "AUDITOR") {
                                  isThereAudit = true;
                                } else if (title == "ASSISTANT AUDITOR") {
                                  isThereAssistAudit = true;
                                } else {
                                  isThereBD = true;
                                }
                              });
                              onClearForm();
                              Navigator.pop(context);
                            }
                          } else {
                            errorMessage(
                                title: "Choose Candidate",
                                desc: "Choose Candidate First",
                                context: context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor: colorFromHex(saveColor),
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text("Add"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }

  StatefulBuilder addCandidateMobileModal(String title) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter mySetState) => SizedBox(
        width: 700,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Candidate",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(
                height: 15,
              ),
              DropdownSearch<UserModel>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: const TextFieldProps(
                      decoration: InputDecoration(hintText: "Search Here...")),
                  searchDelay: const Duration(milliseconds: 100),
                  disabledItemFn: (item) {
                    return candidateModels
                        .where((element) =>
                            element.firstName.trim() == item.firstName.trim() &&
                            element.lastName.trim() == item.lastName.trim())
                        .toList()
                        .isNotEmpty;
                  },
                ),
                items: allUsers,
                selectedItem: candidateUser,
                filterFn: (item, filter) {
                  filter = filter.toLowerCase();
                  if (filter.isEmpty) return true;
                  return item.firstName.toLowerCase().contains(filter) ||
                      item.lastName.toLowerCase().contains(filter);
                },
                itemAsString: (UserModel u) => "${u.firstName} ${u.lastName}",
                onChanged: (UserModel? data) => mySetState(() {
                  candidateUser = data;
                  tcName.text =
                      "${candidateUser?.firstName ?? ""} ${candidateUser?.lastName ?? ""}";
                  tcUsername.text = candidateUser?.username ?? "";
                  tcGender.text = candidateUser?.gender ?? "";
                  tcAddress.text = candidateUser?.address ?? "";
                  profileImageUrl = candidateUser?.profilePicture ?? "";
                  setState(() {});
                }),
              ),
              const SizedBox(
                height: 5,
              ),
              CircleAvatar(
                radius: 80,
                backgroundImage:
                    candidateUser == null || profileImageUrl.isEmpty
                        ? const AssetImage(guestIcon) as ImageProvider
                        : NetworkImage(candidateUser!.profilePicture),
              ),
              const SizedBox(
                height: 5,
              ),
              myTextFormField(tcName, "Candidate Name"),
              const SizedBox(
                height: 5,
              ),
              myTextFormField(tcUsername, "Username"),
              const SizedBox(
                height: 5,
              ),
              myTextFormField(tcGender, "Gender"),
              const SizedBox(
                height: 5,
              ),
              myTextFormField(tcAddress, "Address"),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      mySetState(() {
                        onClearForm();
                        setState(() {});
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      foregroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Discard"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (candidateUser != null) {
                        var candidateId = DateTime.now().toIso8601String();
                        candidateModel = CandidateModel(
                          candidateId: candidateId,
                          firstName: candidateUser?.firstName.trim() ?? "",
                          lastName: candidateUser?.lastName.trim() ?? "",
                          username: candidateUser?.username.trim() ?? "",
                          gender: candidateUser?.gender.trim() ?? "",
                          profilePicture:
                              candidateUser?.profilePicture.trim() ?? "",
                          address: candidateUser?.address.trim() ?? "",
                          position: () {
                            if (title == "PRESIDENT") {
                              return "PRESIDENT";
                            } else if (title == "VICE PRESIDENT") {
                              return "VICE PRESIDENT";
                            } else if (title == "SECRETARY") {
                              return "SECRETARY";
                            } else if (title == "ASSISTANT SECRETARY") {
                              return "ASSISTANT SECRETARY";
                            } else if (title == "TREASURER") {
                              return "TREASURER";
                            } else if (title == "AUDITOR") {
                              return "AUDITOR";
                            } else if (title == "ASSISTANT AUDITOR") {
                              return "ASSISTANT AUDITOR";
                            } else if (title == "BOARD OF DIRECTORS") {
                              return "BOARD OF DIRECTORS";
                            } else {
                              return "";
                            }
                          }(),
                          noOfVotes: 0,
                        );
                        if (candidateModel != null) {
                          candidateModels.add(candidateModel!);
                          setState(() {
                            if (title == "PRESIDENT") {
                              isTherePres = true;
                            } else if (title == "VICE PRESIDENT") {
                              isThereVP = true;
                            } else if (title == "SECRETARY") {
                              isThereSec = true;
                            } else if (title == "ASSISTANT SECRETARY") {
                              isThereAssistSec = true;
                            } else if (title == "TREASURER") {
                              isThereTres = true;
                            } else if (title == "AUDITOR") {
                              isThereAudit = true;
                            } else if (title == "ASSISTANT AUDITOR") {
                              isThereAssistAudit = true;
                            } else {
                              isThereBD = true;
                            }
                          });
                          onClearForm();
                          Navigator.pop(context);
                        }
                      } else {
                        errorMessage(
                            title: "Choose Candidate",
                            desc: "Choose Candidate First",
                            context: context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: colorFromHex(saveColor),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text("Add"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget myTextFormField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget candidatesCard(
      BuildContext context, CandidateModel candidate, int index, String title) {
    return Card(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              SizedBox(
                height: 25.h,
              ),
              Expanded(
                child: FittedBox(
                  child: CircleAvatar(
                    backgroundImage: candidate.profilePicture.isNotEmpty
                        ? NetworkImage(candidate.profilePicture)
                        : const AssetImage(guestIcon) as ImageProvider,
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
              ElevatedButton(
                onPressed: () {
                  widget.deviceScreenType == DeviceScreenType.mobile
                      ? showModalBottomSheet(
                          isScrollControlled: true,
                          useSafeArea: true,
                          showDragHandle: true,
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: viewCandidateMobileModal(index, candidate),
                            );
                          },
                        )
                      : showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: viewCandidateModal(index, candidate),
                              ),
                            );
                          },
                        );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text("View Details"),
              ),
              SizedBox(
                height: 25.h,
              ),
            ],
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              onPressed: () {
                //remove candidate from list of candidates
                candidateModels.removeWhere(
                    (element) => element.candidateId == candidate.candidateId);

                int lenght = candidateModels
                    .where((element) => element.position == title)
                    .toList()
                    .length;
                if (lenght == 0) {
                  if (title == "PRESIDENT") {
                    isTherePres = false;
                  } else if (title == "VICE PRESIDENT") {
                    isThereVP = false;
                  } else if (title == "SECRETARY") {
                    isThereSec = false;
                  } else if (title == "ASSISTANT SECRETARY") {
                    isThereAssistSec = false;
                  } else if (title == "TREASURER") {
                    isThereTres = false;
                  } else if (title == "AUDITOR") {
                    isThereAudit = false;
                  } else if (title == "ASSISTANT AUDITOR") {
                    isThereAssistAudit = false;
                  } else {
                    isThereBD = false;
                  }
                }

                setState(() {});
              },
              icon: const Icon(Icons.close),
            ),
          )
        ],
      ),
    );
  }

  Widget viewCandidateModal(int index, CandidateModel candidate) {
    tcName.text = "${candidate.firstName} ${candidate.lastName}";
    tcUsername.text = candidate.username;
    tcGender.text = candidate.gender;
    tcAddress.text = candidate.address;
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(50.0),
          width: 700,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Candidate ${index + 1}",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: Center(
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: candidate.profilePicture.isEmpty
                              ? const AssetImage(guestIcon) as ImageProvider
                              : NetworkImage(candidate.profilePicture),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      child: myTextFormField(tcName, "Candidate Name"),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    Expanded(child: myTextFormField(tcUsername, "Username")),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(child: myTextFormField(tcGender, "Gender")),
                    const SizedBox(
                      width: 50,
                    ),
                    Expanded(child: myTextFormField(tcAddress, "Address")),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }

  Widget viewCandidateMobileModal(int index, CandidateModel candidate) {
    tcName.text = "${candidate.firstName} ${candidate.lastName}";
    tcUsername.text = candidate.username;
    tcGender.text = candidate.gender;
    tcAddress.text = candidate.address;
    return SizedBox(
      width: 700,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Candidate ${index + 1}",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(
              height: 15,
            ),
            CircleAvatar(
              radius: 80,
              backgroundImage: candidate.profilePicture.isEmpty
                  ? const AssetImage(guestIcon) as ImageProvider
                  : NetworkImage(candidate.profilePicture),
            ),
            const SizedBox(
              height: 5,
            ),
            myTextFormField(tcName, "Candidate Name"),
            const SizedBox(
              height: 5,
            ),
            myTextFormField(tcUsername, "Username"),
            const SizedBox(
              height: 5,
            ),
            myTextFormField(tcGender, "Gender"),
            const SizedBox(
              height: 5,
            ),
            myTextFormField(tcAddress, "Address"),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
