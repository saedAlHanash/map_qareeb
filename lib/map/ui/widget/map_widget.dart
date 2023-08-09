import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_multi_type/image_multi_type.dart';
import 'package:latlong2/latlong.dart';
import 'package:qareeb_models/global.dart';
import 'package:saed_http/api_manager/api_service.dart';

import '../../../generated/assets.dart';
import '../../animate_marker/animated_marker_layer.dart';
import '../../bloc/ather_cubit/ather_cubit.dart';
import '../../bloc/map_controller_cubit/map_controller_cubit.dart';
import '../../bloc/my_location_cubit/my_location_cubit.dart';
import '../../bloc/set_point_cubit/map_control_cubit.dart';
import '../../data/models/my_marker.dart';

class CachedTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(
      getTileUrl(coordinates, options),
      //Now you can set options that determine how the image gets cached via whichever plugin you use.
    );
  }
}

final List<String> imeis = [];

class MapWidget extends StatefulWidget {
  const MapWidget({
    Key? key,
    this.onMapReady,
    this.initialPoint,
    this.search,
    this.onMapClick,
  }) : super(key: key);

  final Function(MapController controller)? onMapReady;
  final Function(LatLng latLng)? onMapClick;
  final Function()? search;
  final LatLng? initialPoint;

  static initImeis(List<String> imei) => imeis
    ..clear()
    ..addAll(imei);

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

  String tile = 'https://maps.almobtakiroon.com/osm/tile/{z}/{x}/{y}.png';

  var bearing = 0.0;
  var maxZoom = 18.0;

  controlMarkersListener(_, MapControlInitial state) async {
    if (state.moveCamera) {
      controller.animateTo(dest: state.point, zoom: controller.zoom);
    }

    if (state.state == 'mt') {
      switch (state.type) {
        case MapType.normal:
          tile = 'https://maps.almobtakiroon.com/osm/tile/{z}/{x}/{y}.png';
          maxZoom = 18.0;
          break;

        case MapType.word:
          tile = 'https://maps.almobtakiroon.com/world2/tiles/{z}/{x}/{y}.png';
          maxZoom = 16.4;
          break;

        case MapType.mix:
          tile = 'https://maps.almobtakiroon.com/overlay/{z}/{x}/{y}.png';
          maxZoom = 16.4;
          break;
      }
      setState(() {});
    }

    setState(() {});
  }

  late MyLocationCubit myLocationCubit;
  late MapControllerCubit mapControllerCubit;

