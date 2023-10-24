import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:qareeb_models/extensions.dart';

import 'package:qareeb_models/global.dart';

import '../../../api_manager/api_service.dart';
import '../../../api_manager/pair_class.dart';
import '../../../api_manager/server_proxy/server_proxy_request.dart';
import '../../../api_manager/server_proxy/server_proxy_service.dart';
import '../../../error_manager.dart';
import '../../data/response/search_location_response.dart';

part 'search_location_state.dart';

class SearchLocationCubit extends Cubit<SearchLocationInitial> {
  SearchLocationCubit() : super(SearchLocationInitial.initial());

  Future<void> searchLocation({required String request}) async {
    if (request.isEmpty ||
        request.length < 3 ||
        request.removeSpace == state.request.removeSpace) {
      emit(state.copyWith(statuses: CubitStatuses.done, result: []));
      return;
    }
    request = 'دمشق $request';


    emit(state.copyWith(statuses: CubitStatuses.loading, request: request));

    final pair = await _searchLocationApi();

    if (pair.first != null) {
      emit(state.copyWith(statuses: CubitStatuses.done, result: pair.first));
    } else {
      emit(state.copyWith(statuses: CubitStatuses.done, result: []));
    }
  }

  Future<Pair<List<SearchLocationResult>?, String?>> _searchLocationApi() async {
    final pair = await getServerProxyApi(
      request: ApiServerRequest(
        url: APIService().getUri(
          url: 'search.php',
          hostName: 'nominatim.openstreetmap.org',
          query: {
            'q': state.request,
            'format': 'jsonv2',
            'countrycodes': 'sy',
            'accept-language': 'ar',
          },
        ).toString(),
        headers: {"Accept": "application/json", "User-Agent": "android"},
        method: 'Get',
      ),
    );

    if (pair.first != null) {
      return Pair(SearchLocationResponse.fromJson(jsonDecode(pair.first)).result, null);
    } else {
      return Pair(null, 'Error Map Server  code: ${pair.second}');
    }
  }
}
