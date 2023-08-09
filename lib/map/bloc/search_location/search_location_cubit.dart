import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:qareeb_models/global.dart';
import 'package:saed_http/api_manager/api_service.dart';
import 'package:saed_http/api_manager/server_proxy/server_proxy_service.dart';
import 'package:saed_http/pair_class.dart';

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
    request = 'دمشق $request'.removeDuplicates;

    emit(state.copyWith(statuses: CubitStatuses.loading, request: request));
    final pair = await _searchLocationApi();

    if (pair.first != null) {
      emit(state.copyWith(statuses: CubitStatuses.done, result: pair.first));
    } else {
      emit(state.copyWith(statuses: CubitStatuses.done, result: []));
    }
  }

  Future<Pair<List<SearchLocationResult>?, String?>> _searchLocationApi() async {

      final response = await APIService().getApi(
        url: 'search.php',
        hostName: 'nominatim.openstreetmap.org',
        query: {
          'q': state.request,
          'dedupe': 0,
          // 'accept-language': 'ar',
          // 'countrycodes': 'sy',
          'format': 'jsonv2'
        },
      );

      if (response.statusCode == 200) {
        return Pair(SearchLocationResponse.fromJson(response.json).result, null);
      } else {
        return Pair(null, ErrorManager.getApiError(response));
      }

  }
}
