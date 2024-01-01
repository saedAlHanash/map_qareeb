import 'dart:ui' as ui;

import 'package:drawable_text/drawable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_map;
import 'package:image_multi_type/image_multi_type.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:qareeb_models/global.dart';
import 'package:qareeb_models/points/data/model/trip_point.dart';

import '../../../generated/assets.dart';
import '../response/ather_response.dart';

Future<Uint8List> getBytesFromAsset(String path, num width) async {
  final data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width.toInt());
  ui.FrameInfo fi = await codec.getNextFrame();
  final bytes =
      (await fi.image.toByteData(format: ui.ImageByteFormat.png))?.buffer.asUint8List() ??
          Uint8List(0);
  return bytes;
}

Future<Uint8List> getBytesFromCanvas(int width, int height) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..color = Colors.blue;
  const  radius =  Radius.circular(20.0);
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      paint);
  TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
  painter.text = const TextSpan(
    text: 'Hello world',
    style: TextStyle(fontSize: 25.0, color: Colors.white),
  );
  painter.layout();
  painter.paint(canvas,
      Offset((width * 0.5) - painter.width * 0.5, (height * 0.5) - painter.height * 0.5));
  final img = await pictureRecorder.endRecording().toImage(width, height);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return data?.buffer.asUint8List() ?? Uint8List(0);
}


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
  google_map.LatLng point;
  num? key;
  double? bearing;
  MyMarkerType type;
  dynamic item;
  Size? markerSize;
  Widget? costumeMarker;
  Function(dynamic item)? onTapMarker1;

  ///Number of users pickup
  String nou;

  MyMarker({
    required this.point,
    this.key,
    this.bearing,
    this.item,
    this.markerSize,
    this.nou = '',
    this.onTapMarker1,
    this.costumeMarker,
    this.type = MyMarkerType.location,
  });

  Marker getWidget(int index) {
    switch (type) {
      case MyMarkerType.location:
        return Marker(
          point: ll.LatLng(point.latitude, point.longitude),
          height: markerSize?.height ?? 40.0.r,
          width: markerSize?.width ?? 40.0.r,
          builder: (context) {
            return costumeMarker ??
                ImageMultiType(
                  url: Assets.iconsMainColorMarker,
                  height: 40.0.r,
                  width: 40.0.r,
                );
          },
        );
      case MyMarkerType.point:
        return Marker(
          point: ll.LatLng(point.latitude, point.longitude),
          height: markerSize?.height ?? 110.0.spMin,
          width: markerSize?.width ?? 150.0.spMin,
          builder: (context) {
            return costumeMarker ??
                InkWell(
                  onTap: onTapMarker1 == null ? null : () => onTapMarker1!.call(item),
                  child: Column(
                    children: [
                      const ImageMultiType(
                        url: Assets.iconsMainColorMarker,
                        height: 35.0,
                        width: 35.0,
                        color: Colors.black,
                      ),
                      if (item is TripPoint)
                        SizedBox(
                          width: 150.0.spMin,
                          child: DrawableText(
                            selectable: false,
                            text: (item as TripPoint).arName,
                            size: 14.0.sp,
                            maxLines: 2,
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
          point: ll.LatLng(point.latitude, point.longitude),
          height: markerSize?.height ?? 50.0.r,
          width: markerSize?.width ?? 50.0.r,
          builder: (context) {
            return costumeMarker ??
                InkWell(
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
          },
        );
      case MyMarkerType.driver:
      case MyMarkerType.bus:
        return Marker(
          point: ll.LatLng(point.latitude, point.longitude),
          height: markerSize?.height ?? 150.0.spMin,
          width: markerSize?.width ?? 150.0.spMin,
          builder: (context) {
            return costumeMarker ??
                InkWell(
                  onTap: onTapMarker1 == null ? null : () => onTapMarker1?.call(item),
                  child: Column(
                    children: [
                      Transform.rotate(
                        angle: bearing ?? 0.0,
                        child: ImageMultiType(
                          url: Assets.iconsCarTopView,
                          height: 40.0.spMin,
                          width: 40.0.spMin,
                        ),
                      ),
                    ],
                  ),
                );
          },
        );
    }
  }

  Future<google_map.Marker> getWidgetGoogleMap(
      {required int index,
        required num key,
        Function(MyMarker marker)? onTapMarker}) async {
    switch (type) {
      case MyMarkerType.location:
        final icon = google_map.BitmapDescriptor.fromBytes(
            await getBytesFromAsset(Assets.iconsMainColorMarker, 500.0.r));

        return google_map.Marker(
          markerId: google_map.MarkerId(key.toString()),
          position: point,
          icon: icon,
        );
      default:
        return google_map.Marker(
          markerId: google_map.MarkerId(key.toString()),
          position: point,
          icon: google_map.BitmapDescriptor.defaultMarkerWithHue(10),
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
