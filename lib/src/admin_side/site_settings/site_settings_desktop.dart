import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_drawer.dart';
import 'package:neighboard/widgets/others/tab_header.dart';

class SiteSettingsDesktop extends StatefulWidget {
  const SiteSettingsDesktop({super.key, required this.drawer});

  final void Function() drawer;

  @override
  State<SiteSettingsDesktop> createState() => _SiteSettingsDesktopState();
}

class _SiteSettingsDesktopState extends State<SiteSettingsDesktop> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 30.h,
        horizontal: 15.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabHeader(
            title: "Site Settings",
            callback: () {
              widget.drawer();
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 1024,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GridView(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 500,
                          childAspectRatio: 500 / 400,
                          crossAxisSpacing: 20,
                        ),
                        children: [
                          Stack(
                            children: [
                              const Image(
                                image: AssetImage(homepageImage),
                                fit: BoxFit.cover,
                                width: 550,
                                height: 400,
                              ),
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.image_outlined),
                                  label: const Text("Change 'Homepage' Image"),
                                ),
                              ),
                            ],
                          ),
                          Stack(
                            children: [
                              const Image(
                                image: AssetImage(homeImage),
                                fit: BoxFit.cover,
                                width: 550,
                                height: 400,
                              ),
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.image_outlined),
                                  label: const Text("Change 'About' Image"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      ListTile(
                        onTap: () {},
                        leading: const CircleAvatar(),
                        title: const Text("Change Logo"),
                      ),
                      const Divider(),
                      const LightDarkMode(),
                      const Divider(),
                      const ThemeColorPicker(),
                      const Divider(),
                      TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Homepage Header",
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Homepage Subheader",
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Homepage About",
                        ),
                        maxLines: 10,
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.delete_outline),
                              label: const Text("Discard")),
                          const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.save_outlined),
                              label: const Text("Save")),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
