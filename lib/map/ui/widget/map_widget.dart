import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;

import 'package:latlong2/latlong.dart' as ll;
import 'package:image_multi_type/image_multi_type.dart';
import 'package:map_package/map/utile.dart';

import 'package:qareeb_models/global.dart';

import '../../../generated/assets.dart';
import '../../animate_marker/animated_marker_layer.dart';
import '../../bloc/ather_cubit/ather_cubit.dart';
import '../../bloc/map_controller_cubit/map_controller_cubit.dart';
import '../../bloc/set_point_cubit/map_control_cubit.dart';
import '../../data/models/my_marker.dart';
import 'map_type_spinner.dart';

bool isAppleTestFromMapPackage = false;

final List<String> imeis = [];

class MapWidget extends StatefulWidget {
  const MapWidget({
    Key? key,
    this.onMapReady,
    this.initialPoint,
    this.search,
    this.updateMarkerWithZoom,
    this.onMapClick,
    this.atherListener = true,
  }) : super(key: key);

  final Function(MapController controller)? onMapReady;
  final Function(google.LatLng latLng)? onMapClick;
  final Function()? search;
  final google.LatLng? initialPoint;
  final bool? updateMarkerWithZoom;
  final bool atherListener;

  static initImeis(List<String> imei) => imeis
    ..clear()
    ..addAll(imei)
    ..removeWhere((element) => element.isEmpty);

  GlobalKey<MapWidgetState> getKey() {
    return GlobalKey<MapWidgetState>();
  }

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  late final controller = AnimatedMapController(
    vsync: this,
  );

  var tile = 'https://maps.almobtakiroon.com/osm/tile/{z}/{x}/{y}.png';

  var bearing = 0.0;
  var maxZoom = 18.0;

  controlMarkersListener(_, MapControlInitial state) async {
    if (state.moveCamera) {
      controller.animateTo(dest: state.point.ll2, zoom: controller.zoom);
    }

    if (state.state == 'mt') {
      switch (state.type) {
        case MyMapType.normal:
          tile = 'https://maps.almobtakiroon.com/osm/tile/{z}/{x}/{y}.png';
          maxZoom = 18.0;
          break;

        case MyMapType.word:
          tile = 'https://maps.almobtakiroon.com/world2/tiles/{z}/{x}/{y}.png';
          maxZoom = 16.4;
          break;

        case MyMapType.mix:
          tile = 'https://maps.almobtakiroon.com/overlay/{z}/{x}/{y}.png';
          maxZoom = 16.4;
          break;
      }
      setState(() {});
    }

    setState(() {});
  }

  late MapControllerCubit mapControllerCubit;

  final mapWidgetKey = GlobalKey();

  // Create your stream
  final _streamController = StreamController<double>();

