import 'package:map_package/api_manager/api_service.dart';

import '../map/ui/widget/map_widget.dart';

class PostUrl {
  static final serverProxy =
      '${constStartUrl}services/app/HttpRequestService/ExecuteRequest';
}

String get baseUrl {
  return isAppleTestFromMapPackage ? 'proxy.cors.sh' : qareebBaseUrl;
}

String get qareebBaseUrl {
  return isAppleTestFromMapPackage ? 'livetest.qareeb-maas.com' : 'live.qareeb-maas.com';
}

String get constStartUrl {
  return isAppleTestFromMapPackage ? 'https://$qareebBaseUrl/api/' : 'api/';
}

// const baseUrlProxy = 'proxy.cors.sh';
// const baseUrlQareeb = 'livetest.qareeb-maas.com';
// const baseUrlQareebTest = 'live.qareeb-maas.com';

// final baseUrl = 'livetest.qareeb-maas.com';
