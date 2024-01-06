import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:drawable_text/drawable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:latlong2/latlong.dart' as ll;
import 'package:qareeb_models/extensions.dart';
import 'package:qareeb_models/global.dart';
import 'package:qareeb_models/trip_path/data/models/trip_path.dart';
import 'package:qareeb_models/trip_process/data/response/trip_response.dart';

import 'data/models/my_marker.dart';

extension DoubleHealper on double {
  int get getZoomMarkerCount {
    if (this >= 11 && this < 12 || this < 10) return 10;
    if (this >= 12 && this < 13) return 15;
    if (this >= 13 && this < 14) return 30;
    if (this >= 14 && this < 15) return 40;
    if (this > 15) return 100000;

    return 100000;
  }
}

extension LatLngHealper on google.LatLng {
  ll.LatLng get ll2 => ll.LatLng(latitude, longitude);
}

extension GLatLngHealper on ll.LatLng {
  google.LatLng get gll => google.LatLng(latitude, longitude);
}

const initialPoint = google.LatLng(33.514631885313264, 36.27654397981723);
const initialPointBaghdad = google.LatLng(33.313120604340895, 44.37581771812867);

class CachedTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(
      getTileUrl(coordinates, options),
      //Now you can set options that determine how the image gets cached via whichever plugin you use.
    );
  }
}

const singleMarkerKey = -5622;

extension PathMap on TripPath {
  List<MyMarker> getMarkers({Function(dynamic item)? onTapMarker}) {
    final list = <MyMarker>[];
    edges.forEachIndexed(
      (i, e) {
        if (i == 0) {
          list.add(
              MyMarker(point: e.startPoint.getLatLng, type: MyMarkerType.sharedPint));
        }
        list.add(
          MyMarker(
            point: e.endPoint.getLatLng,
            type: MyMarkerType.sharedPint,
            onTapMarker1: onTapMarker,
          ),
        );
      },
    );

    return list;
  }

  List<MyPolyLine> getPolyLines() {
    final list = <MyPolyLine>[];

    edges.forEachIndexed((i, e) {
      list.add(MyPolyLine(key: i, encodedPolyLine: e.steps));
    });

    return list;
  }
}

extension NormalTripMap on Trip {
  List<MyMarker> getMarkers() {
    return [
      MyMarker(point: startPoint, type: MyMarkerType.sharedPint),
      MyMarker(point: endPoint, type: MyMarkerType.sharedPint),
      if (preAcceptPoint != null)
        MyMarker(point: preAcceptPoint!, costumeMarker: 0.0.verticalSpace),
    ];
  }
}


class PathLengthWidget extends StatelessWidget {
  const PathLengthWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0.r),
      ),
      margin: EdgeInsets.only(bottom: 20.0.h),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontFamily: FontManager.cairoBold.name,
        ),
      ),
    );
  }
}
