import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';

Widget noPostMessage() => Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            noPost,
            width: 300,
            height: 300,
          ),
          const Text("No posts right now"),
        ],
      ),
    );
