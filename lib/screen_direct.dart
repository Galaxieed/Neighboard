import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/admin_side/admin_side.dart';
import 'package:neighboard/src/landing_page/ui/landing_page.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page.dart';

String myToken = '';

class ScreenDirect extends StatefulWidget {
  const ScreenDirect({super.key});

  @override
  State<ScreenDirect> createState() => _ScreenDirectState();
}

class _ScreenDirectState extends State<ScreenDirect> {
  bool isLoggedIn = false, isLoading = true, firstRun = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot>? subscription;

  UserModel? userModel;

  void checkIfUserLoggedIn() async {
    setState(() {
      isLoading = true;
    });
    if (_auth.currentUser != null) {
      await getUserDetails(_auth.currentUser!.uid);
      Map<String, dynamic> deviceToken = {
        'device_token': myToken,
      };

      await ProfileFunction.updateUserProfile(deviceToken);
      isLoggedIn = true;
      listenForNotification();
    } else {
      isLoggedIn = false;
      subscription?.cancel();
    }
    setState(() {
      isLoading = false;
    });
  }

  getUserDetails(userId) async {
    userModel = await ProfileFunction.getUserDetails(userId);
  }

  //for Web
  List<NotificationModel> notificationModels = [];
  void listenForNotification() {
    if (isLoggedIn) {
      subscription = _firestore
          .collection("notifications")
          .doc(_auth.currentUser!.uid)
          .collection("all")
          .snapshots()
          .listen(
        (snapshot) {
          //These conditions is to prevent notifications from showing when the current user reads the notification
          if (notificationModels.isEmpty) {
            notificationModels = snapshot.docs
                .map((e) => NotificationModel.fromJson(e.data()))
                .toList();
            if (!firstRun && mounted) {
              showElegantNotification(notificationModels[0]);
            } else {
              firstRun = false;
            }
          } else {
            List<NotificationModel> notificationModels1 = snapshot.docs
                .map((e) => NotificationModel.fromJson(e.data()))
                .toList();

            //kapag may bagong notification
            if (notificationModels.length < notificationModels1.length) {
              notificationModels = notificationModels1;
              if (!firstRun && mounted) {
                showElegantNotification(
                    notificationModels[notificationModels.length - 1]);
              } else {
                firstRun = false;
              }
            }
          }
        },
        onError: (error) {
          print(error);
        },
        onDone: () {},
      );
    } else {
      firstRun = false;
    }
  }

  void showElegantNotification(NotificationModel notification) async {
    ElegantNotification.info(
      width: 360,
      notificationPosition: NotificationPosition.bottomLeft,
      animation: AnimationType.fromLeft,
      title: Text(notification.notifTitle),
      description: Text(
        notification.notifBody,
      ),
      showProgressIndicator: true,
      onDismiss: () {},
    ).show(context);
  }

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    super.initState();
    getToken();
    checkIfUserLoggedIn();
  }

  getToken() async {
    myToken = await _messaging.getToken() ?? '';
    print("TOKEN: $myToken");
  }

  Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
    // Handle the message data
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'launch_background',
          ),
        ),
      );
    } else if (notification != null && kIsWeb) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(notification.title.toString()),
          content: Text(notification.body.toString()),
        ),
      );
    }
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'launch_background',
          ),
        ),
      );
    } else if (notification != null && kIsWeb) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(notification.title.toString()),
          content: Text(notification.body.toString()),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    //getToken();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingScreen();
    }
    if (isLoggedIn) {
      if (userModel!.role == "ADMIN") {
        return const AdminSide();
      } else {
        return const ForumPage();
      }
    } else {
      return const LandingPage();
    }
  }
}
