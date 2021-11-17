import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/models/enums/enums_plan/enums_plan.dart';
import 'package:trufi_core/services/models_otp/pattern.dart';

class TileTransport extends StatelessWidget {
  final PatternOtp patternOtp;
  final GestureTapCallback onTap;

  const TileTransport({
    Key key,
    @required this.patternOtp,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: patternOtp.route?.color != null
                              ? Color(int.tryParse(
                                  "0xFF${patternOtp.route?.color}"))
                              : patternOtp.route?.mode?.backgroundColor ??
                                  Colors.black,
                          borderRadius:
                              BorderRadius.horizontal(left: Radius.circular(5)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              patternOtp.route?.shortName ?? '',
                              style: theme.primaryTextTheme.headline6.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              patternOtp.route?.mode
                                      ?.getTranslate(localization) ??
                                  '',
                              style: theme.primaryTextTheme.headline6.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius:
                            BorderRadius.horizontal(right: Radius.circular(5)),
                      ),
                      child: Icon(
                        patternOtp.route?.mode?.icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.7),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(5),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(5),
                      ),
                    ),
                    child: Text(
                      patternOtp.route.longName,
                      style: theme.textTheme.subtitle1
                          .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 30,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
