import 'package:url_launcher/url_launcher.dart';

Future<void> launcherUrl(String url) async {
  final Uri urlUri = Uri.parse(url);
  if (await canLaunchUrl(urlUri)) {
    await launchUrl(urlUri);
  } else {
    throw 'Could not launch $url';
  }
}
