import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/models/user_model.dart';

class AdminNavDrawer extends StatefulWidget {
  const AdminNavDrawer(
      {super.key,
      required this.callback,
      required this.selectedPage,
      required this.isDrawerExpanded,
      required this.userModel});

  final UserModel userModel;
  final Function callback;
  final String selectedPage;
  final bool isDrawerExpanded;

  @override
  State<AdminNavDrawer> createState() => _AdminNavDrawerState();
}

class _AdminNavDrawerState extends State<AdminNavDrawer> {
  final ExpansionTileController _controller = ExpansionTileController();
  String selectedSubButton = "";

  changingButton(String newValue) {
    setState(() {
      selectedSubButton = newValue;
      if (newValue == 'User') {
        widget.callback(0);
      }
      if (newValue == 'Dashboard') {
        widget.callback(1);
      }
      if (newValue == 'Forum') {
        widget.callback(2);
      }
      if (newValue == 'Announcements') {
        widget.callback(3);
      }
      if (newValue == 'Community Map') {
        widget.callback(4);
      }
      if (newValue == 'Stores') {
        widget.callback(5);
      }
      if (newValue == 'Candidates') {
        widget.callback(6);
      }
      if (newValue == 'Voting') {
        widget.callback(7);
      }
      if (newValue == 'Voters') {
        widget.callback(8);
      }
      if (newValue == 'Site Settings') {
        widget.callback(9);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    selectedSubButton = widget.selectedPage;
  }

  @override
  void didUpdateWidget(covariant AdminNavDrawer oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    selectedSubButton = widget.selectedPage;
    if (selectedSubButton == "Voting") {
      _controller.expand();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ccNavDrawerBGColor(context),
      child: SafeArea(
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: 8,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              color: Colors.grey,
              height: 1,
            );
          },
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return ListTile(
                minVerticalPadding: 30,
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: widget.userModel.profilePicture != ''
                      ? NetworkImage(widget.userModel.profilePicture)
                      : const AssetImage(guestIcon) as ImageProvider,
                ),
                title: Text(
                  widget.userModel.username,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  changingButton("User");
                },
                selected: selectedSubButton == "User",
                selectedColor: Theme.of(context).colorScheme.onBackground,
                selectedTileColor: Colors.amber,
              );
            }

            if (index == 6) {
              return Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  controller: _controller,
                  textColor: Theme.of(context).primaryColor,
                  iconColor: Theme.of(context).primaryColor,
                  tilePadding: const EdgeInsets.only(left: 0, right: 5),
                  title: const Row(
                    children: <Widget>[
                      SizedBox(
                        width: 16,
                      ),
                      Icon(Icons.people),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          "HOA Voting",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: drawerItem(
                          context,
                          Icons.people_outline,
                          "Candidates",
                          selectedSubButton == "Candidates",
                          const EdgeInsets.only(left: 50)),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: drawerItem(
                          context,
                          Icons.how_to_vote,
                          "Voting",
                          selectedSubButton == "Voting",
                          const EdgeInsets.only(left: 50)),
                    ),
                    drawerItem(
                        context,
                        Icons.card_membership_outlined,
                        "Voters",
                        selectedSubButton == "Voters",
                        const EdgeInsets.only(left: 50)),
                  ],
                ),
              );
            }
            if (index == 1) {
              return drawerItem(context, Icons.dashboard_outlined, "Dashboard",
                  selectedSubButton == "Dashboard");
            }
            if (index == 2) {
              return drawerItem(context, Icons.forum_outlined, "Forum",
                  selectedSubButton == "Forum");
            }
            if (index == 3) {
              return drawerItem(context, Icons.announcement_outlined,
                  "Announcements", selectedSubButton == "Announcements");
            }
            if (index == 4) {
              return drawerItem(context, Icons.map_outlined, "Community Map",
                  selectedSubButton == "Community Map");
            }
            if (index == 5) {
              return drawerItem(context, Icons.store_outlined, "Stores",
                  selectedSubButton == "Stores");
            }
            if (index == 7) {
              return drawerItem(context, Icons.settings_outlined,
                  "Site Settings", selectedSubButton == "Site Settings");
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }

  ListTile drawerItem(
      BuildContext context, IconData icon, String title, bool isSelected,
      [EdgeInsetsGeometry? padding]) {
    return ListTile(
      contentPadding: padding,
      leading: Icon(icon),
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        changingButton(title);
        setState(() {});
      },
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.onBackground,
      selectedTileColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }
}