  final mapWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MapControlCubit, MapControlInitial>(
          listener: controlMarkersListener,
        ),
        BlocListener<AtherCubit, AtherInitial>(
          listener: (context, state) {
            // controller.move(state.result.getLatLng(), controller.zoom);
          },
        ),
        BlocListener<MyLocationCubit, MyLocationInitial>(
          listenWhen: (p, c) => c.state == CubitStatuses.done,
          listener: (context, state) async {
            if (mapControllerCubit.state.centerZoomPoints.isNotEmpty) return;
            if (mapControllerCubit.state.point == null) return;
            if (mapControllerCubit.state.markers.isNotEmpty) return;

            await controller.animateTo(dest: state.result, zoom: 15);
          },
        ),
        BlocListener<MapControllerCubit, MapControllerInitial>(
          listener: (context, state) async {
            loggerObject.wtf(state.centerZoomPoints);
            if (state.point != null) {
              controller.animateTo(dest: state.point!, zoom: state.zoom);
            }

            if (state.centerZoomPoints.isNotEmpty) {
              await controller.centerOnPoints(state.centerZoomPoints,
                  options: const FitBoundsOptions(
                    forceIntegerZoomLevel: true,
                  ));
            }
          },
        ),
      ],
      child: FlutterMap(
        key: mapWidgetKey,
        mapController: controller,
        options: MapOptions(
          maxZoom: maxZoom,
          interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          onMapReady: () {
            if (widget.initialPoint != null && widget.initialPoint!.latitude != 0) {
              controller.animateTo(dest: widget.initialPoint!, zoom: 15);
              mapControllerCubit.addSingleMarker(
                  marker: MyMarker(point: widget.initialPoint!));
            } else {
              myLocationCubit.getMyLocation(context, moveMap: true);
            }

            // controller.centerOnPoints(points);
            if (widget.onMapReady != null) {
              widget.onMapReady!(controller);
            }
          },
          onTap: widget.onMapClick == null
              ? null
              : (tapPosition, point) {
                  mapControllerCubit.addSingleMarker(
                    marker: MyMarker(point: point),
                  );
                  widget.onMapClick!.call(point);
                },
          zoom: 16.0,
        ),
        nonRotatedChildren: [
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
                polylines: MapHelper.initPolyline(state),
              );
            },
          ),
          BlocBuilder<MapControllerCubit, MapControllerInitial>(
            buildWhen: (p, c) => p.markerNotifier != c.markerNotifier,
            builder: (context, state) {
              return MarkerLayer(
                markers: MapHelper.initMarker(state),
              );
            },
          ),
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
                            point: e.getLatLng(),
                            builder: (_) {
                              return Center(
                                child: Transform.rotate(
                                  angle: -e.angle,
                                  child: ImageMultiType(
                                    url: Assets.iconsCarTopView,
                                    height: 200.0.spMin,
                                    width: 200.0.spMin,
                                  ),
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

  var stream = Stream.periodic(const Duration(seconds: 15));

  @override
  void initState() {
    super.initState();

    myLocationCubit = context.read<MyLocationCubit>();
    mapControllerCubit = context.read<MapControllerCubit>();

    context.read<AtherCubit>().getDriverLocation(imeis);
    stream.takeWhile((element) {
      return mounted;
    }).listen((event) {
      if (!mounted) return;
      context.read<AtherCubit>().getDriverLocation(imeis);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapControllerCubit.mapHeight = mapWidgetKey.currentContext?.size?.height ?? 640.0;
      mapControllerCubit.mapWidth = mapWidgetKey.currentContext?.size?.width ?? 360.0;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

//---------------------------------------

final mapTypeList = [
  SpinnerItem(name: 'خريطة عادية', id: MapType.normal.index),
  SpinnerItem(name: 'قمر صناعي', id: MapType.word.index),
  SpinnerItem(name: 'مختلطة', id: MapType.mix.index),
];

class MapTypeSpinner extends StatelessWidget {
  const MapTypeSpinner({Key? key, required this.controller}) : super(key: key);

  final MapController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30.0.h,
      right: 10.0.w,
      child: const SizedBox.shrink(),
      // child: SpinnerWidget(
      //   items: mapTypeList,
      //   width: 50.0.w,
      //   dropdownWidth: 200.0.w,
      //   customButton: MyCardWidget(
      //     elevation: 10.0,
      //     padding: const EdgeInsets.all(10.0).r,
      //     cardColor: AppColorManager.lightGray,
      //     child: const Icon(Icons.layers_rounded, color: AppColorManager.mainColor),
      //   ),
      //   onChanged: (p0) {
      //     context
      //         .read<MapControlCubit>()
      //         .changeMapType(MapType.values[p0.id], controller.center);
      //   },
      // ),
    );
  }
}

class MapHelper {
  static List<Marker> initMarker(MapControllerInitial state) {
    return state.markers.values.mapIndexed((i, e) => e.getWidget(i)).toList();
  }

  static List<Polyline> initPolyline(MapControllerInitial state) {
    return state.polyLines.values.mapIndexed(
      (i, e) {
        var color = Colors.black;
        return Polyline(
          points: e,
          color: color,
          strokeCap: StrokeCap.round,
          strokeWidth: 5.0.spMin,
        );
      },
    ).toList();
  }
}
