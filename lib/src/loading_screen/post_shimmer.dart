import 'package:flutter/material.dart';
import 'package:neighboard/main.dart';
import 'package:shimmer/shimmer.dart';

class PostShimmer extends StatelessWidget {
  const PostShimmer({super.key, this.postType});

  final String? postType;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[isDarkMode ? 700 : 400]!,
          highlightColor: Colors.grey[isDarkMode ? 500 : 100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    radius: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 80,
                          height: 16,
                          color: Theme.of(context).colorScheme.background,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: 100,
                          height: 12,
                          color: Theme.of(context).colorScheme.background,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: 150,
                height: 12,
                color: Theme.of(context).colorScheme.background,
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                height: 12,
                color: Theme.of(context).colorScheme.background,
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                height: 12,
                color: Theme.of(context).colorScheme.background,
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              postType == "My Posts"
                  ? const MyPostActionBar()
                  : const ActionBarPosts()
            ],
          ),
        ),
      ),
    );
  }
}

class ActionBarPosts extends StatelessWidget {
  const ActionBarPosts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.remove_red_eye_outlined),
          style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.background),
        ),
        const Text("0"),
        const SizedBox(
          width: 20,
        ),
        AbsorbPointer(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mode_comment_outlined),
            style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.background),
          ),
        ),
        const Text("0"),
        const SizedBox(
          width: 20,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_upward),
          style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.background),
        ),
        const Text("0"),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }
}

class MyPostActionBar extends StatelessWidget {
  const MyPostActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Wrap(
            spacing: 16,
            children: [
              ActionChip(
                avatar: CircleAvatar(
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  child: const Text(" "),
                ),
                label: Text(
                  "     ",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                backgroundColor: Theme.of(context).disabledColor,
                side: BorderSide.none,
                onPressed: () {},
              )
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.arrow_upward_rounded),
          label: const Text("    "),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.background),
        )
      ],
    );
  }
}