  Stream<double> get onZoomChanged => _streamController.stream;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MapControlCubit, MapControlInitial>(
          listener: controlMarkersListener,
        ),
        BlocListener<AtherCubit, AtherInitial>(
          listener: (context, state) {
            // controller.move(state.result.getgoogle.LatLng(), controller.zoom);
          },
        ),
        BlocListener<MapControllerCubit, MapControllerInitial>(
          listener: (context, state) async {
            if (state.point != null) {
              controller.animateTo(dest: state.point!.ll2, zoom: state.zoom);
            }

            if (state.centerZoomPoints.isNotEmpty) {
              await controller.centerOnPoints(
                state.centerZoomPoints.map((e) => e.ll2).toList(),
                options: const FitBoundsOptions(
                    forceIntegerZoomLevel: true, padding: EdgeInsets.all(30.0)),
              );
            }
          },
        ),
      ],
      child: FlutterMap(
        key: mapWidgetKey,
        mapController: controller,
        options: MapOptions(
          maxZoom: maxZoom,
          center: widget.initialPoint?.ll2 ??
              (isAppleTestFromMapPackage ? initialPointBaghdad.ll2 : initialPoint.ll2),
          onPositionChanged: (position, hasGesture) {
            // Fill your stream when your position changes
            final zoom = position.zoom;
            if (zoom != null) {
              _streamController.sink.add(zoom);
            }
          },
          interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          onMapReady: () => widget.onMapReady?.call(controller),
          onTap: widget.onMapClick == null
              ? null
              : (tapPosition, point) {
                  mapControllerCubit.addSingleMarker(
                    marker: MyMarker(point: point.gll),
                  );
                  widget.onMapClick!.call(point.gll);
                },
          zoom: 12.0,
        ),
        nonRotatedChildren: [
          if (!isAppleTestFromMapPackage)
            MapTypeSpinner(
              controller: controller,
            ),
          if (widget.search != null)
            Positioned(
              top: 100.0.h,
              right: 10.0.w,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.all(10.0).r,
                child: InkWell(
                  onTap: widget.search,
                  child: const Icon(
                    Icons.search,
                    color: Color(0xFF4CA243),
                  ),
                ),
              ),
            ),
        ],
        children: [
          TileLayer(
            urlTemplate: tile,
            tileProvider: CachedTileProvider(),
          ),
          BlocBuilder<MapControllerCubit, MapControllerInitial>(
            buildWhen: (p, c) {
              return p.polylineNotifier != c.polylineNotifier;
            },
            builder: (context, state) {
              return PolylineLayer(
                polylines: initPolyline(state),
              );
            },
          ),
          BlocBuilder<MapControllerCubit, MapControllerInitial>(
            buildWhen: (p, c) => p.markerNotifier != c.markerNotifier,
            builder: (context, state) {
              return MarkerLayer(
                markers: initMarker(state),
              );
            },
          ),
          if (widget.atherListener)
            BlocBuilder<AtherCubit, AtherInitial>(
              builder: (context, state) {
                return SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      for (var e in state.result)
                        MyAnimatedMarkerLayer(
                          options: AnimatedMarkerLayerOptions(
                            duration: const Duration(seconds: 15),
                            marker: Marker(
                              width: 75.0.spMin,
                              height: 75.0.spMin,
                              point: e.getLatLng().ll2,
                              builder: (_) {
                                return Center(
                                  child: ImageMultiType(
                                    url: Assets.iconsCarTopView,
                                    height: 200.0.spMin,
                                    width: 200.0.spMin,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Timer? timer;

  @override
  void initState() {
    super.initState();

    if (isAppleTestFromMapPackage) {
      tile = 'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png';
    }

    mapControllerCubit = context.read<MapControllerCubit>();

    // Add your listener
    onZoomChanged.listen((event) {
      if (widget.updateMarkerWithZoom ?? false) {
        mapControllerCubit.updateMarkersWithZoom(event);
      }
    });
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapControllerCubit.mapHeight = mapWidgetKey.currentContext?.size?.height ?? 640.0;
      mapControllerCubit.mapWidth = mapWidgetKey.currentContext?.size?.width ?? 360.0;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    timer?.cancel();
    _streamController.close();
    super.dispose();
  }

  List<Marker> initMarker(MapControllerInitial state) {
    List<Marker> markers = [];
    final m = state.markers.values.mapIndexed(
      (i, e) {
        return e.getWidget(i);
      },
    );

    if (widget.updateMarkerWithZoom ?? false) {
      markers.addAll(m
          .take(state.mapZoom.getZoomMarkerCount)
          .where((marker) => controller.bounds?.contains(marker.point) ?? true)
          .toList());
    } else {
      markers.addAll(m.toList());
    }

    return markers;
  }

  List<Polyline> initPolyline(MapControllerInitial state) {
    return state.polyLines.values.mapIndexed(
      (i, e) {
        return Polyline(
          points: e.first.map((e) => e.ll2).toList(),
          color: e.second,
          strokeCap: StrokeCap.round,
          strokeWidth: 5.0.spMin,
        );
      },
    ).toList();
  }
}

//---------------------------------------




