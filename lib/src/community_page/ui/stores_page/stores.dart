import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/widgets/navigation_bar/navigation_bar.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({Key? key}) : super(key: key);

  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
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
              'Stores',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 400 / 300,
                ),
                children: [
                  for (int i = 0; i < 20; i++) const StoresCards(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoresCards extends StatelessWidget {
  const StoresCards({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
              image: const DecorationImage(
                  image: AssetImage('assets/bigscoop.jpg'), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(5)),
          child: Column(
            children: [
              const Expanded(child: SizedBox()),
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Chilly Choice',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Block 12 Lot 18, Zaragosa Street',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 32,
                                ),
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    width: 600,
                                    height: 600,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(bigScoopImage),
                                          fit: BoxFit.cover),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 214, 65, 100),
                      borderRadius: BorderRadius.circular(5)),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chilly Choice',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
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
