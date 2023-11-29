import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/hoa_model.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/store_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/admin_side/dashboard/activity_logs.dart';
import 'package:neighboard/src/admin_side/hoa_voting/voters/voters_function.dart';
import 'package:neighboard/src/admin_side/site_settings/site_settings_function.dart';
import 'package:neighboard/src/admin_side/stores/store_function.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/user_side/forum_page/ui/all_posts/all_posts_function.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    required this.callback,
    required this.deviceScreenType,
    required this.currentUser,
  });

  final Function callback;
  final DeviceScreenType deviceScreenType;
  final UserModel? currentUser;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool isLoading = true;

  List<HOAModel> hoaModels = [];
  List<PostModel> postModels = [];
  List<PostModel> pendingPostModels = [];
  List<UserModel> userModels = [];
  List<StoreModel> storeModels = [];
  List<NotificationModel> logsModels = [];

  getAllData() async {
    hoaModels = await SiteSettingsFunction.getHOA() ?? [];
    postModels = await AllPostsFunction.getAllPost() ?? [];
    pendingPostModels = await AllPostsFunction.getAllPendingPost(false) ?? [];
    userModels = await VotersFunction.getAllUsers() ?? [];
    storeModels = await StoreFunction.getAllStores() ?? [];
    logsModels = await ActivityLogsFunction.getLogs() ?? [];
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: widget.deviceScreenType ==
                                DeviceScreenType.mobile
                            ? Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                )
                            : Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        children: <TextSpan>[
                          const TextSpan(
                              text: 'Welcome back, ',
                              style: TextStyle(color: Colors.grey)),
                          TextSpan(
                              text: ' ${widget.currentUser!.firstName}! 👋'),
                        ],
                      ),
                    ),
                    if (widget.deviceScreenType == DeviceScreenType.desktop)
                      ElevatedButton.icon(
                        onPressed: () {
                          showGeneralDialog(
                              context: context,
                              pageBuilder: (context, ant1, ant2) {
                                return Scaffold(
                                  appBar: AppBar(
                                    title: const Text(
                                      "Activity Logs",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  body: logsModels.isEmpty
                                      ? const Center(
                                          child: Text("No Logs"),
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 40.w),
                                          shrinkWrap: true,
                                          itemCount: logsModels.length,
                                          itemBuilder: (context, index) {
                                            NotificationModel log =
                                                logsModels[index];
                                            return ListTile(
                                              title: Text(log.notifTitle),
                                              subtitle: Text(log.notifTime),
                                            );
                                          }),
                                );
                              });
                        },
                        icon: const Icon(Icons.receipt_rounded),
                        label: const Text("Logs"),
                      ),
                  ],
                ),
                if (widget.deviceScreenType == DeviceScreenType.mobile)
                  ElevatedButton.icon(
                    onPressed: () {
                      showGeneralDialog(
                          context: context,
                          pageBuilder: (context, ant1, ant2) {
                            return Scaffold(
                              appBar: AppBar(
                                title: const Text(
                                  "Activity Logs",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              body: logsModels.isEmpty
                                  ? const Center(
                                      child: Text("No Logs"),
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 40.w),
                                      shrinkWrap: true,
                                      itemCount: logsModels.length,
                                      itemBuilder: (context, index) {
                                        NotificationModel log =
                                            logsModels[index];
                                        return ListTile(
                                          title: Text(log.notifTitle),
                                          subtitle: Text(log.notifTime),
                                        );
                                      }),
                            );
                          });
                    },
                    icon: const Icon(Icons.receipt_rounded),
                    label: const Text("Logs"),
                  ),
                SizedBox(
                  height: 30.h,
                ),
                GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      widget.deviceScreenType == DeviceScreenType.mobile
                          ? const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 400 / 300,
                              mainAxisSpacing: 30,
                              crossAxisSpacing: 30,
                            )
                          : SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 75.w,
                              childAspectRatio: 30.w / 80.h,
                              mainAxisSpacing: 30,
                              crossAxisSpacing: 30,
                            ),
                  shrinkWrap: true,
                  children: [
                    _buildSmallCard(
                      "Pending Posts",
                      Icons.pending_actions_outlined,
                      pendingPostModels.length.toString(),
                    ),
                    _buildSmallCard(
                      "Active Residents",
                      Icons.people_outline,
                      userModels.length.toString(),
                    ),
                    _buildSmallCard(
                      "Stores Registered",
                      Icons.store_outlined,
                      storeModels.length.toString(),
                    ),
                    _buildSmallCard(
                      "Election",
                      Icons.how_to_vote_outlined,
                      mainIsElectionOngoing ? "Ongoing" : "Closed",
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate:
                      widget.deviceScreenType == DeviceScreenType.mobile
                          ? const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 400 / 300,
                              mainAxisSpacing: 30,
                              crossAxisSpacing: 30,
                            )
                          : const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 800,
                              childAspectRatio: 400 / 300,
                              mainAxisSpacing: 30,
                              crossAxisSpacing: 30,
                            ),
                  children: [
                    Card(
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () {
                          widget.deviceScreenType == DeviceScreenType.mobile
                              ? showModalBottomSheet(
                                  showDragHandle: true,
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (_) => Container(
                                      padding: const EdgeInsets.all(8),
                                      height: 400,
                                      child: residentsPie(context, true)),
                                )
                              : showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: SizedBox(
                                        width: 800,
                                        height: 400,
                                        child: residentsPie(context, true)),
                                  ),
                                );
                        },
                        child:
                            IgnorePointer(child: residentsPie(context, false)),
                      ),
                    ),
                    Card(
                      elevation: 3,
                      child: categoriesBar(context, false),
                    ),
                  ],
                )
              ],
            ),
          );
  }

  Padding categoriesBar(BuildContext context, bool isOnModal) {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Forum Discussions",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: MyBarChart(
              isOnModal: isOnModal,
              postModels: postModels,
            ),
          ),
        ],
      ),
    );
  }

  Padding residentsPie(BuildContext context, bool isOnModal) {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Residents",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: MyPieChart(
              hoaModel: hoaModels,
              isOnModal: isOnModal,
              screen: widget.deviceScreenType,
            ),
          ),
        ],
      ),
    );
  }

  Card _buildSmallCard(String title, IconData icon, String data) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(
            widget.deviceScreenType == DeviceScreenType.mobile ? 10.w : 5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(icon),
              ],
            ),
            Expanded(
              child: Text(
                data,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: widget.deviceScreenType == DeviceScreenType.mobile
                        ? 52.sp
                        : 8.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResidentsData {
  final String street;
  final int noOfResident;
  const _ResidentsData({required this.street, required this.noOfResident});
}

class MyPieChart extends StatefulWidget {
  const MyPieChart(
      {super.key,
      required this.hoaModel,
      required this.isOnModal,
      required this.screen});

  final List<HOAModel> hoaModel;
  final bool isOnModal;
  final DeviceScreenType screen;

  @override
  State<MyPieChart> createState() => _MyPieChartState();
}

class _MyPieChartState extends State<MyPieChart> {
  //Chart configs
  final bool _animate = true;
  final double _arcRatio = 0.4;
  final charts.ArcLabelPosition _arcLabelPosition =
      charts.ArcLabelPosition.outside;
  charts.BehaviorPosition _legendPosition = charts.BehaviorPosition.end;
  //Data to render
  final List<_ResidentsData> _data = [];

  initializePie() async {
    Map<String, int> streetCounts = {};

    for (var hoa in widget.hoaModel) {
      if (streetCounts.containsKey(hoa.street)) {
        streetCounts[hoa.street] = streetCounts[hoa.street]! + 1;
      } else {
        streetCounts[hoa.street] = 1;
      }
    }

    streetCounts.forEach((street, count) {
      _data.add(_ResidentsData(street: street, noOfResident: count));
    });
  }

  @override
  void initState() {
    super.initState();
    initializePie();
    if (widget.screen == DeviceScreenType.mobile) {
      _legendPosition = charts.BehaviorPosition.bottom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorPalletes =
        charts.MaterialPalette.getOrderedPalettes(_data.length);
    return charts.PieChart<String>(
      [
        charts.Series<_ResidentsData, String>(
          id: 'Residents-1',
          colorFn: (_, idx) => colorPalletes[idx!].shadeDefault,
          data: _data,
          domainFn: (_ResidentsData resident, _) => resident.street,
          measureFn: (_ResidentsData resident, _) => resident.noOfResident,
          labelAccessorFn: (_ResidentsData row, _) =>
              "${row.street}: ${row.noOfResident}",
        )
      ],
      animate: _animate,
      defaultRenderer: charts.ArcRendererConfig(
        arcRatio: _arcRatio,
        arcRendererDecorators: [
          charts.ArcLabelDecorator(
            labelPosition: _arcLabelPosition,
            outsideLabelStyleSpec: charts.TextStyleSpec(
              fontSize: 12,
              color: isDarkMode ? charts.Color.white : charts.Color.black,
            ),
            leaderLineStyleSpec: charts.ArcLabelLeaderLineStyleSpec(
              color: isDarkMode ? charts.Color.white : charts.Color.black,
              length: 10,
              thickness: 1,
            ),
          )
        ],
      ),
      behaviors: !widget.isOnModal
          ? null
          : [
              charts.DatumLegend(
                position: _legendPosition,
                desiredMaxColumns: 1,
              )
            ],
    );
  }
}

class _CategoriesData {
  final int noOfPost;
  final String category;
  _CategoriesData({required this.noOfPost, required this.category});
}

class MyBarChart extends StatefulWidget {
  const MyBarChart(
      {super.key, required this.isOnModal, required this.postModels});
  final bool isOnModal;
  final List<PostModel> postModels;
  @override
  State<MyBarChart> createState() => _MyBarChartState();
}

class _MyBarChartState extends State<MyBarChart> {
  //charts configs
  final bool _animate = true;

  // final charts.BehaviorPosition _legendPosition =
  //     charts.BehaviorPosition.bottom;

  //Data to render
  final List<_CategoriesData> _data = [];

  void dataInitialization() {
    List<String> validTags = [
      'Water Billing',
      'Parking Space',
      'Electric Billing',
      'Garbage Collection',
      'Power Interruption',
      'Marketplace/Business',
      'Clubhouse Fees and Rental',
    ];
    Map<String, int> tagCounts = {};
    for (var post in widget.postModels) {
      for (var tag in post.tags) {
        if (!validTags.contains(tag)) {
          tag = "Others";
        } else {
          if (tag == "Water Billing") {
            tag = "Water";
          } else if (tag == "Parking Space") {
            tag = "Parking";
          } else if (tag == "Electric Billing") {
            tag = "Electric";
          } else if (tag == "Garbage Collection") {
            tag = "Garbage";
          } else if (tag == "Power Interruption") {
            tag = "Power";
          } else if (tag == "Marketplace/Business") {
            tag = "Market";
          } else if (tag == "Clubhouse Fees and Rental") {
            tag = "Club";
          }
        }
        if (tagCounts.containsKey(tag)) {
          tagCounts[tag] = tagCounts[tag]! + 1;
        } else {
          tagCounts[tag] = 1;
        }
      }
    }

    // Iterate over the map and create a _PostData object for each entry
    tagCounts.forEach((tag, count) {
      _data.add(_CategoriesData(noOfPost: count, category: tag));
    });
  }

  @override
  void initState() {
    super.initState();
    dataInitialization();
  }

  @override
  Widget build(BuildContext context) {
    final colorPalletes =
        charts.MaterialPalette.getOrderedPalettes(_data.length);
    return charts.BarChart(
      [
        charts.Series<_CategoriesData, String>(
          id: "Category-1",
          data: _data,
          colorFn: (_, idx) => colorPalletes[idx!].shadeDefault,
          domainFn: (_CategoriesData datum, _) => datum.category,
          measureFn: (_CategoriesData datum, _) => datum.noOfPost,
          labelAccessorFn: (_CategoriesData row, _) {
            return "${row.category}: ${row.noOfPost}";
          },
        ),
      ],
      animate: _animate,
      defaultRenderer: charts.BarRendererConfig(
        barRendererDecorator: charts.BarLabelDecorator(
          outsideLabelStyleSpec: charts.TextStyleSpec(
            fontSize: 12,
            color: isDarkMode ? charts.Color.white : charts.Color.black,
          ),
          labelPosition: charts.BarLabelPosition.auto,
        ),
      ),
      // behaviors: [
      //   charts.DatumLegend(
      //       position: _legendPosition,
      //       entryTextStyle: const charts.TextStyleSpec(fontSize: 10))
      // ],
    );
  }
}
