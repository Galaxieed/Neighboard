import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/routes/routes.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: ccNavDrawerHeaderColor),
            child: Center(child: Text("NEIGHBOARD")),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Routes().navigate("Home", context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum),
            title: const Text("Forum"),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Routes().navigate("Forum", context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.announcement),
            title: const Text("Announcements"),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Routes().navigate("Announcements", context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text("Community Map"),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Routes().navigate("Community Map", context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.how_to_vote),
            title: const Text("HOA Voting"),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Routes().navigate("HOA Voting", context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text("Stores"),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Routes().navigate("Stores", context);
            },
          ),
        ],
      ),
    );
  }
}
