import 'package:map_package/api_manager/api_service.dart';

import '../map/ui/widget/map_widget.dart';
import 'dart:io';

class PostUrl {
  static const serverProxy =
      'api/services/app/HttpRequestService/ExecuteRequest';
}

String get baseUrl {
  if (Platform.isIOS) {
    if (isAppleTestFromMapPackage) return testUrl;
  }

  return liveUrl;
}

const liveUrl = 'live.qareeb-maas.com';
const testUrl = 'qareeb-api.first-pioneers.com.tr';


