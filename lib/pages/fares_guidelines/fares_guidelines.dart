import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:trufi/translations/trufi_app_localizations.dart';
import 'package:trufi_core/base/utils/util_icons/custom_icons.dart';
import 'package:trufi_core/base/widgets/basic_widgets/trufi_expansion_tile.dart';
import 'package:trufi_core/base/widgets/drawer/menu/default_pages_menu.dart';

class FaresGuideLinesPage extends StatelessWidget {
  static const String route = "/FaresGuideLines";
  static const EdgeInsets _paddingList = EdgeInsets.fromLTRB(30, 15, 15, 15);
  static final menuPage = MenuPageItem(
    id: FaresGuideLinesPage.route,
    selectedIcon: (context) => _notesEditIcon(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
    ),
    notSelectedIcon: (context) => _notesEditIcon(
      color: Colors.grey,
    ),
    name: (context) {
      return TrufiAppLocalization.of(context).menuFaresGuidelines;
    },
  );

  final Widget Function(BuildContext) drawerBuilder;

  const FaresGuideLinesPage({
    super.key,
    required this.drawerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final localizationFG = TrufiAppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Text(localizationFG.menuFaresGuidelines)]),
      ),
      drawer: drawerBuilder(context),
      body: SafeArea(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 40),
          children: [
            Text(
              localizationFG.guidelinesIntroduction,
              style: TrufiExpansionTile.styleTextContent,
            ),
            const SizedBox(height: 16),
            TrufiExpansionTile(
              padding: const EdgeInsets.symmetric(vertical: 2),
              title: localizationFG.guidelinesFareCost,
              body: Column(
                children: [
                  TrufiExpansionTile(
                    typeTitle: ExpansionTileTitleType.secondary,
                    title: localizationFG.guidelinesTransitFare,
                    body: Column(
                      children: [
                        Text(
                          localizationFG.guidelinesTransitFareIntroduction,
                          style: TrufiExpansionTile.styleTextContent,
                        ),
                        const Divider(height: 24),
                        _ListTileFare(
                            dataName:
                                localizationFG.guidelinesTypePassengerOlder,
                            value: "Bs 1,90"),
                        const Divider(),
                        _ListTileFare(
                            dataName: localizationFG
                                .guidelinesTypePassengerSeniorCitizen,
                            value: "Bs 1,50"),
                        const Divider(),
                        _ListTileFare(
                            dataName:
                                localizationFG.guidelinesTypePassengerDisabled,
                            value: "Bs 1,50"),
                        const Divider(),
                        _ListTileFare(
                            dataName: localizationFG
                                .guidelinesTypePassengerUniversityStudents,
                            value: "Bs 0,80"),
                        const Divider(),
                        _ListTileFare(
                            dataName: localizationFG
                                .guidelinesTypePassengerPrimarySecondaryStudents,
                            value: "Bs 0,50"),
                        const Divider(),
                        _ListTileFare(
                            dataName: localizationFG
                                .guidelinesTypePassengerMeritorious,
                            value: localizationFG.guidelinesExemptPay),
                        const Divider(),
                        _ListTileFare(
                            dataName: localizationFG
                                .guidelinesTypePassengerChildrenUnderFive,
                            value: localizationFG.guidelinesExemptPay),
                        const Divider(height: 24),
                        Text(
                          localizationFG.guidelinesTransitFareClarification,
                          style: TrufiExpansionTile.styleTextContent,
                        ),
                      ],
                    ),
                  ),
                  TrufiExpansionTile(
                    typeTitle: ExpansionTileTitleType.secondary,
                    padding: EdgeInsets.zero,
                    title: localizationFG.guidelinesMetropolitanFare,
                    body: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                          child: Text(
                            localizationFG
                                .guidelinesMetropolitanFareIntroduction,
                            style: TrufiExpansionTile.styleTextContent,
                          ),
                        ),
                        TrufiExpansionTile(
                          typeTitle: ExpansionTileTitleType.tertiary,
                          padding: _paddingList,
                          title: "Micro (Cochabamba - Quillacollo)",
                          body: Column(
                            children: [
                              _ListTileFare(
                                  dataName: localizationFG
                                      .guidelinesTypePassengerOlder,
                                  value: "Bs 1,90"),
                              const Divider(),
                              _ListTileFare(
                                  dataName: localizationFG
                                      .guidelinesTypePassengerSeniorCitizen,
                                  value: "Bs 1,50"),
                              const Divider(),
                              _ListTileFare(
                                  dataName: localizationFG
                                      .guidelinesTypePassengerDisabled,
                                  value: "Bs 1,50"),
                              const Divider(),
                              _ListTileFare(
                                  dataName: localizationFG
                                      .guidelinesTypePassengerUniversityStudents,
                                  value: "Bs 0,80"),
                              const Divider(),
                              _ListTileFare(
                                  dataName: localizationFG
                                      .guidelinesTypePassengerStudents,
                                  value: "Bs 0,50"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        TrufiExpansionTile(
                          typeTitle: ExpansionTileTitleType.tertiary,
                          padding: EdgeInsets.zero,
                          title: "Minibus",
                          body: Column(
                            children: [
                              const SizedBox(height: 2),
                              TrufiExpansionTile(
                                typeTitle: ExpansionTileTitleType.tertiary,
                                textAlign: TextAlign.right,
                                padding: _paddingList,
                                title: "Cochabamba - Quillacollo",
                                body: Column(
                                  children: [
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerOlder,
                                        value: "Bs 1,90"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerSeniorCitizen,
                                        value: "Bs 1,50"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerDisabled,
                                        value: "Bs 1,50"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerUniversityStudents,
                                        value: "Bs 0,80"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerStudents,
                                        value: "Bs 0,50"),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              TrufiExpansionTile(
                                typeTitle: ExpansionTileTitleType.tertiary,
                                textAlign: TextAlign.right,
                                padding: _paddingList,
                                title: "Cochabamba - El Paso",
                                body: Column(
                                  children: [
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerOlder,
                                        value: "Bs 1,90"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerSeniorCitizen,
                                        value: "Bs 1,50"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerDisabled,
                                        value: "Bs 1,50"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerUniversityStudents,
                                        value: "Bs 0,80"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerStudents,
                                        value: "Bs 0,50"),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              TrufiExpansionTile(
                                typeTitle: ExpansionTileTitleType.tertiary,
                                textAlign: TextAlign.right,
                                padding: _paddingList,
                                title: "Cochabamba - Sacaba",
                                body: Column(
                                  children: [
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerOlder,
                                        value: "Bs 1,90"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerSeniorCitizen,
                                        value: "Bs 1,50"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerDisabled,
                                        value: "Bs 1,50"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerUniversityStudents,
                                        value: "Bs 0,80"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerStudents,
                                        value: "Bs 0,50"),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              TrufiExpansionTile(
                                typeTitle: ExpansionTileTitleType.tertiary,
                                textAlign: TextAlign.right,
                                padding: _paddingList,
                                title: "Cochabamba - Sipe Sipe",
                                body: Column(
                                  children: [
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerOlder,
                                        value: "Bs 1,90"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerSeniorCitizen,
                                        value: "Bs 1,50"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerDisabled,
                                        value: "Bs 1,50"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerUniversityStudents,
                                        value: "Bs 0,80"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerStudents,
                                        value: "Bs 0,50"),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              TrufiExpansionTile(
                                typeTitle: ExpansionTileTitleType.tertiary,
                                textAlign: TextAlign.right,
                                padding: _paddingList,
                                title: "Cochabamba - Tiquipaya",
                                body: Column(
                                  children: [
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerOlder,
                                        value: "Bs 1,90"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerSeniorCitizen,
                                        value: "Bs 1,50"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerDisabled,
                                        value: "Bs 1,50"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerUniversityStudents,
                                        value: "Bs 0,80"),
                                    const Divider(),
                                    _ListTileFare(
                                        dataName: localizationFG
                                            .guidelinesTypePassengerStudents,
                                        value: "Bs 0,50"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                          child: Text(
                            localizationFG
                                .guidelinesMetropolitanFareClarification,
                            style: TrufiExpansionTile.styleTextContent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),
            const SizedBox(height: 2),
            TrufiExpansionTile(
              title: localizationFG.guidelinesPublicTransportation,
              body: Text(
                localizationFG.guidelinesPublicTransportationDescription,
                style: TrufiExpansionTile.styleTextContent,
              ),
            ),
            const SizedBox(height: 2),
            TrufiExpansionTile(
              title: localizationFG.guidelinesStops,
              body: Text(
                localizationFG.guidelinesStopsDescription,
                style: TrufiExpansionTile.styleTextContent,
              ),
            ),
            const SizedBox(height: 2),
            TrufiExpansionTile(
              title: localizationFG.guidelinesRouteIdentifiers,
              body: Text(
                localizationFG.guidelinesRouteIdentifiersDescription,
                style: TrufiExpansionTile.styleTextContent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizationFG.guidelinesClarification,
              style: TrufiExpansionTile.styleTextContent,
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTileFare extends StatelessWidget {
  final String dataName;
  final String value;

  const _ListTileFare({
    required this.dataName,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dataName,
              style: TrufiExpansionTile.styleTextContent,
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Text(
              value,
              style: TrufiExpansionTile.styleTextContent,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _notesEditIcon({Color? color, double size = 24}) {
  return Container(
    height: size,
    width: size,
    padding: const EdgeInsets.all(2),
    child: SvgPicture.string(_notesEditSvg(
      color: decodeFillColor(color),
    )),
  );
}

String _notesEditSvg({String color = '#000000'}) => '''
<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path fill='$color' stroke='$color'
        d="M13.8333 1.66667V1.16667H13.3333H1.66667H1.16667V1.66667L1.16667 13.3333V13.8333H1.66667H5.05771L4.39555 14.5H1.66667C1.02233 14.5 0.5 13.9777 0.5 13.3333V1.66667C0.5 1.02233 1.02233 0.5 1.66667 0.5H13.3333C13.9777 0.5 14.5 1.02233 14.5 1.66667V4.32672L13.8333 4.99793V1.66667ZM3.83333 7.83333V7.16667H11.1667V7.68276L11.0171 7.83333H3.83333ZM3.83333 11.1667V10.5H8.36849L7.70633 11.1667H3.83333ZM3.83333 3.83333H11.1667V4.5H3.83333V3.83333Z" />
    <path fill='$color'
        d="M10.0753 16.1506L17.9726 8.25323L16.7468 7.02738L8.84943 14.9247L10.0753 16.1506ZM10.5232 18.3665L6.63346 14.4768L15.6388 5.47148C15.9531 5.15716 16.3264 5 16.7586 5C17.1907 5 17.564 5.15716 17.8783 5.47148L19.5285 7.12167C19.8428 7.43599 20 7.80925 20 8.24144C20 8.67364 19.8428 9.04689 19.5285 9.36121L10.5232 18.3665ZM6.77491 19.1445C6.50773 19.2073 6.27199 19.1366 6.06768 18.9323C5.86337 18.728 5.79265 18.4923 5.85552 18.2251L6.63346 14.4768L10.5232 18.3665L6.77491 19.1445Z" />
</svg>
''';
