import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/src/loading_screen/post_shimmer.dart';

class LoadingPosts extends StatelessWidget {
  const LoadingPosts({super.key, this.postType});

  final String? postType;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: 5,
        itemBuilder: (_, __) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 5.h),
            child: PostShimmer(
              postType: postType,
            ),
          );
        });
  }
}
