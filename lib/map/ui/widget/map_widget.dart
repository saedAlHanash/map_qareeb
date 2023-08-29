import 'dart:async';

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
import '../../bloc/set_point_cubit/map_control_cubit.dart';
import '../../data/models/my_marker.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    Key? key,
    this.onMapReady,
    this.initialPoint,
    this.search,
    this.updateMarkerWithZoom,
    this.onMapClick,
    this.onTapMarker,
    this.atherListener= true,
  }) : super(key: key);

  final Function(MapController controller)? onMapReady;
  final Function(LatLng latLng)? onMapClick;
  final Function()? search;
  final Function(MyMarker marker)? onTapMarker;
  final LatLng? initialPoint;
  final bool? updateMarkerWithZoom;
  final bool atherListener;

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
            // controller.move(state.result.getLatLng(), controller.zoom);
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
          center: widget.initialPoint ?? initialPoint,
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
                    marker: MyMarker(point: point),
                  );
                  widget.onMapClick!.call(point);
                },
          zoom: 12.0,
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
          if(widget.atherListener)
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

  var stream = Stream.periodic(const Duration(seconds: 15));

  @override
  void initState() {
    super.initState();

    mapControllerCubit = context.read<MapControllerCubit>();

    // Add your listener
    onZoomChanged.listen((event) {
      if (widget.updateMarkerWithZoom ?? false) {
        mapControllerCubit.updateMarkersWithZoom(event);
      }
    });
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
    _streamController.close();
    super.dispose();
  }

  List<Marker> initMarker(MapControllerInitial state) {
    return state.markers.values
        .mapIndexed(
          (i, e) {
            return e.getWidget(i, onTapMarker: widget.onTapMarker);
          },
        )
        .take(state.mapZoom.getZoomMarkerCount)
        .toList();
  }

  List<Polyline> initPolyline(MapControllerInitial state) {
    return state.polyLines.values.mapIndexed(
      (i, e) {
        return Polyline(
          points: e.first,
          color: e.second,
          strokeCap: StrokeCap.round,
          strokeWidth: 5.0.spMin,
        );
      },
    ).toList();
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
      child: PopupMenuButton<MapType>(
        initialValue: context.read<MapControlCubit>().state.type,
        onSelected: (MapType item) {
          context.read<MapControlCubit>().changeMapType(item, controller.center);
        },
        child: const Card(
          elevation: 3.0,
          color: Color(0xFFF5F5F5),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(Icons.layers_rounded, color: Colors.green),
          ),
        ),
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<MapType>>[
            const PopupMenuItem<MapType>(
              value: MapType.normal,
              child: Text('خريطة عادية'),
            ),
            const PopupMenuItem<MapType>(
              value: MapType.word,
              child: Text('قمر صناعي'),
            ),
            const PopupMenuItem<MapType>(
              value: MapType.mix,
              child: Text('مختلطة'),
            ),
          ];
        },
      ),
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

extension DoubleHealper on double {
  int get getZoomMarkerCount {
    if (this >= 10 && this < 13 || this < 10) return 10;
    if (this >= 13 && this < 14) return 15;
    if (this >= 14 && this < 15) return 30;
    if (this >= 15 && this < 16) return 40;
    if (this > 16) return 100000;

    return 100000;
  }
}

final List<String> imeis = [];

final initialPoint = LatLng(33.514631885313264, 36.27654397981723);

class CachedTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(
      getTileUrl(coordinates, options),
      //Now you can set options that determine how the image gets cached via whichever plugin you use.
    );
  }
}
