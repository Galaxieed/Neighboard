import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:neighboard/data/posts_data.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/notification_model.dart';
import 'package:neighboard/models/user_model.dart';
import 'package:neighboard/src/admin_side/admin_side.dart';
import 'package:neighboard/src/landing_page/ui/landing_page.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/profile_screen/profile_screen_function.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_page_ui.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:page_transition/page_transition.dart';

String myToken = '';
List<NotificationModel> notificationModels = [];
StreamSubscription<QuerySnapshot>? notifSubscription;
StreamSubscription<QuerySnapshot>? chatSubscription;

String siteContactNo = "";
String officeAddress = "";

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

  UserModel? userModel;

  void checkIfUserLoggedIn() async {
    setState(() {
      isLoading = true;
    });
    //pag naka login
    if (_auth.currentUser != null) {
      bool emailVerified = _auth.currentUser!.emailVerified;
      //exemptedUser for email verification
      List<String> exemptedUser = [
        '2jB7wg7PFZUV382mpTId2dqoTyL2',
        '8Jnmea0EkxgwTOLNpA9PQjm85j72',
        'sJuGAwN3Ena76LVIdJIdudfPSmh2',
        'v0HBgPZPb3OxY4VsQAWrI2oY4rF2',
      ];
      //pag di verified saka di exempted
      if (!emailVerified && !exemptedUser.contains(_auth.currentUser!.uid)) {
        //this delete() throws an error if session was made long ago. Then catch
        await _auth.currentUser!.delete().catchError((e) {
          _auth.signOut();
          infoMessage(
              title: "Login session expired",
              desc: "Please login again",
              context: context);
          Navigator.of(context).pushReplacement(PageTransition(
              child: const LoginPage(), type: PageTransitionType.fade));
        });

        // ignore: use_build_context_synchronously
        infoMessage(
            title: "",
            desc:
                "Current account is not verified\nRegister again and verify your email",
            context: context);
        isLoggedIn = false;
      } else {
        //exempted user logins without any additional requirements
        if (exemptedUser.contains(_auth.currentUser!.uid)) {
          await getUserDetails(_auth.currentUser!.uid);
          Map<String, dynamic> deviceToken = {
            'device_token': myToken,
          };

          await ProfileFunction.updateUserProfile(deviceToken);
          isLoggedIn = true;
          listenForNotification();
        } else {
          final mfa = await _auth.currentUser!.multiFactor.getEnrolledFactors();
          //pag walang mfa si user, mag signout
          if (mfa.isEmpty) {
            _auth.signOut();
            return;
          }
          await getUserDetails(_auth.currentUser!.uid);
          Map<String, dynamic> deviceToken = {
            'device_token': myToken,
          };

          await ProfileFunction.updateUserProfile(deviceToken);
          isLoggedIn = true;
          listenForNotification();
        }
      }
    } else {
      isLoggedIn = false;
    }
    setState(() {
      isLoading = false;
    });
  }

  getUserDetails(userId) async {
    userModel = await ProfileFunction.getUserDetails(userId);
  }

  void listenForNotification() {
    if (isLoggedIn) {
      notifSubscription = _firestore
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
          errorMessage(title: "Error!", desc: error, context: context);
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

  getToken() async {
    myToken = await _messaging.getToken() ?? '';
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

  List<String> contactNo = [];
  void displayNo() {
    officeAddress = siteModel?.siteOfficeAddress ?? "";
    contactNo = siteModel?.siteContactNo ?? [];
    if (contactNo.isNotEmpty) {
      for (int i = 0; i < contactNo.length; i++) {
        if (i == 0) {
          siteContactNo = formatPhoneNumbers(contactNo[i]);
        } else {
          siteContactNo += " | ${formatPhoneNumbers(contactNo[i])}";
        }
      }
    }
  }

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    super.initState();
    displayNo();
    getToken();
    checkIfUserLoggedIn();
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
        return ForumPage();
      }
    } else {
      return const LandingPage();
    }
  }
}
