import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              'Announcements',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Filter'),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Row(
                children: [
                  const Expanded(
                    flex: 5,
                    child: MainAnnouncement(),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    flex: 3,
                    child: ListView(
                      children: const [
                        OtherAnnouncement(),
                        OtherAnnouncement(),
                        OtherAnnouncement(),
                        OtherAnnouncement(),
                        OtherAnnouncement(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainAnnouncement extends StatelessWidget {
  const MainAnnouncement({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(homeImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.amberAccent,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bingo Bonanza'.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Text(
                        'April 30, 2023 - 1PM',
                        style: Theme.of(context).textTheme.headlineSmall,
                      )
                    ],
                  ),
                  Text(
                    'View Details..',
                    style: Theme.of(context).textTheme.headlineSmall,
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class OtherAnnouncement extends StatelessWidget {
  const OtherAnnouncement({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(homeImage),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 150,
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 214, 65, 100),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Water Interruption',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'April 17, 2023',
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        ],
                      ),
                      Text(
                        'View Details..',
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
