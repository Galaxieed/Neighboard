import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:neighboard/models/post_model.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PostPage extends StatefulWidget {
  const PostPage(
      {super.key, required this.postModel, required this.deviceScreenType});

  final PostModel postModel;
  final DeviceScreenType deviceScreenType;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  CarouselController carouselController = CarouselController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
        ),
        title: Text(
          "${widget.postModel.authorName}'s Post",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CarouselSlider(
              carouselController: carouselController,
              items: widget.postModel.images.map((e) {
                return Image.network(
                  e,
                );
              }).toList(),
              options: CarouselOptions(
                autoPlay: true,
                enableInfiniteScroll: true,
                viewportFraction: 1,
                aspectRatio: widget.deviceScreenType == DeviceScreenType.mobile
                    ? 3 / 4
                    : 16 / 9,
              ),
            ),
            Positioned(
              left: 5,
              child: IconButton(
                onPressed: () {
                  carouselController.previousPage();
                },
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height,
                ),
                style:
                    IconButton.styleFrom(shape: const BeveledRectangleBorder()),
                icon: const Icon(Icons.keyboard_arrow_left),
              ),
            ),
            Positioned(
              right: 5,
              child: IconButton(
                onPressed: () {
                  carouselController.nextPage();
                },
                style:
                    IconButton.styleFrom(shape: const BeveledRectangleBorder()),
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height,
                ),
                icon: const Icon(Icons.keyboard_arrow_right),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
