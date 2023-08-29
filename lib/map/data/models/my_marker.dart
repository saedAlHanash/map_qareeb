import 'package:drawable_text/drawable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_multi_type/image_multi_type.dart';

import 'package:latlong2/latlong.dart';
import 'package:qareeb_models/global.dart';
import 'package:qareeb_models/points/data/model/trip_point.dart';

import '../../../generated/assets.dart';
import '../../bloc/map_controller_cubit/map_controller_cubit.dart';
import '../response/ather_response.dart';

extension IconPoint on num {
  String get iconPoint {
    final data = toInt() + 1;
    switch (data) {
      case 1:
        return Assets.icons1;
      case 2:
        return Assets.icons2;
      case 3:
        return Assets.icons3;
      case 4:
        return Assets.icons4;
      case 5:
        return Assets.icons5;
      case 6:
        return Assets.icons6;
      case 7:
        return Assets.icons7;
      case 8:
        return Assets.icons8;
      case 9:
        return Assets.icons9;
      case 10:
        return Assets.icons10;
      case 11:
        return Assets.icons11;
      case 12:
        return Assets.icons12;
      case 13:
        return Assets.icons13;
      case 14:
        return Assets.icons14;
      case 15:
        return Assets.icons15;
      case 16:
        return Assets.icons16;
      case 17:
        return Assets.icons17;
      case 18:
        return Assets.icons18;
      case 19:
        return Assets.icons19;
      case 20:
        return Assets.icons20;
      case 21:
        return Assets.icons21;
      case 22:
        return Assets.icons22;
      case 23:
        return Assets.icons23;
      case 24:
        return Assets.icons24;
      case 25:
        return Assets.icons25;
      case 26:
        return Assets.icons26;
    }
    return Assets.icons26;
  }
}

class MyMarker {
  LatLng point;
  num? key;
  double? bearing;
  MyMarkerType type;
  dynamic item;
  Function(dynamic item)? onTapMarker1;

  ///Number of users pickup
  String nou;

  MyMarker({
    required this.point,
    this.key,
    this.bearing,
    this.item,
    this.nou = '',
    this.onTapMarker1,
    this.type = MyMarkerType.location,
  });

  Marker getWidget(int index, {Function(MyMarker marker)? onTapMarker}) {
    switch (type) {
      case MyMarkerType.location:
        return Marker(
          point: point,
          height: 40.0.r,
          width: 40.0.r,
          builder: (context) {
            return ImageMultiType(
              url: Assets.iconsMainColorMarker,
              height: 40.0.r,
              width: 40.0.r,
            );
          },
        );
      case MyMarkerType.point:
        return Marker(
          point: point,
          height: 90.0.spMin,
          width: 150.0.spMin,
          builder: (context) {
            return InkWell(
              onTap: onTapMarker == null ? null : () => onTapMarker.call(this),
              child: Column(
                children: [
                  const ImageMultiType(
                    url: Assets.iconsMainColorMarker,
                    height: 35.0,
                    width: 35.0,
                    color: Colors.black,
                  ),
                  if (item is TripPoint)
                    Container(
                      width: 150.0.spMin,
                      color: Colors.white,
                      padding: const EdgeInsets.all(3.0).r,
                      child: DrawableText(
                        selectable: false,
                        text: (item as TripPoint).arName,
                        size: 15.0.sp,
                        maxLines: 2,
                        fontFamily: FontManager.cairoBold,
                        matchParent: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      case MyMarkerType.sharedPint:
        return Marker(
          point: point,
          height: 50.0.r,
          width: 50.0.r,
          builder: (context) {
            return Builder(builder: (context) {
              return InkWell(
                onTap: onTapMarker1 == null ? null : () => onTapMarker1?.call(item),
                child: Column(
                  children: [
                    if (nou.isNotEmpty)
                      Container(
                        height: 35.0.r,
                        width: 70.0.r,
                        margin: EdgeInsets.only(bottom: 5.0.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0.r),
                        ),
                        alignment: Alignment.center,
                        child: DrawableText(
                          text: '$nou مقعد',
                          color: Colors.black,
                          size: 12.0.sp,
                        ),
                      ),
                    ImageMultiType(
                      url: index.iconPoint,
                      height: 50.0.r,
                      width: 50.0.r,
                    ),
                  ],
                ),
              );
            });
          },
        );
      case MyMarkerType.driver:
      case MyMarkerType.bus:
        return Marker(
          point: point,
          height: 150.0.spMin,
          width: 150.0.spMin,
          builder: (context) {
            Ime? imei;
            if (item is Ime) imei = item as Ime;

            return InkWell(
              onTap: onTapMarker1 == null ? null : () => onTapMarker1?.call(item),
              child: Column(
                children: [
                  Transform.rotate(
                    angle: bearing ?? 0.0,
                    child: ImageMultiType(
                      url: Assets.iconsLocator,
                      height: 40.0.spMin,
                      width: 40.0.spMin,
                      color: imei?.speed == '0' ? Colors.red : const Color(0xFF4CA243),
                    ),
                  ),
                ],
              ),
            );
          },
        );
    }
  }

  @override
  String toString() {
    return 'MyMarker{point: $point, key: $key, type: $type, nou: $nou}';
  }
}

class MyPolyLine {
  TripPoint? endPoint;
  num? key;
  String encodedPolyLine;
  Color? color;

  MyPolyLine({this.endPoint, this.key, this.encodedPolyLine = '', this.color});
}
