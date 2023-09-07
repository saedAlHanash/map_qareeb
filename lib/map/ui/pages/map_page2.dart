// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_animated_marker/flutter_map_animated_marker.dart';
// import 'package:flutter_qareeb_client/core/extensions/extensions.dart';
// import 'package:flutter_qareeb_client/features/booking/bloc/booking_ui_control_cubit/booking_ui_control_cubit.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// 
//
// import '../../../../core/strings/app_color_manager.dart';
// import '../../../../core/strings/enum_manager.dart';
// import '../../../../core/widgets/my_card_widget.dart';
// import '../../../../core/widgets/spinner_widget.dart';
// import '../../../../generated/assets.dart';
// import '../../../booking/bloc/trip_mediator_cubit/trip_mediator_cubit.dart';
// import '../../../osrm/bloc/get_route_point_cubit/charge_wallet_cubit.dart';
// import '../../../trip/bloc/driver_location/driver_location_cubit.dart';
// import '../../bloc/change_map_type_cubit/change_map_type_cubit.dart';
// import '../../bloc/set_point_cubit/map_control_cubit.dart';
//
// class MapWidget extends StatefulWidget {
//   const MapWidget({
//     Key? key,
//     this.isPicker,
//     this.onMapReady,
//   }) : super(key: key);
//
//   final Function? onMapReady;
//   final bool? isPicker;
//
//   GlobalKey<MapWidgetState> getKey() {
//     return GlobalKey<MapWidgetState>();
//   }
//
//   @override
//   State<MapWidget> createState() => MapWidgetState();
// }
//
// class MapWidgetState extends State<MapWidget> {
//   late MapController controller;
//
//   List<Marker> markers = [];
//   List<LatLng> polyline = [];
//   String tile = 'https://maps.almobtakiroon.com/osm/tile/{z}/{x}/{y}.png';
//   var startPoint = LatLng(0, 0);
//   var endPoint = LatLng(0, 0);
//   var driverLocation = LatLng(0, 0);
//
//   /// get center map from picker mode
//   LatLng getCenterMap() => controller.center;
//
//   void changeMapListener(BuildContext context, ChangeMapTypeInitial state) {
//     switch (state.type) {
//       case MapType.normal:
//         tile = 'https://maps.almobtakiroon.com/osm/tile/{z}/{x}/{y}.png';
//         break;
//
//       case MapType.word:
//         tile = 'https://maps.almobtakiroon.com/world2/tiles/{z}/{x}/{y}.png';
//         break;
//
//       case MapType.mix:
//         tile = 'https://maps.almobtakiroon.com/overlay/{z}/{x}/{y}.png';
//         break;
//     }
//   }
//
//   controlMarkersListener(_, ControlMarkersInitial state) async {
//     if (state.moveCamera) controller.move(state.point, controller.zoom);
//
//     if (state.state != 'dl') return;
//
//     driverLocation = state.point;
//
//     if (state.oldPoint.latitude == 0) {
//       // await controller.addMarker(
//       //   state.point,
//       //   angle: state.bearing,
//       //   markerIcon: MarkerIcon(
//       //     iconWidget: Image.asset(
//       //       Assets.iconsCarTopView,
//       //       height: 200.0.spMin,
//       //       width: 200.0.spMin,
//       //     ),
//       //   ),
//       // );
//     } else {
//       // controller.changeLocationMarker(
//       //   oldLocation: state.oldPoint,
//       //   newLocation: state.point,
//       // );
//     }
//   }
//
//   controlPageListener(_, BookingControlInitial state) {
//     switch (state.bookingPage) {
//       case BookingPages.selectLocation:
//         // controller.clearAllRoads();
//         // controller.removeMarker(startPoint);
//         // controller.removeMarker(endPoint);
//         // controller.advancedPositionPicker();
//
//         break;
//       case BookingPages.trip:
//         // controller.cancelAdvancedPositionPicker();
//         tripListener();
//         break;
//       case BookingPages.booking:
//         break;
//     }
//   }
//
//   void tripListener() async {
//     var tripMediator = context.read<BookingCubit>().state;
//     //جلب النقاط البداية والنهاية للرحلة
//     startPoint = tripMediator.startLocation;
//     endPoint = tripMediator.endLocation;
//     markers.clear();
//     //أصافة العلامة الأولى
//     markers.add(Marker(
//       point: startPoint,
//       builder: (context) {
//         return SvgPicture.asset(
//           Assets.iconsMarkerStart,
//           height: 70.0,
//           width: 70.0,
//         );
//       },
//     ));
//
//     //أصافة العلامة الثانية
//     markers.add(Marker(
//       point: endPoint,
//       builder: (context) {
//         return SvgPicture.asset(
//           Assets.iconsMarkerEnd,
//           height: 70.0,
//           width: 70.0,
//         );
//       },
//     ));
//
//     setState(() {});
//     //رسم الطريق وجلب المعلومات منه
//     context
//         .read<GetRoutePointCubit>()
//         .getRoutePoint(context, start: startPoint, end: endPoint);
//
//     // final rodeInfo = await controller.drawRoad(
//     //   startPoint,
//     //   endPoint,
//     //   roadType: RoadType.car,
//     //   roadOption: RoadOption(
//     //     roadColor: AppColorManager.mainColorDark,
//     //     roadWidth: 15.0.spMin.toInt(),
//     //   ),
//     // );
//   }
//
//   driverLocationListener(_, DriverLocationInitial state) {
//     if (state.result.lng == 0) return;
//
//     final p = LatLng(state.result.lat, state.result.lng);
//
//     context.read<ControlMarkersCubit>().setDriverLocation(
//           point: p,
//           moveCamera: false,
//         );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocListener(
//       listeners: [
//         BlocListener<ChangeMapTypeCubit, ChangeMapTypeInitial>(
//           listener: changeMapListener,
//         ),
//         BlocListener<ControlMarkersCubit, ControlMarkersInitial>(
//           listener: controlMarkersListener,
//         ),
//         BlocListener<BookingUiControlCubit, BookingControlInitial>(
//           listener: controlPageListener,
//         ),
//         BlocListener<DriverLocationCubit, DriverLocationInitial>(
//           listener: driverLocationListener,
//         ),
//         BlocListener<GetRoutePointCubit, GetRoutePointInitial>(
//           listener: (context, state) {
//             polyline = decodePolyline(state.result.routes[0].geometry)
//                 .unpackPolyline();
//
//             //إرسال المعلومات الخاصة بالطريق للرحلة
//             context.read<RoadInfoCubit>().setRoadInfo(
//                   duration: state.result.routes[0].duration,
//                   distance: state.result.routes[0].distance,
//                 );
//
//             setState(() {});
//           },
//         ),
//       ],
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           FlutterMap(
//             options: MapOptions(
//               interactiveFlags:
//                   InteractiveFlag.pinchZoom | InteractiveFlag.drag,
//               zoom: 9.2,
//             ),
//             children: [
//               TileLayer(urlTemplate: tile),
//               MarkerLayer(markers: markers),
//               PolylineLayer(
//                 polylineCulling: false,
//                 polylines: [
//                   Polyline(
//                     points: polyline,
//                     color: Colors.blue,
//                   ),
//                 ],
//               ),
//               AnimatedMarkerLayer(
//                 options: AnimatedMarkerLayerOptions(
//                   duration: const Duration(
//                     milliseconds: 3000,
//                   ),
//                   marker: Marker(
//                     width: 200.0.spMin,
//                     height: 200.0.spMin,
//                     point: driverLocation,
//                     builder: (_) {
//                       return driverLocation.latitude != 0
//                           ? Center(
//                               child: Transform.rotate(
//                                 angle: 90,
//                                 child: Image.asset(
//                                   Assets.iconsCarTopView,
//                                   height: 200.0.spMin,
//                                   width: 200.0.spMin,
//                                 ),
//                               ),
//                             )
//                           : 0.0.verticalSpace;
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const MapTypeSpinner(),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     controller = MapController();
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }
//
// //---------------------------------------
//
// final mapTypeList = [
//   SpinnerItem(name: 'خريطة عادية', id: MapType.normal.index),
//   SpinnerItem(name: 'قمر صناعي', id: MapType.word.index),
//   SpinnerItem(name: 'مختلطة', id: MapType.mix.index),
// ];
//
// class MapTypeSpinner extends StatelessWidget {
//   const MapTypeSpinner({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: 30.0.h,
//       right: 10.0.w,
//       child: SpinnerWidget(
//         items: mapTypeList,
//         width: 50.0.w,
//         dropdownWidth: 200.0.w,
//         customButton: MyCardWidget(
//           elevation: 10.0,
//           padding: const EdgeInsets.all(10.0).r,
//           cardColor: AppColorManager.lightGray,
//           child: const Icon(Icons.layers_rounded,
//               color: AppColorManager.mainColor),
//         ),
//         onChanged: (p0) {
//           context
//               .read<ChangeMapTypeCubit>()
//               .changeMapType(MapType.values[p0.id!]);
//         },
//       ),
//     );
//   }
// }
//
// /*
// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_animated_marker/flutter_map_animated_marker.dart';
// 
// import 'package:rxdart/subjects.dart';
//
// import '../../../../generated/assets.dart';
//
// void main() {
//   runApp(MyApp2());
// }
//
// class MyApp2 extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: MapScreen(),
//     );
//   }
// }
//
// class MapScreen extends StatefulWidget {
//   const MapScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   static double lat = 33.6651;
//   static double lng = 36.2154;
//   var point = LatLng(lat, lng);
//
//   final stream = Stream.periodic(Duration(seconds: 5), (count) => count ).take(10);
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     stream.listen(
//       (event) {
//         point = LatLng(lat + event, lng + event);
//         setState(() {
//         });
//       },
//     );
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FlutterMap(
//       options: MapOptions(
//         center: LatLng(51.509364, -0.128928),
//         interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
//         zoom: 9.2,
//       ),
//       children: [
//         TileLayer(
//           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//         ),
//         AnimatedMarkerLayer(
//           options: AnimatedMarkerLayerOptions(
//             duration: const Duration(
//               milliseconds: 3000,
//             ),
//             marker: Marker(
//               width: 30,
//               height: 30,
//               point: point,
//               builder: (context) => Center(
//                 child: Transform.rotate(
//                   angle: 90,
//                   child: Image.asset(
//                     Assets.iconsCarTopView,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
// */
