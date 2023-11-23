import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/widgets/post/post_interactors_function.dart';

//FOR SHOWING NO OF VIEWS AND UPVOTES (People)
class PostInteractors extends StatefulWidget {
  const PostInteractors({
    super.key,
    required this.postModel,
    required this.collection,
  });

  final String collection;
  final PostModel postModel;

  @override
  State<PostInteractors> createState() => _PostInteractorsState();
}

class _PostInteractorsState extends State<PostInteractors> {
  bool isLoading = true;
  List<UserModel> userModels = [];

  void getData() async {
    userModels = await PostInteractorsFunctions.getPostInteractorsData(
            widget.postModel.postId, widget.collection, reaction) ??
        [];

    setState(() {
      isLoading = false;
    });
  }

  String reaction = "All";

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 720,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.postModel.asAnonymous
                ? "Anonymous' ${widget.collection.toLowerCase()}"
                : "${widget.postModel.authorName}'s ${widget.collection.toLowerCase()}",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const LoadingScreen()
            : widget.collection.toLowerCase() == "upvotes"
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  reaction = "All";
                                  getData();
                                },
                                child: const Text("All"),
                              ),
                              if (reaction == "All")
                                Text(userModels.length.toString()),
                              const SizedBox(
                                width: 20,
                              ),
                              IconButton(
                                onPressed: () {
                                  reaction = "Like";
                                  getData();
                                },
                                icon: Icon(
                                  Icons.thumb_up,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              if (reaction == "Like")
                                Text(userModels.length.toString()),
                              const SizedBox(
                                width: 20,
                              ),
                              IconButton(
                                onPressed: () {
                                  reaction = "Love";
                                  getData();
                                },
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ),
                              if (reaction == "Love")
                                Text(userModels.length.toString()),
                              const SizedBox(
                                width: 20,
                              ),
                              IconButton(
                                onPressed: () {
                                  reaction = "Star";
                                  getData();
                                },
                                icon: const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                              ),
                              if (reaction == "Star")
                                Text(userModels.length.toString()),
                            ],
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: userModels.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      userModels[index].profilePicture == ""
                                          ? const AssetImage(guestIcon)
                                              as ImageProvider
                                          : NetworkImage(
                                              userModels[index].profilePicture),
                                ),
                                title: Text(userModels[index].username),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: userModels.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      userModels[index].profilePicture == ""
                                          ? const AssetImage(guestIcon)
                                              as ImageProvider
                                          : NetworkImage(
                                              userModels[index].profilePicture),
                                ),
                                title: Text(userModels[index].username),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
