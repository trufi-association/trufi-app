import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/menu/social_media/facebook_social_media.dart';
import 'package:trufi_core/models/menu/social_media/instagram_social_media.dart';
import 'package:trufi_core/models/menu/social_media/social_media_item.dart';
import 'package:trufi_core/models/menu/social_media/twitter_social_media.dart';
import 'package:trufi_core/models/menu/social_media/website_social_media.dart';
import 'package:trufi_core/utils/util_icons/custom_icons.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:trufi_core/models/menu/default_item_menu.dart';
import 'package:trufi_core/models/menu/default_pages_menu.dart';
import 'package:trufi_core/models/menu/menu_item.dart';

final List<List<MenuItem>> menuItems = [
  DefaultPagesMenu.values.map((menuPage) => menuPage.toMenuPage()).toList(),
  [
    ...DefaultItemsMenu.values
        .map((menuPage) => menuPage.toMenuItem())
        .toList(),
    donateItem,
    AppShareButtonMenu(""),
    socialMediaItems
  ],
];

final donateItem = SimpleMenuItem(
  buildIcon: (context) => const Icon(
    Icons.monetization_on,
    color: Colors.grey,
  ),
  name: (context) {
    final localization = TrufiLocalization.of(context);
    return MenuItem.buildName(
      context,
      localization.donate,
    );
  },
  onClick: () => launch("https://donorbox.org/trufi-association"),
);

final socialMediaItems = SimpleMenuItem(
    buildIcon: (context) => const Icon(CustomIcons.trufi),
    name: (context) {
      final theme = Theme.of(context);
      final languageCode = Localizations.localeOf(context).languageCode;
      return DropdownButton<SocialMediaItem>(
        icon: Row(
          children: [
            Text(languageCode == "de"
                ? "Soziale Medien"
                : languageCode == "es"
                    ? "Redes sociales"
                    : "Social media"),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
        selectedItemBuilder: (_) => [],
        underline: Container(),
        style: theme.textTheme.bodyText1,
        onChanged: (SocialMediaItem value) {
          value.onClick(context, true);
        },
        items: <SocialMediaItem>[
          WebSiteSocialMedia("https://www.trufi.app/blog/"),
          FacebookSocialMedia("https://m.facebook.com/trufiapp"),
          TwitterSocialMedia("https://mobile.twitter.com/TrufiAssoc"),
          InstagramSocialMedia("https://www.instagram.com/trufi.app/"),
        ].map((SocialMediaItem value) {
          return DropdownMenuItem<SocialMediaItem>(
            value: value,
            child: Row(
              children: [
                value.notSelectedIcon(context),
                value.name(context),
              ],
            ),
          );
        }).toList(),
      );
    });
