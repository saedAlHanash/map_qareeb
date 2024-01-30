import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_multi_type/image_multi_type.dart';
import 'package:map_package/api_manager/api_service.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'dart:math' as math;
import '../../../generated/assets.dart';
import '../../bloc/ather_cubit/ather_cubit.dart';
import '../../bloc/map_controller_cubit/map_controller_cubit.dart';
import '../../bloc/set_point_cubit/map_control_cubit.dart';

import '../../utile.dart';
import 'map_widget.dart';

class GMapWidget extends StatefulWidget {
  const GMapWidget({
    Key? key,
    this.onMapReady,
    this.initialPoint,
    this.search,
    this.updateMarkerWithZoom,
    this.onMapClick,
    this.atherListener = true,
  }) : super(key: key);

  final Function(GoogleMapController controller)? onMapReady;
  final Function(LatLng latLng)? onMapClick;
  final Function()? search;
  final LatLng? initialPoint;
  final bool? updateMarkerWithZoom;
  final bool atherListener;

  GlobalKey<GMapWidgetState> getKey() {
    return GlobalKey<GMapWidgetState>();
  }

  @override
  State<GMapWidget> createState() => GMapWidgetState();
}

class GMapWidgetState extends State<GMapWidget> with TickerProviderStateMixin {
  late MapControllerCubit mapControllerCubit;

  final mapWidgetKey = GlobalKey();

  Timer? timer;

  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MapControlCubit, MapControlInitial>(
          listener: (context, state) {},
        ),
        if (widget.atherListener)
          BlocListener<AtherCubit, AtherInitial>(
            listener: (context, state) async {
              markers.removeWhere((e) => e.markerId.value.startsWith('__'));

              final list = state.result.map((e) async {
                final icon = await ImageMultiType(
                  url: Assets.iconsCarTopView,
                  height: 150.0.r,
                  width: 150.0.r,
                ).toBitmapDescriptor(
                  logicalSize: Size(150.0.r, 150.0.r),
                  imageSize: Size(150.0.r, 150.0.r),
                );
                return Marker(
                  markerId: MarkerId('__${e.ime}'),
                  position: e.getLatLng(),
                  icon: icon,
                );
              }).toList();

              for (var e in list) {
                markers.add(await e);
              }
              setState(() {});
            },
          ),
        BlocListener<MapControllerCubit, MapControllerInitial>(
          listenWhen: (p, c) => p.markerNotifier != c.markerNotifier,
          listener: (context, state) async {
            final listMarkers = await initMarker(state);

            markers.removeWhere((e) => !e.markerId.value.startsWith('__'));

            for (var e in listMarkers) {
              markers.add(await e);
            }
            if (mounted) setState(() {});
          },
        ),
        BlocListener<MapControllerCubit, MapControllerInitial>(
          listenWhen: (p, c) => p.polylineNotifier != c.polylineNotifier,
          listener: (context, state) async {
            polyLines
              ..clear()
              ..addAll(initPolyline(state));
            setState(() {});
          },
        ),
        BlocListener<MapControllerCubit, MapControllerInitial>(
          listener: (context, state) async {
            if (state.point != null) {
              mapControllerCubit.controller?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: state.point ?? initialPoint,
                    zoom: state.zoom,
                  ),
                ),
              );
            }

            if (state.centerZoomPoints.isNotEmpty) {
              mapControllerCubit.controller?.animateCamera(
                CameraUpdate.newLatLngBounds(
                  calculateLatLngBounds(state.centerZoomPoints),
                  40.0.r,
                ),
              );
            }
          },
        ),
      ],
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: widget.initialPoint ?? initialPoint,
          zoom: 13.0,
        ),
        minMaxZoomPreference: const MinMaxZoomPreference(0, 16.5),
        onMapCreated: (controller) {
          widget.onMapReady?.call(controller);
          mapControllerCubit.setGoogleMap(controller);

          mapControllerCubit.controller?.animateCamera(
            CameraUpdate.newCameraPosition(CameraPosition(
              target: widget.initialPoint ?? initialPoint,
              zoom: 13.0,
            )),
          );
        },
        onTap: (argument) => widget.onMapClick?.call(argument),
        markers: markers,
        polylines: polyLines,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    ///initial map controller
    mapControllerCubit = context.read<MapControllerCubit>();
    context.read<AtherCubit>().getDriverLocation(imeis);
    if (widget.atherListener) {
      timer = Timer.periodic(
        Duration(
          seconds: 15,
          hours: isAppleTestFromMapPackage ? 10 : 0,
        ),
        (timer) {
          if (!mounted) return;
          context.read<AtherCubit>().getDriverLocation(imeis);
        },
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    mapControllerCubit.controller?.dispose();

    super.dispose();
  }

  Future<List<Future<Marker>>> initMarker(MapControllerInitial state) async {
    loggerObject.wtf(state.markers.length);
    return state.markers.keys.mapIndexed(
      (i, key) async {
        return await state.markers[key]!.getWidgetGoogleMap(
          index: i,
          key: key,
        );
      },
    ).toList();
  }

  List<Polyline> initPolyline(MapControllerInitial state) {
    return state.polyLines.values.mapIndexed(
      (i, e) {
        return Polyline(
          points: e.first,
          color: e.second,
          width: 5.0.r.toInt(),
          polylineId: PolylineId(e.hashCode.toString()),
        );
      },
    ).toList();
  }
}

//---------------------------------------

LatLngBounds calculateLatLngBounds(List<LatLng> latLngList) {
  double minLat = 90.0;
  double maxLat = -90.0;
  double minLng = 180.0;
  double maxLng = -180.0;

  for (LatLng latLng in latLngList) {
    minLat = math.min(minLat, latLng.latitude);
    maxLat = math.max(maxLat, latLng.latitude);
    minLng = math.min(minLng, latLng.longitude);
    maxLng = math.max(maxLng, latLng.longitude);
  }

  LatLng southwest = LatLng(minLat, minLng);
  LatLng northeast = LatLng(maxLat, maxLng);

  return LatLngBounds(southwest: southwest, northeast: northeast);
}
