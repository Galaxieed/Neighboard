import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/data/store_data.dart';
import 'package:neighboard/models/store_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:responsive_builder/src/device_screen_type.dart';

class StoresMobile extends StatefulWidget {
  const StoresMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  State<StoresMobile> createState() => _StoresMobileState();
}

class _StoresMobileState extends State<StoresMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stores"),
        centerTitle: true,
        actions: [
          NavBarCircularImageDropDownButton(callback: Routes().navigate),
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
              child: GridView(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 400 / 300,
                ),
                children: [
                  for (StoreModel stModel in stores)
                    StoresCards(storeModel: stModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoresCards extends StatelessWidget {
  const StoresCards({
    super.key,
    required this.storeModel,
  });

  final StoreModel storeModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(storeModel.storeImage), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(5)),
          child: Column(
            children: [
              const Expanded(child: SizedBox()),
              GestureDetector(
                onTap: () {
                  showDialog(
                      // The Modal
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        storeModel.storeName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                      Text(
                                        storeModel.storeAddress,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 32,
                                ),
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image:
                                              AssetImage(storeModel.storeImage),
                                          fit: BoxFit.cover),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: ccStoresBannerColor,
                      borderRadius: BorderRadius.circular(5)),
                  padding: EdgeInsets.all(5.sp),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          storeModel.storeName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
