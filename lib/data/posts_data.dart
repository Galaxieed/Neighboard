import 'dart:math';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

String formattedDate() =>
    DateFormat('MMMM d, yyyy | hh:mm a').format(DateTime.now());

// String randomName = WordPair.random().asPascalCase.toString();

final random = Random();
String generateRandomId(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final id = String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  return id;
}
