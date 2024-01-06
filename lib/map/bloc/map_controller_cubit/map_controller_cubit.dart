import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:qareeb_models/booking/trip_mediator.dart';
import 'package:qareeb_models/extensions.dart';
import 'package:qareeb_models/global.dart';
import 'package:qareeb_models/osrm/data/response/osrm_model.dart';
import 'package:qareeb_models/points/data/model/trip_point.dart';
import 'package:qareeb_models/trip_path/data/models/trip_path.dart';
import 'package:qareeb_models/trip_process/data/response/trip_response.dart';

import '../../../api_manager/api_service.dart';
import '../../../api_manager/pair_class.dart';
import '../../data/models/my_marker.dart';
import '../../utile.dart';
import '../ather_cubit/ather_cubit.dart';

part 'map_controller_state.dart';

class MapControllerCubit extends Cubit<MapControllerInitial> {
  MapControllerCubit() : super(MapControllerInitial.initial());

  var mapHeight = 640.0;
  var mapWidth = 360.0;

  void setGoogleMap(GoogleMapController controller) => state.controller = controller;

  GoogleMapController? get controller => state.controller;

  Future<LatLng?> get getCenter async {
    if (controller == null) return null;

    LatLngBounds bounds = await controller!.getVisibleRegion();

    LatLng center = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );

