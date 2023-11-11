import 'dart:math';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

String formattedDate([DateTime? dateTime]) =>
    DateFormat('MMMM d, yyyy | hh:mm a').format(dateTime ?? DateTime.now());

String formatPhoneNumbers(String input) {
  final pattern = RegExp(r'(\d{4})(\d{3})(\d{4})');
  return input.replaceAllMapped(pattern, (match) {
    return '(${match[1]}) ${match[2]}-${match[3]}';
  });
}

// String randomName = WordPair.random().asPascalCase.toString();

final random = Random();
String generateRandomId(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final id = String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  return id;
}
