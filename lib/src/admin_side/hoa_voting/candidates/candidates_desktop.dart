import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/models/candidates_model.dart';
import 'package:neighboard/models/election_model.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/services/notification/notification.dart';
import 'package:neighboard/src/admin_side/hoa_voting/candidates/candidates_function.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_function.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:neighboard/widgets/notification/notification_function.dart';
import 'package:neighboard/widgets/others/tab_header.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:universal_io/io.dart';

class CandidatesDesktop extends StatefulWidget {
  const CandidatesDesktop(
      {super.key, required this.drawer, required this.deviceScreenType});

  final Function drawer;
  final DeviceScreenType deviceScreenType;

  @override
  State<CandidatesDesktop> createState() => _CandidatesDesktopState();
}

class _CandidatesDesktopState extends State<CandidatesDesktop> {
  final _formKey = GlobalKey<FormState>();
  TabController controller(context) => DefaultTabController.of(context);
  TextEditingController tcNote = TextEditingController();
  TextEditingController tcFName = TextEditingController();
  TextEditingController tcLName = TextEditingController();
  TextEditingController tcAddress = TextEditingController();

  List<CandidateModel> candidateModels = [];
  CandidateModel? candidateModel;
  ElectionModel? electionModel;

  File? profileImage;
  PlatformFile? profileImageByte;
  String profileImageUrl = "";
  List<List> profileImages = [];

  bool isTherePres = false, isThereVP = false;
  bool isThereSec = false, isThereAssistSec = false;
  bool isThereTres = false;
  bool isThereAudit = false, isThereAssistAudit = false;
  bool isThereBD = false;
  bool isLoading = true;
  bool isElectionOngoing = false;

