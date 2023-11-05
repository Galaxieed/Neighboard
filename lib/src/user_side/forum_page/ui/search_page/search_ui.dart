import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/src/user_side/forum_page/ui/search_page/search_function.dart';
import 'package:neighboard/widgets/post/post_modal.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SearchScreenUI extends SearchDelegate {
  List<PostModel> postModels = [];

  SearchScreenUI(this.screenType);
  final DeviceScreenType screenType;

  void searchPost() async {
    query.isEmpty
        ? postModels.clear()
        : postModels = await SearchFunction.searchPosts(query: query) ?? [];
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.close),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return const BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    searchPost();
    return ListView.builder(
      itemCount: postModels.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            screenType != DeviceScreenType.mobile
                ? showDialog(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                        child: PostModal(
                      postModel: postModels[index],
                      deviceScreenType: screenType,
                    )),
                  )
                : showModalBottomSheet(
                    useSafeArea: true,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => PostModal(
                      postModel: postModels[index],
                      deviceScreenType: screenType,
                    ),
                  );
          },
          leading: CircleAvatar(
            backgroundImage: postModels[index].asAnonymous
                ? const AssetImage(guestIcon) as ImageProvider
                : NetworkImage(postModels[index].profilePicture),
          ),
          title: Text(
            postModels[index].title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            postModels[index].content,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    searchPost();
    return ListView.builder(
      itemCount: postModels.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            screenType != DeviceScreenType.mobile
                ? showDialog(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                        child: PostModal(
                      postModel: postModels[index],
                      deviceScreenType: screenType,
                    )),
                  )
                : showModalBottomSheet(
                    useSafeArea: true,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => PostModal(
                      postModel: postModels[index],
                      deviceScreenType: screenType,
                    ),
                  );
          },
          leading: CircleAvatar(
            backgroundImage: postModels[index].asAnonymous
                ? const AssetImage(guestIcon) as ImageProvider
                : NetworkImage(postModels[index].profilePicture),
          ),
          title: Center(
            child: Row(
              children: [
                Text(
                  postModels[index].title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          subtitle: Text(
            postModels[index].content,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
