import 'package:flutter/material.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/widgets/post/post_interactors_function.dart';

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
            widget.postModel.postId, widget.collection) ??
        [];

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      child: SizedBox(
        width: 720,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "${widget.postModel.authorName}'s ${widget.collection.toLowerCase()}",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: isLoading
              ? const LoadingScreen()
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
                              onTap: () {},
                              leading: userModels[index].profilePicture == ""
                                  ? const CircleAvatar()
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(
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
      ),
    );
  }
}