  void pickImage(StateSetter modalStateSetter) async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image);
      if (result != null) {
        profileImageByte = result.files.single;
        modalStateSetter(() {});
      }
    } else if (!kIsWeb) {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        profileImage = File(pickedImage.path);
        modalStateSetter(() {});
      }
    }
  }

  Future<void> onSavingPic(ppImage, ppImageByte) async {
    if (ppImage != null || ppImageByte != null) {
      profileImageUrl = kIsWeb
          ? await ProfileFunction.uploadImageWeb(ppImageByte!.bytes!,
                  ppImageByte!.name, ppImageByte!.extension!) ??
              ""
          : await ProfileFunction.uploadImage(ppImage!) ?? "";
    }
  }

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
          //Get the profile pic from the list of profileImages
          profileImageUrl = '';
          int imageIndex = profileImages.indexWhere(
              (element) => element.contains(candidateModels[i].candidateId));
          if (imageIndex != -1) {
            await onSavingPic(
                profileImages[imageIndex][1], profileImages[imageIndex][2]);
          }

          //set the profile pic of each candidates
          candidateModels[i].profilePicture = profileImageUrl;

          //save the candidate in firebase
          await CandidatesFunctions.addCandidate(
            electionModel!.electionId,
            candidateModels[i],
          );
        }
        isElectionOngoing = true;
        await sendNotifToAll();
        // ignore: use_build_context_synchronously
        successMessage(
            title: "Success!",
            desc: "Election successfully started",
            context: context);
      } catch (e) {
        // ignore: use_build_context_synchronously
        errorMessage(
            title: "Error!", desc: "Something went wrong..", context: context);
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
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
    tcFName.clear();
    tcLName.clear();
    tcAddress.clear();
    profileImage = null;
    profileImageByte = null;
    profileImageUrl = '';
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
                                          }
                                          if (ctrl.index == 1 && isThereVP) {
                                            ctrl.animateTo(2);
                                          }
                                          if (ctrl.index == 2 && isThereSec) {
                                            ctrl.animateTo(3);
                                          }
                                          if (ctrl.index == 3 &&
                                              isThereAssistSec) {
                                            ctrl.animateTo(4);
                                          }
                                          if (ctrl.index == 4 && isThereTres) {
                                            ctrl.animateTo(5);
                                          }
                                          if (ctrl.index == 5 && isThereAudit) {
                                            ctrl.animateTo(6);
                                          }
                                          if (ctrl.index == 6 &&
                                              isThereAssistAudit) {
                                            ctrl.animateTo(7);
                                          }
                                          if (ctrl.index == 7 && isThereBD) {
                                            ctrl.animateTo(8);
                                          }

                                          setState(() {});
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
                                        foregroundColor:
                                            ccHOANextButtonFGColor(context),
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
                          child: addCandidateModal(title),
                        );
                      },
                    )
                  : showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: addCandidateModal(title),
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
                int imageIndex = profileImages.indexWhere(
                    (element) => element.contains(candidate.candidateId));
                return candidatesCard(context, candidate, imageIndex);
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
      builder: (BuildContext context, StateSetter mySetState) => Container(
        padding: const EdgeInsets.all(8.0),
        width: 700,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "New Candidate",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage:
                          profileImage != null || profileImageByte != null
                              ? kIsWeb
                                  ? MemoryImage(profileImageByte!.bytes!)
                                  : FileImage(profileImage!) as ImageProvider
                              : const AssetImage(guestIcon),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: IconButton(
                          onPressed: () {
                            //update picture
                            pickImage(mySetState);
                          },
                          icon: const Icon(Icons.camera_alt),
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                myTextFormField(tcFName, "First Name"),
                const SizedBox(
                  height: 5,
                ),
                myTextFormField(tcLName, "Last Name"),
                const SizedBox(
                  height: 5,
                ),
                myTextFormField(tcAddress, "Address", 5),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        mySetState(() {
                          onClearForm();
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
                        if (_formKey.currentState!.validate()) {
                          var candidateId = DateTime.now().toIso8601String();
                          candidateModel = CandidateModel(
                            candidateId: candidateId,
                            firstName: tcFName.text.trim(),
                            lastName: tcLName.text.trim(),
                            profilePicture: '',
                            address: tcAddress.text.trim(),
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
                            profileImages.add([
                              candidateId,
                              profileImage,
                              profileImageByte,
                            ]);
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
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onBackground,
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
      ),
    );
  }

  TextFormField myTextFormField(controller, label, [maxlines]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        label: Text(label),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == '' || value == null) {
          return "Enter value to this field";
        }
        return null;
      },
      maxLines: maxlines,
    );
  }

  Widget candidatesCard(
      BuildContext context, CandidateModel candidate, int index) {
    return Card(
      child: Column(
        children: [
          SizedBox(
            height: 25.h,
          ),
          Expanded(
            child: FittedBox(
              child: CircleAvatar(
                backgroundImage: (profileImages[index][1] != null ||
                        profileImages[index][2] != null)
                    ? kIsWeb
                        ? MemoryImage(profileImages[index][2]!.bytes!)
                        : FileImage(profileImages[index][1]!) as ImageProvider
                    : const AssetImage(guestIcon),
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
          ElevatedButton.icon(
            onPressed: () {
              tcFName.text = candidate.firstName;
              tcLName.text = candidate.lastName;
              tcAddress.text = candidate.address;
              widget.deviceScreenType == DeviceScreenType.mobile
                  ? showModalBottomSheet(
                      isScrollControlled: true,
                      useSafeArea: true,
                      showDragHandle: true,
                      context: context,
                      builder: (context) {
                        return Padding(
                          padding: MediaQuery.of(context).viewInsets,
                          child: editCandidateModal(index, candidate),
                        );
                      },
                    )
                  : showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: editCandidateModal(index, candidate),
                        );
                      },
                    );
            },
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

  StatefulBuilder editCandidateModal(int index, CandidateModel candidate) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter mySetState) => Container(
        padding: const EdgeInsets.all(8.0),
        width: 700,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Candidate",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: (profileImages[index][1] != null ||
                              profileImages[index][2] != null)
                          ? profileImage != null || profileImageByte != null
                              ? kIsWeb
                                  ? MemoryImage(profileImageByte!.bytes!)
                                  : FileImage(profileImage!) as ImageProvider
                              : kIsWeb
                                  ? MemoryImage(profileImages[index][2]!.bytes!)
                                  : FileImage(profileImages[index][1]!)
                                      as ImageProvider
                          : profileImage != null || profileImageByte != null
                              ? kIsWeb
                                  ? MemoryImage(profileImageByte!.bytes!)
                                  : FileImage(profileImage!) as ImageProvider
                              : const AssetImage(guestIcon),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: IconButton(
                          onPressed: () {
                            //update picture
                            pickImage(mySetState);
                          },
                          icon: const Icon(Icons.camera_alt),
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                myTextFormField(tcFName, "First Name"),
                const SizedBox(
                  height: 5,
                ),
                myTextFormField(tcLName, "Last Name"),
                const SizedBox(
                  height: 5,
                ),
                myTextFormField(tcAddress, "Address", 5),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        mySetState(() {
                          onClearForm();
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
                        if (_formKey.currentState!.validate()) {
                          //update candidateModels specific index
                          int candidateIndex = candidateModels.indexWhere(
                              (element) =>
                                  element.candidateId == candidate.candidateId);

                          candidateModels[candidateIndex] = CandidateModel(
                              candidateId: candidate.candidateId,
                              firstName: tcFName.text,
                              lastName: tcLName.text,
                              profilePicture: candidate.profilePicture,
                              address: tcAddress.text,
                              position: candidate.position,
                              noOfVotes: candidate.noOfVotes);

                          //update profileImages specific index
                          profileImages[index][2] =
                              profileImageByte ?? profileImages[index][2];
                          profileImages[index][1] =
                              profileImage ?? profileImages[index][1];

                          onClearForm();
                          setState(() {});
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onBackground,
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text("Update"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
