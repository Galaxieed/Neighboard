import 'package:flutter/material.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/src/forum_page/ui/search_page/search_function.dart';

class SearchScreenUI extends SearchDelegate {
  List<PostModel> postModels = [];
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
          onTap: () {},
          leading: CircleAvatar(
            backgroundImage: NetworkImage(postModels[index].profilePicture),
          ),
          title: Row(
            children: [
              Text(
                postModels[index].title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(postModels[index].timeStamp),
            ],
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
          onTap: () {},
          leading: CircleAvatar(
            backgroundImage: NetworkImage(postModels[index].profilePicture),
          ),
          title: Center(
            child: Row(
              children: [
                Text(
                  postModels[index].title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(postModels[index].timeStamp),
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
