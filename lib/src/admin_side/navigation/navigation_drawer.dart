import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';

class AdminNavDrawer extends StatelessWidget {
  const AdminNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ccNavDrawerBGColor(context),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            minVerticalPadding: 30,
            leading: const CircleAvatar(
              radius: 25,
              child: Icon(Icons.person),
            ),
            title: const Text("User"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text("Dashboard"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.forum_outlined),
            title: const Text("Forum"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.announcement_outlined),
            title: const Text("Announcements"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.store_outlined),
            title: const Text("Stores"),
            onTap: () {},
          ),
          const Divider(),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
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
                    child: Text("HOA Voting"),
                  ),
                ],
              ),
              children: [
                const Divider(),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 50),
                  leading: const Icon(Icons.people_outline),
                  title: const Text("Candidates"),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 50),
                  leading: const Icon(Icons.how_to_vote),
                  title: const Text("Voting"),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 50),
                  leading: const Icon(Icons.card_membership_outlined),
                  title: const Text("Voters"),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text("Site Settings"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
