import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:saed_http/api_manager/api_service.dart';

import '../../bloc/ather_cubit/ather_cubit.dart';
import '../../bloc/map_controller_cubit/map_controller_cubit.dart';
import '../../bloc/set_point_cubit/map_control_cubit.dart';
import '../../data/models/my_marker.dart';
import 'map_widget.dart';

class GMapWidget extends StatefulWidget {
  const GMapWidget({
    Key? key,
    this.onMapReady,
    this.initialPoint,
    this.search,
    this.updateMarkerWithZoom,
    this.onMapClick,
    this.onTapMarker,
    this.atherListener = true,
  }) : super(key: key);

  final Function(GoogleMapController controller)? onMapReady;
  final Function(LatLng latLng)? onMapClick;
  final Function()? search;
  final Function(MyMarker marker)? onTapMarker;
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

  final _controller = Completer<GoogleMapController>();
  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MapControlCubit, MapControlInitial>(
          listener: (context, state) {},
        ),
        BlocListener<AtherCubit, AtherInitial>(
          listener: (context, state) {},
        ),
        BlocListener<MapControllerCubit, MapControllerInitial>(
          listener: (context, state) {
            initMarker(state).then((value) {
              setState(() => markers
                ..clear()
                ..addAll(value));
            });
          },
        ),
      ],
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: widget.initialPoint ?? initialPoint,
          zoom: 13.0,
        ),
        onMapCreated: (GoogleMapController controller) {

          _controller.complete(controller);
          controller.animateCamera(
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

  var stream = Stream.periodic(const Duration(seconds: 15));

  @override
  void initState() {
    super.initState();

    ///initial map controller
    mapControllerCubit = context.read<MapControllerCubit>();
  }

  Future<List<Marker>> initMarker(MapControllerInitial state) async {
    final list = <Marker>[];
    int i = 0;
    state.markers.forEach(
      (key, value) async {
        final marker = await value.getWidgetGoogleMap(
          index: i,
          key: key,
          onTapMarker: widget.onTapMarker,
        );
        list.add(marker);
        i++;
      },
    );
    return list;
  }

  List<Polyline> initPolyline(MapControllerInitial state) {
    return state.polyLines.values.mapIndexed(
      (i, e) {
        return Polyline(
          points: e.first,
          color: e.second,
          polylineId: PolylineId(e.hashCode.toString()),
        );
      },
    ).toList();
  }
}

//---------------------------------------
