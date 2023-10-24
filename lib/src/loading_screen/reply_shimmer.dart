import 'package:flutter/material.dart';
import 'package:neighboard/main.dart';
import 'package:shimmer/shimmer.dart';

class ReplyShimmer extends StatelessWidget {
  const ReplyShimmer({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            decoration: const BoxDecoration(
              border:
                  Border(left: BorderSide(color: Colors.blueAccent, width: 5)),
            ),
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
              top: 10,
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[isDarkMode ? 700 : 400]!,
              highlightColor: Colors.grey[isDarkMode ? 500 : 100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const Divider(),
                  !isLoggedIn
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 12,
                              color: Theme.of(context).colorScheme.background,
                            ),
                            const Expanded(
                                child: SizedBox(
                              width: 10,
                            )),
                            TextButton.icon(
                              onPressed: () {},
                              icon: Icon(
                                Icons.reply_outlined,
                                color: Theme.of(context).colorScheme.background,
                              ),
                              label: Text(
                                'Reply',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
