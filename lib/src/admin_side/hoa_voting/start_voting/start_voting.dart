import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/widgets/others/tab_header.dart';

class StartVoting extends StatelessWidget {
  const StartVoting({super.key, required this.drawer});

  final Function drawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 15.w),
      child: Column(
        children: [
          TabHeader(
            title: "Candidates List",
            callback: () {
              drawer();
            },
          ),
          SizedBox(
            height: 20.h,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.date_range_outlined),
                        label: const Text("Start of Election")),
                    ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.date_range_outlined),
                        label: const Text("End of Election"))
                  ],
                ),
                ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.start_outlined),
                    label: const Text("Begin Election"))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
