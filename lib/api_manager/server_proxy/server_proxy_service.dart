
import 'dart:convert';

import 'package:map_package/api_manager/server_proxy/server_proxy_request.dart';
import 'package:http/http.dart' as http;
import '../../error_manager.dart';
import '../api_service.dart';
import '../api_url.dart';
import '../pair_class.dart';


extension MapResponse on http.Response {
  dynamic get json => jsonDecode(body);
}

 Future<Pair<dynamic, String?>>  getServerProxyApi(
    {required ApiServerRequest request}) async {

    final response =
        await APIService().postApi(url: PostUrl.serverProxy, body: request.toJson());

    if (response.statusCode == 200) {
      return Pair(response.json['result'], null);
    } else {
      return Pair(null, ErrorManager.getApiError(response));
    }

}
