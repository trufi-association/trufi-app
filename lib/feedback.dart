import 'package:flutter/material.dart';
import 'package:trufi_core/base/utils/util_icons/custom_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trufi_core/base/models/trufi_latlng.dart';
import 'package:trufi_core/base/blocs/providers/gps_location_provider.dart';
import 'package:trufi_core/base/pages/feedback/translations/feedback_localizations.dart';
import 'package:trufi_core/base/utils/packge_info_platform.dart';

class FeedbackPage extends StatelessWidget {
  static const String route = "/Feedback";
  final String urlFeedback;
  final String urlWhatsapp;
  final Widget Function(BuildContext) drawerBuilder;

  const FeedbackPage({
    Key? key,
    required this.drawerBuilder,
    required this.urlFeedback,
    required this.urlWhatsapp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationF = FeedbackLocalization.of(context);
    final theme = Theme.of(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Text(localizationF.menuFeedback)]),
      ),
      drawer: drawerBuilder(context),
      body: Scrollbar(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          children: <Widget>[
            Text(
              localizationF.feedbackTitle,
              style: theme.textTheme.bodyText1?.copyWith(
                fontSize: 20,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                localizationF.feedbackContent,
                style: theme.textTheme.bodyText2,
              ),
            ),
            SizedBox(height: isPortrait ? 150 : 50),
            ContactButtons(
              ontap: () {
                launch(urlWhatsapp);
              },
              icon: whatsappIcon(color: Colors.white),
              color: const Color(0xff25D366),
              text: const Text(
                'WhatsApp',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18
                ),
              ),
            ),
            const SizedBox(height: 20),
            ContactButtons(
              ontap: () async {
                String version = await PackageInfoPlatform.version();
                final TrufiLatLng? currentLocation =
                    GPSLocationProvider().myLocation;
                launch(
                  "$urlFeedback?lang=${localizationF.localeName}&geo=${currentLocation?.latitude},"
                  "${currentLocation?.longitude}&app=$version",
                );
              },
              icon: const Icon(
                Icons.email,
                color: Colors.black,
              ),
              color: Colors.grey[100]!,
              text: const Text(
                'Email',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 18
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactButtons extends StatelessWidget {
  final GestureTapCallback ontap;
  final Widget icon;
  final Widget text;
  final Color color;

  const ContactButtons({
    Key? key,
    required this.ontap,
    required this.icon,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 40,
        width: 280,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: ontap,
            borderRadius: BorderRadius.circular(50),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 15),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: icon,
                ),
                const SizedBox(width: 8),
                text,
                const SizedBox(width: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
