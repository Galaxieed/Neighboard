import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/candidates_model.dart';
import 'package:neighboard/models/election_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/models/voter_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/src/admin_side/hoa_voting/candidates/candidates_function.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/community_page/ui/hoa_voting_page/hoa_voting_function.dart';
import 'package:neighboard/widgets/chat/chat.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_drawer.dart';
import 'package:intl/intl.dart';

import 'package:responsive_builder/responsive_builder.dart';

class HOAVotingDesktop extends StatefulWidget {
  const HOAVotingDesktop({super.key});

  @override
  State<HOAVotingDesktop> createState() => _HOAVotingDesktopState();
}

class _HOAVotingDesktopState extends State<HOAVotingDesktop> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? chosenPresident;
  String? chosenVicePresident;

  String? chosenSecretary;
  String? chosenAssistSecretary;
  String? chosenTreasurer;
  String? chosenAuditor;
  String? chosenAssistAuditor;

  Map<String, bool> optionsBD = {};
  List selectedBD = [];
  int maxDirectors = 8, startCount = 0;

  TabController controller(context) => DefaultTabController.of(context);
  bool isLoading = true, isElectionOngoing = true, isAlreadyVoted = false;
  bool isLoggedIn = false;
  List<CandidateModel> candidateModels = [];
  ElectionModel? electionModel;

  checkIfLoggedIn() async {
    if (_auth.currentUser != null) {
      isLoggedIn = true;
      getUserDetails();
      checkIfElectionOngoing();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  checkIfAlreadyVoted() async {
    isAlreadyVoted =
        await HOAVotingFunction.isAlreadyVoted(electionModel!.electionId);
    isLoading = false;
    setState(() {});
  }

  checkIfElectionOngoing() async {
    electionModel = await CandidatesFunctions.getLatestElection();
    //there is election
    if (electionModel != null) {
      DateTime elecStartDate = DateTime.parse(electionModel!.electionStartDate);
      TimeOfDay elecStartTime = TimeOfDay.fromDateTime(
          DateFormat("h:mm a").parse(electionModel!.electionStartTime));
      TimeOfDay elecEndTime = TimeOfDay.fromDateTime(
          DateFormat("h:mm a").parse(electionModel!.electionEndTime));
      DateTime now = DateTime.now();
      DateTime startDateTime = DateTime(
        elecStartDate.year,
        elecStartDate.month,
        elecStartDate.day,
        elecStartTime.hour,
        elecStartTime.minute,
      );
      DateTime endDateTime = DateTime(
        elecStartDate.year,
        elecStartDate.month,
        elecStartDate.day,
        elecEndTime.hour,
        elecEndTime.minute,
      );
      now = DateTime(now.year, now.month, now.day, now.hour, now.minute);

      //election is within the set date

      if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
        await checkIfAlreadyVoted();
        if (isAlreadyVoted) return;
        await getAllCandidates();
        setState(() {
          isElectionOngoing = true;
        });
      } else if (now.isAtSameMomentAs(startDateTime) ||
          now.isAtSameMomentAs(endDateTime)) {
        await checkIfAlreadyVoted();
        if (isAlreadyVoted) return;
        await getAllCandidates();
        setState(() {
          isElectionOngoing = true;
        });
      } else {
        // print('The date is not within the range');
        setState(() {
          isElectionOngoing = false;
          isLoading = false;
        });
      }
    } else {
      // print('The date is not within the range');
      setState(() {
        isElectionOngoing = false;
        isLoading = false;
      });
    }
  }

  getAllCandidates() async {
    candidateModels =
        await CandidatesFunctions.getAllCandidate(electionModel!.electionId) ??
            [];
    if (mounted) {
      setState(() {
        isLoading = false;
        initializeBDs();
      });
    }
  }

  void initializeBDs() {
    for (CandidateModel candidate in candidateModels) {
      if (candidate.position == "BOARD OF DIRECTORS") {
        optionsBD.addAll({candidate.candidateId: false});
      }
    }
  }

  UserModel? userModel;
  getUserDetails() async {
    userModel = await ProfileFunction.getUserDetails(_auth.currentUser!.uid);
    setState(() {});
  }

  void onSaveVote() async {
    setState(() {
      isLoading = true;
    });
    VoterModel voter = VoterModel(
      voterId: userModel!.userId,
      name: "${userModel!.lastName}, ${userModel!.firstName}",
      address: userModel!.address,
      timeVoted: formattedDate(),
    );
    await HOAVotingFunction.voteCandidate(
        electionModel!.electionId, chosenPresident!, voter);

    await HOAVotingFunction.voteCandidate(
        electionModel!.electionId, chosenVicePresident!, voter);

    await HOAVotingFunction.voteCandidate(
        electionModel!.electionId, chosenSecretary!, voter);

    await HOAVotingFunction.voteCandidate(
        electionModel!.electionId, chosenAssistSecretary!, voter);

    await HOAVotingFunction.voteCandidate(
        electionModel!.electionId, chosenTreasurer!, voter);

    await HOAVotingFunction.voteCandidate(
        electionModel!.electionId, chosenAuditor!, voter);

    await HOAVotingFunction.voteCandidate(
        electionModel!.electionId, chosenAssistAuditor!, voter);

    for (String id in selectedBD) {
      await HOAVotingFunction.voteCandidate(
          electionModel!.electionId, id, voter);
    }
    // ignore: use_build_context_synchronously
    successMessage(
        title: "Success!", desc: 'Your vote is successful.', context: context);

    setState(() {
      isLoading = false;
      isAlreadyVoted = true;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openNotification() {
    _scaffoldKey.currentState!.openEndDrawer();
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return const MyChat();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn();
  }

  TextEditingController tcName = TextEditingController();
  TextEditingController tcUsername = TextEditingController();
  TextEditingController tcGender = TextEditingController();
  TextEditingController tcAddress = TextEditingController();

  @override
  void dispose() {
    tcName.dispose();
    tcUsername.dispose();
    tcGender.dispose();
    tcAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavBar(
        openNotification: _openNotification,
        openChat: _openChat,
        currentPage: "Community",
      ),
      endDrawer: NotificationDrawer(
        deviceScreenType: DeviceScreenType.desktop,
        stateSetter: setState,
      ),
      body: isLoading
          ? const LoadingScreen()
          : Container(
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
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        fontFamily: "Montserrat", fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  !isLoggedIn
                      ? Expanded(
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  loginFirstImg,
                                  height: 300,
                                  width: 300,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Routes().navigate("Login", context);
                                      },
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                    const Text(" First"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : !isElectionOngoing
                          ? infoBannerMessage(
                              context,
                              "There is no election right now",
                              noElectionImg,
                            )
                          : isAlreadyVoted
                              ? infoBannerMessage(
                                  context,
                                  "You already voted.\nThank you for participation",
                                  electionImg,
                                )
                              : Expanded(
                                  child: gridOfCandidates(),
                                ),
                ],
              ),
            ),
    );
  }

  Widget infoBannerMessage(BuildContext context, text, imageString) {
    return Center(
      child: Container(
        //color: Theme.of(context).colorScheme.inversePrimary,
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imageString,
              width: 300,
              height: 300,
            ),
            Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  DefaultTabController gridOfCandidates() {
    return DefaultTabController(
      initialIndex: 0,
      length: 8,
      child: Builder(
        builder: (BuildContext context) => Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  hoaTab("PRESIDENT"),
                  hoaTab("VICE PRESIDENT"),
                  hoaTab("SECRETARY"),
                  hoaTab("ASSISTANT SECRETARY"),
                  hoaTab("TREASURER"),
                  hoaTab("AUDITOR"),
                  hoaTab("ASSISTANT AUDITOR"),
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
                      foregroundColor: ccHOANextButtonFGColor(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
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
                    TabController ctrl = controller(context);
                    if (!ctrl.indexIsChanging && ctrl.index < 7) {
                      ctrl.animateTo(ctrl.index + 1);
                      setState(() {});
                    }
                    if (!ctrl.indexIsChanging &&
                        ctrl.index == 7 &&
                        (startCount == 8 &&
                            chosenPresident != null &&
                            chosenVicePresident != null &&
                            chosenSecretary != null &&
                            chosenAssistSecretary != null &&
                            chosenTreasurer != null &&
                            chosenAuditor != null &&
                            chosenAssistAuditor != null)) {
                      onSaveVote();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller(context).index == 7 &&
                            (startCount != 8 ||
                                chosenPresident == null ||
                                chosenVicePresident == null ||
                                chosenSecretary == null ||
                                chosenAssistSecretary == null ||
                                chosenTreasurer == null ||
                                chosenAuditor == null ||
                                chosenAssistAuditor == null)
                        ? Theme.of(context).disabledColor
                        : ccHOANextButtonBGColor(context),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    controller(context).index < 7 ? "Next" : "Save",
                  ),
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
        hoaTitleBanner(
            context,
            title == "BOARD OF DIRECTORS"
                ? "BOARD OF DIRECTORS (select 8 candidates)"
                : title),
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

              return voteCandidatesCard(context, title, candidate, index);
            },
          ),
        ),
      ],
    );
  }

  Widget voteCandidatesCard(BuildContext context, String position,
      CandidateModel candidate, int index) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (position == "PRESIDENT") {
            chosenPresident = candidate.candidateId;
          }
          if (position == "VICE PRESIDENT") {
            chosenVicePresident = candidate.candidateId;
          }
          if (position == "SECRETARY") {
            chosenSecretary = candidate.candidateId;
          }
          if (position == "ASSISTANT SECRETARY") {
            chosenAssistSecretary = candidate.candidateId;
          }
          if (position == "TREASURER") {
            chosenTreasurer = candidate.candidateId;
          }
          if (position == "AUDITOR") {
            chosenAuditor = candidate.candidateId;
          }
          if (position == "ASSISTANT AUDITOR") {
            chosenAssistAuditor = candidate.candidateId;
          }
          if (position == "BOARD OF DIRECTORS") {
            if (!optionsBD[candidate.candidateId]! && startCount >= 8) {
              errorMessage(
                  title: "Warning!",
                  desc: 'You can only select up to 8 Candidates.',
                  context: context);
              return;
            } else {
              optionsBD[candidate.candidateId] =
                  !optionsBD[candidate.candidateId]!;
              if (optionsBD[candidate.candidateId]!) {
                selectedBD.add(candidate.candidateId);
                startCount += 1;
              } else {
                selectedBD.remove(candidate.candidateId);
                startCount -= 1;
              }
            }
          }
          setState(() {});
        },
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: position == "BOARD OF DIRECTORS"
                  ? Checkbox.adaptive(
                      value: optionsBD[candidate.candidateId],
                      onChanged: (bool? value) {
                        setState(() {
                          if (!optionsBD[candidate.candidateId]! &&
                              startCount >= 8) {
                            errorMessage(
                                title: "Warning!",
                                desc: 'You can only select up to 8 Candidates.',
                                context: context);
                            return;
                          } else {
                            optionsBD[candidate.candidateId] =
                                !optionsBD[candidate.candidateId]!;
                            if (optionsBD[candidate.candidateId]!) {
                              selectedBD.add(candidate.candidateId);
                              startCount += 1;
                            } else {
                              selectedBD.remove(candidate.candidateId);
                              startCount -= 1;
                            }
                          }
                        });
                      },
                    )
                  : Radio(
                      value: candidate.candidateId,
                      groupValue: () {
                        if (position == "PRESIDENT") {
                          return chosenPresident;
                        } else if (position == "VICE PRESIDENT") {
                          return chosenVicePresident;
                        } else if (position == "SECRETARY") {
                          return chosenSecretary;
                        } else if (position == "ASSISTANT SECRETARY") {
                          return chosenAssistSecretary;
                        } else if (position == "TREASURER") {
                          return chosenTreasurer;
                        } else if (position == "AUDITOR") {
                          return chosenAuditor;
                        } else if (position == "ASSISTANT AUDITOR") {
                          return chosenAssistAuditor;
                        } else {
                          return null;
                        }
                      }(),
                      onChanged: (val) {
                        if (position == "PRESIDENT") {
                          chosenPresident = val.toString();
                        }
                        if (position == "VICE PRESIDENT") {
                          chosenVicePresident = val.toString();
                        }
                        if (position == "SECRETARY") {
                          chosenSecretary = val.toString();
                        }
                        if (position == "ASSISTANT SECRETARY") {
                          chosenAssistSecretary = val.toString();
                        }
                        if (position == "TREASURER") {
                          chosenTreasurer = val.toString();
                        }
                        if (position == "AUDITOR") {
                          chosenAuditor = val.toString();
                        }
                        if (position == "ASSISTANT AUDITOR") {
                          chosenAssistAuditor = val.toString();
                        }

                        setState(() {});
                      },
                    ),
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
            ElevatedButton(
              onPressed: () {
                showDialog(
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
}
