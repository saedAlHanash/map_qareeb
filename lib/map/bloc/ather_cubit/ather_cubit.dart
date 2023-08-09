import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saed_http/api_manager/api_service.dart';
import 'package:saed_http/api_manager/server_proxy/server_proxy_request.dart';
import 'package:saed_http/api_manager/server_proxy/server_proxy_service.dart';
import 'package:saed_http/pair_class.dart';
import 'package:qareeb_models/global.dart';
import '../../data/response/ather_response.dart';

part 'ather_state.dart';

class AtherCubit extends Cubit<AtherInitial> {
  AtherCubit() : super(AtherInitial.initial());

  Future<void> getDriverLocation(List<String> ime) async {
    if (isClosed) return;

    if (ime.isEmpty) return;

    final pair = await _getDriverLocationApi(ime);

    if (pair.first != null) {
      if (isClosed) return;
      emit(state.copyWith(statuses: CubitStatuses.done, result: pair.first));
    }
  }

  Future<Pair<List<Ime>?, String?>> _getDriverLocationApi(List<String> ime) async {
    // var ime = '359632104211708';

    final pair = await getServerProxyApi(
      request: ApiServerRequest(
        url: APIService()
            .getUri(
              url: 'api/api.php',
              query: {
                'api': 'user',
                'ver': '1.0',
                'key': '719FE559BD77F2F3461C0D29D305FA6E',
                'cmd': 'OBJECT_GET_LOCATIONS,${ime.join(';')}',
              },
              hostName: 'admin.alather.net',
            )
            .toString(),
      ),
    );

    if (pair.first != null) {
      return Pair(AtherResponse.fromJson(pair.first, ime).imes, null);
    } else {
      return Pair(null, pair.second?.body ?? '');
    }
  }
}