    return center;
  }

  void test() {}

  void addMarker({required MyMarker marker}) {
    state.markers[marker.key ?? marker.point.hashCode] = marker;
    emit(state.copyWith(markerNotifier: state.markerNotifier + 1));
  }

  void addSingleMarker({required MyMarker? marker, bool? moveTo}) {
    if (marker == null) {
      state.markers.remove(singleMarkerKey);
    } else {
      state.markers[singleMarkerKey] = marker;
      if (moveTo ?? true) movingCamera(point: marker.point);
    }

    emit(state.copyWith(markerNotifier: state.markerNotifier + 1));
  }

  void movingCamera({required LatLng point, double? zoom}) {
    emit(state.copyWith(
      point: point,
      zoom: zoom,
    ));
  }

  void addMarkers({
    required List<MyMarker> marker,
    bool update = true,
    bool centerZoom = false,
  }) {
    for (var e in marker) {
      state.markers[e.key ?? e.point.hashCode] = e;
    }
    if (centerZoom) {
      centerPointMarkers();
    } else {
      state.centerZoomPoints.clear();
    }
    if (update) emit(state.copyWith(markerNotifier: state.markerNotifier + 1));
  }

  void clearMap(bool update) {
    state.markers.removeWhere((key, value) => key != singleMarkerKey);
    state.polyLines.clear();
    if (update) {
      emit(state.copyWith(
        markerNotifier: state.markerNotifier + 1,
        polylineNotifier: state.polylineNotifier + 1,
      ));
    }
  }

  void addPath({required TripPath path,
    Function(dynamic item)? onTapMarker,
    bool? withPathLength}) {
    clearMap(false);
    addMarkers(marker: path.getMarkers(onTapMarker: onTapMarker), update: false);
    addEncodedPolyLines(
      myPolyLines: path.getPolyLines(),
      update: false,
      addPathLength: withPathLength,
    );
    centerPointMarkers();
    emit(state.copyWith(
      markerNotifier: state.markerNotifier + 1,
      polylineNotifier: state.polylineNotifier + 1,
    ));
  }

  void addTrip({required Trip trip, bool? withPathLength}) {
    addMarkers(
      marker: trip.getMarkers(),
    );

    centerPointMarkers();

    addEncodedPolyLine(
      addPathLength: withPathLength,
      myPolyLine: MyPolyLine(
        encodedPolyLine: trip.estimatedPath,
      ),
      update: false,
    );

    if (trip.preAcceptPath.isNotEmpty) {
      addEncodedPolyLine(
        myPolyLine: MyPolyLine(
          encodedPolyLine: trip.preAcceptPath,
          color: Colors.green,
        ),
        update: false,
        addPathLength: withPathLength,
      );
    }

    if (trip.actualPath.isNotEmpty) {
      addEncodedPolyLine(
        myPolyLine: MyPolyLine(
          encodedPolyLine: trip.actualPath,
          color: Colors.red,
        ),
        update: false,
        addPathLength: withPathLength,
      );
    }

    emit(state.copyWith(
      point: trip.startPoint,
      markerNotifier: state.markerNotifier + 1,
      polylineNotifier: state.polylineNotifier + 1,
    ));
  }

  void addTripMediator({required TripMediator trip, bool? withPathLength}) {
    state.markers.clear();
    state.polyLines.clear();

    addMarkers(
      marker: [
        if (trip.startIsSet)
          MyMarker(point: trip.startLocation, type: MyMarkerType.sharedPint),
        if (trip.endIsSet)
          MyMarker(point: trip.endLocation, type: MyMarkerType.sharedPint),
      ],
    );

    if (trip.canConfirm) {
      centerPointMarkers();
      addPolyLine(
          start: trip.startLocation,
          end: trip.endLocation,
          addPathLength: withPathLength);
    }

    emit(state.copyWith(
      markerNotifier: state.markerNotifier + 1,
      polylineNotifier: state.polylineNotifier + 1,
    ));
  }

  void centerPointMarkers({bool withDriver = false}) {
    if (state.markers.length == 1) return;
    state.centerZoomPoints.clear();

    for (var e in state.markers.values) {
      if (e.type != MyMarkerType.driver || withDriver) {
        state.centerZoomPoints.add(e.point);
      }
    }
  }

  void removeMarker({LatLng? point, int? key}) {
    if (point == null && key == null) return;

    state.markers.remove(key ?? point.hashCode);

    emit(state.copyWith(markerNotifier: state.markerNotifier + 1));
  }

  void removeMarkers({List<LatLng>? points, List<int>? keys}) {
    if (points == null && keys == null) return;

    if (points != null) {
      for (var e in points) {
        state.markers.remove(e.hashCode);
      }
    } else {
      for (var e in keys!) {
        state.markers.remove(e);
      }
    }

    emit(state.copyWith(markerNotifier: state.markerNotifier + 1));
  }

  void update(){
    emit(state.copyWith(
      markerNotifier: state.markerNotifier + 1,
      polylineNotifier: state.polylineNotifier + 1,
    ));
  }
  Future<void> addPolyLine({
    required LatLng? start,
    required LatLng end,
    required bool? addPathLength,
    int? key,
  }) async {
    if (start == null || start.latitude == 0 || end.latitude == 0) return;

    final pair = await getRoutePointApi(start: start, end: end);

    if (pair.first != null) {
      var list = decodePolyline(pair.first!.routes.first.geometry).unpackPolyline();
      if ((addPathLength ?? false) && list.length > 2) {
        addMarker(
          marker: MyMarker(
            point: list[list.length ~/ 2],
            costumeMarker: PathLengthWidget(
              text: '${(calculateDistance(list) / 1000).toStringAsFixed(1)} كم',
            ),
            markerSize: Size(70.0.r, 70.0.r),
          ),
        );
      }
      state.polyLines[key ?? end.hashCode] = Pair(list, Colors.black);
      emit(state.copyWith(polylineNotifier: state.polylineNotifier + 1));
    }
  }

  void addEncodedPolyLine({
    required MyPolyLine myPolyLine,
    bool update = true,
    required bool? addPathLength,
  }) {
    var list = decodePolyline(myPolyLine.encodedPolyLine).unpackPolyline();
    if ((addPathLength ?? false) && list.length > 2) {
      addMarker(
        marker: MyMarker(
          point: list[list.length ~/ 2],
          costumeMarker: PathLengthWidget(
            text: '${(calculateDistance(list) / 1000).toStringAsFixed(1)} كم',
          ),
          markerSize: Size(70.0.r, 70.0.r),
        ),
      );
    }
    myPolyLine.endPoint = TripPoint.fromJson({
      "latitude": list.lastOrNull?.latitude,
      "langitude": list.lastOrNull?.longitude,
    });

    state.polyLines[myPolyLine.key ?? myPolyLine.endPoint.hashCode] =
        Pair(list, myPolyLine.color ?? Colors.black);

    if (update) {
      emit(state.copyWith(polylineNotifier: state.polylineNotifier + 1));
    }
  }

  void addEncodedPolyLines({
    required List<MyPolyLine> myPolyLines,
    bool update = true,
    required bool? addPathLength,
  }) {
    state.polyLines.clear();
    for (var e in myPolyLines) {
      if (e.endPoint != null) {
        addMarker(
          marker: MyMarker(
            point: e.endPoint!.getLatLng,
            type: MyMarkerType.point,
            item: e.endPoint,
          ),
        );
      }
      if (e.key == null && e.endPoint == null) return;
      var list = decodePolyline(e.encodedPolyLine).unpackPolyline();
      if ((addPathLength ?? false) && list.length > 2) {
        addMarker(
          marker: MyMarker(
            point: list[list.length ~/ 2],
            costumeMarker: PathLengthWidget(
              text: '${(calculateDistance(list) / 1000).toStringAsFixed(1)} كم',
            ),
            markerSize: Size(70.0.r, 70.0.r),
          ),
        );
      }
      state.polyLines[e.key ?? e.endPoint.hashCode] = Pair(list, e.color ?? Colors.black);
    }
    if (update) emit(state.copyWith(polylineNotifier: state.polylineNotifier + 1));
  }

  Future<Pair<OsrmModel?, String?>> getRoutePointApi(
      {required LatLng start, required LatLng end}) async {
    final response = await APIService().getApi(
        url: 'route/v1/driving',
        host: 'router.project-osrm.org',
        path: '${start.longitude},${start.latitude};'
            '${end.longitude},${end.latitude}');

    if (response.statusCode == 200) {
      return Pair(OsrmModel.fromJson(jsonDecode(response.body)), null);
    } else {
      return Pair(null, 'error');
    }
  }

  Future<OsrmModel> getRoutePoint(
      {String? imei, LatLng? start, required LatLng end}) async {
    if (imei == null && start == null) {
      throw Exception();
    }
    LatLng? lld;
    if (imei != null) {
      final dl = await AtherCubit.getDriverLocationAsync(imei);
      if (dl != null) {
        lld = dl.getLatLng();
      }
    }

    if (lld == null && start == null) {
      return OsrmModel.fromJson({
        'routes': [{}]
      });
    }

    final pair = await getRoutePointApi(start: start ?? lld!, end: end);

    return pair.first ??
        OsrmModel.fromJson({
          'routes': [{}]
        });
  }

  void removePolyLine({LatLng? endPoint, int? key}) {
    if (endPoint == null && key == null) return;
    state.polyLines.remove(key ?? endPoint.hashCode);
    emit(state.copyWith(polylineNotifier: state.polylineNotifier + 1));
  }

  void addAllPoints(
      {required List<TripPoint> points, Function(dynamic item)? onTapMarker}) {
    state.markers.clear();
    addMarkers(
        marker: points.mapIndexed(
              (i, e) {
            return MyMarker(
              point: e.getLatLng,
              type: MyMarkerType.point,
              key: e.id,
              item: e,
              onTapMarker1: onTapMarker,
            );
          },
        ).toList());
  }

  void updateMarkersWithZoom(double zoom) {
    emit(state.copyWith(markerNotifier: state.markerNotifier + 1, mapZoom: zoom));
  }
}

double distanceBetween(LatLng point1, LatLng point2) {
  const p = 0.017453292519943295;
  final a = 0.5 -
      cos((point2.latitude - point1.latitude) * p) / 2 +
      cos(point1.latitude * p) *
          cos(point2.latitude * p) *
          (1 - cos((point2.longitude - point1.longitude) * p)) /
          2;
  return 12742 * asin(sqrt(a));
}

double getZoomLevel(LatLng point1, LatLng point2, double width) {
  if (point1.hashCode == point2.hashCode) {
    return 13.0;
  }
  final distance = distanceBetween(point1, point2) * 1000;
  final zoomScale = distance / (width * 0.6);
  final zoom =
      log(40075016.686 * cos(point1.latitude * pi / 180) / (256 * zoomScale)) / log(2);

  return zoom;
}
