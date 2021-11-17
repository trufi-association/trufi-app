import 'package:gql/language.dart';
import 'package:graphql/client.dart';

import 'package:trufi/route_transports/services/patter_queries.dart'
    as pattern_query;
import 'package:trufi_core/services/models_otp/pattern.dart';
import 'package:trufi_core/services/plan_request/online_graphql_repository/graphql_client/graphql_client.dart';

class RouteTransportsRepository {
  final GraphQLClient client;

  RouteTransportsRepository(String endpoint) : client = getClient(endpoint);

  Future<List<PatternOtp>> fetchPatterns() async {
    final WatchQueryOptions listPatterns = WatchQueryOptions(
      document: parseString(pattern_query.allPatterns),
      fetchResults: true,
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final dataListPatterns = await client.query(listPatterns);
    if (dataListPatterns.hasException && dataListPatterns.data == null) {
      throw dataListPatterns.exception.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Error connection");
    }
    final patterns = dataListPatterns.data['patterns']
            ?.map<PatternOtp>((dynamic json) =>
                PatternOtp.fromJson(json as Map<String, dynamic>))
            ?.toList() as List<PatternOtp> ??
        <PatternOtp>[];

    return patterns;
  }

  Future<PatternOtp> fetchDataPattern(String idStop) async {
    final WatchQueryOptions pattern = WatchQueryOptions(
      document: parseString(pattern_query.dataPattern),
      fetchResults: true,
      fetchPolicy: FetchPolicy.networkOnly,
      variables: <String, dynamic>{
        'id': idStop,
      },
    );
    final dataPattern = await client.query(pattern);
    if (dataPattern.hasException && dataPattern.data == null) {
      throw dataPattern.exception.graphqlErrors.isNotEmpty
          ? Exception("Bad request")
          : Exception("Error connection");
    }
    final stopData = PatternOtp.fromJson(
        dataPattern.data['pattern'] as Map<String, dynamic>);

    return stopData;
  }
}
