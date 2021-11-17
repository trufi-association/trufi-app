part of 'route_transports_cubit.dart';

@immutable
class RouteTransportsState extends Equatable {
  final List<PatternOtp> transports;

  const RouteTransportsState({
    @required this.transports,
  });

  RouteTransportsState copyWith({
    List<PatternOtp> transports,
  }) {
    return RouteTransportsState(
      transports: transports ?? this.transports,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transports': transports.map((x) => x.toJson()).toList(),
    };
  }

  factory RouteTransportsState.fromJson(Map<String, dynamic> json) {
    return RouteTransportsState(
      transports: json['transports']
              ?.map<PatternOtp>((dynamic json) =>
                  PatternOtp.fromJson(json as Map<String, dynamic>))
              ?.toList() as List<PatternOtp> ??
          <PatternOtp>[],
    );
  }

  @override
  List<Object> get props => [transports];

  @override
  String toString() {
    return "Preference: {  }";
  }
}
