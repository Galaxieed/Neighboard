import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';

void successMessage(
    {required String title,
    required String desc,
    required BuildContext context,
    int? duration}) {
  ElegantNotification.success(
    width: 360,
    toastDuration: Duration(seconds: duration ?? 3),
    notificationPosition: NotificationPosition.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
    description: Text(
      desc,
      style: const TextStyle(color: Colors.black),
    ),
    onDismiss: () {},
  ).show(context);
}

void errorMessage(
    {required String title,
    required String desc,
    required BuildContext context,
    int? duration}) {
  ElegantNotification.error(
    width: 360,
    toastDuration: Duration(seconds: duration ?? 3),
    notificationPosition: NotificationPosition.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
    description: Text(
      desc,
      style: const TextStyle(color: Colors.black),
    ),
    onDismiss: () {},
  ).show(context);
}

void infoMessage(
    {required String title,
    required String desc,
    required BuildContext context}) {
  ElegantNotification.info(
    width: 360,
    notificationPosition: NotificationPosition.bottomRight,
    animation: AnimationType.fromRight,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
    description: Text(
      desc,
      style: const TextStyle(color: Colors.black),
    ),
    onDismiss: () {},
  ).show(context);
}
