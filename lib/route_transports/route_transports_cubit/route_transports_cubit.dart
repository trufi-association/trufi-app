import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:trufi/route_transports/services/route_transports_repository.dart';
import 'package:trufi_core/services/models_otp/pattern.dart';

part 'route_transports_state.dart';

class RouteTransportsCubit extends Cubit<RouteTransportsState>
    with HydratedMixin {
  final RouteTransportsRepository routeTransportsRepository =
      RouteTransportsRepository("https://cbba.trufi.dev/otp");

  RouteTransportsCubit()
      : super(
          const RouteTransportsState(
            transports: [],
          ),
        ) {
  }

  Future<void> init() async {
    // hydrate();
    if (state.transports.isNotEmpty) return;
    await refresh();
  }

  Future<void> refresh() async {
    emit(state.copyWith(transports: []));
    final transports = await routeTransportsRepository.fetchPatterns();
    transports.sort((a, b) {
      int res = -1;
      final aShortName = int.tryParse(a.route.shortName);
      final bShortName = int.tryParse(b.route.shortName);
      if (aShortName != null && bShortName != null) {
        res = aShortName.compareTo(bShortName);
      } else if (aShortName == null && bShortName == null) {
        res = a.route.shortName.compareTo(b.route.shortName);
      } else if (aShortName != null) {
        res = 1;
      }
      return res;
    });
    emit(state.copyWith(transports: transports));
  }

  Future<PatternOtp> fetchDataPattern(PatternOtp pattern) async {
    if (pattern.patternGeometry != null) return pattern;
    final newPattern =
        await routeTransportsRepository.fetchDataPattern(pattern.code);
    emit(
      state.copyWith(
          transports: [..._updateItem(state.transports, pattern, newPattern)]),
    );
    return newPattern;
  }

  List<PatternOtp> _updateItem(
    List<PatternOtp> list,
    PatternOtp oldLocation,
    PatternOtp newLocation,
  ) {
    final tempList = [...list];
    final int index = tempList.indexOf(oldLocation);
    if (index != -1) {
      tempList.replaceRange(index, index + 1, [
        oldLocation.copyWith(
          patternGeometry: newLocation.patternGeometry,
          stops: newLocation.stops,
        )
      ]);
    }
    return tempList;
  }

  @override
  RouteTransportsState fromJson(Map<String, dynamic> json) =>
      RouteTransportsState.fromJson(json);

  @override
  Map<String, dynamic> toJson(RouteTransportsState state) => state.toJson();
}
