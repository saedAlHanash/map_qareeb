// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'package:flutter_qareeb_client/core/strings/app_color_manager.dart';
// import 'package:flutter_qareeb_client/core/strings/app_string_manager.dart';
// import 'package:flutter_qareeb_client/core/widgets/my_button.dart';
// import 'package:flutter_qareeb_client/core/widgets/my_text_widget.dart';
// import 'package:flutter_qareeb_client/features/map/bloc/change_map_type_cubit/change_map_type_cubit.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:latlong2/latlong.dart';
//
// import 'dart:async';
//
// import 'package:logger/logger.dart';
//
// import '../../../../core/widgets/my_card_widget.dart';
// import '../../../../core/widgets/my_text_form_widget.dart';
// import '../../../../core/widgets/spinner_widget.dart';
// import '../../../../generated/assets.dart';
// import '../widget/map_widget.dart';
//
// class MapPage extends StatefulWidget {
//   const MapPage({Key? key, this.onChange, this.isPicker}) : super(key: key);
//
//   final Function(GeoPoint)? onChange;
//   final bool? isPicker;
//
//   @override
//   State<MapPage> createState() => MapPageState();
// }
//
// class MapPageState extends State<MapPage> with OSMMixinObserver {
//   late MapController controller;
//
//   final mapTypeList = [
//     SpinnerItem(name: 'خريطة عادية', id: MapType.normal.index),
//     SpinnerItem(name: 'قمر صناعي', id: MapType.word.index),
//     SpinnerItem(name: 'مختلطة', id: MapType.mix.index),
//   ];
//
//   Future<GeoPoint> getCenterMap() async {
//     return controller.centerMap;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     controller = MapController.customLayer(
//       initMapWithUserPosition: true,
//       customTile: CustomTile(
//         sourceName: "USGS Topo",
//         tileExtension: ".png",
//         maxZoomLevel: 19,
//         urlsServers: [
//           TileURLs(
//             url: "https://maps.almobtakiroon.com/osm/tile/",
//             subdomains: [],
//           ),
//         ],
//         tileSize: 256,
//       ),
//     );
//
//     controller.setZoom(zoomLevel: 11.0);
//     controller.addObserver(this);
// //33.520344, 36.295686
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   void onSelectLocation() async {
//     final f = await controller.centerMap;
//     Logger().wtf(f.toString());
//   }
//
//   void onChangeMapType(int index) {
//     context.read<ChangeMapTypeCubit>().changeMapType(MapType.values[index]);
//   }
//
//   void initListener(BuildContext context, ChangeMapTypeInitial state) {
//     late String tileSource;
//     switch (state.type) {
//       case MapType.normal:
//         tileSource = 'https://maps.almobtakiroon.com/osm/tile/';
//         break;
//
//       case MapType.word:
//         tileSource = 'https://maps.almobtakiroon.com/world/tiles/';
//         break;
//
//       case MapType.mix:
//         tileSource = 'https://maps.almobtakiroon.com/overlay/';
//         break;
//     }
//
//     controller.changeTileLayer(
//       tileLayer: CustomTile(
//         sourceName: state.type.name,
//         tileExtension: ".png",
//         maxZoomLevel: 19,
//         urlsServers: [
//           TileURLs(url: tileSource),
//         ],
//         tileSize: 256,
//       ),
//     );
//   }
//
//   final textController = TextEditingController();
//
//   @override
//   Future<void> mapIsReady(bool isReady) async {
//     var oldPoint = GeoPoint(latitude: 0, longitude: 0);
//     var point = GeoPoint(latitude: 33.520344, longitude: 36.295686);
//     Timer(const Duration(seconds: 10), () async {
//       if (oldPoint.latitude == 0) {
//         await controller.addMarker(
//           point,
//           markerIcon: MarkerIcon(
//             iconWidget: Image.asset(
//               Assets.iconsCarTopView,
//               height: 200.0.spMin,
//               width: 200.0.spMin,
//             ),
//           ),
//         );
//         oldPoint = point;
//       } else {
//         var list = getPointsBetween(oldPoint, point, 5);
//         var old = oldPoint;
//         for (var e in list) {
//           controller.changeLocationMarker(
//             oldLocation: old,
//             newLocation: e,
//             markerIcon: MarkerIcon(
//               iconWidget: Image.asset(
//                 Assets.iconsCarTopView,
//                 height: 200.0.spMin,
//                 width: 200.0.spMin,
//               ),
//             ),
//           );
//           old = e;
//           await Future.delayed(const Duration(milliseconds: 10));
//           controller.goToLocation(point);
//         }
//       }
//     });
//
//     Timer(const Duration(seconds: 20), () async {
//       point = GeoPoint(latitude: 33.540344, longitude: 36.255686);
//       if (oldPoint.latitude == 0) {
//         await controller.addMarker(
//           point,
//           markerIcon: MarkerIcon(
//             iconWidget: Image.asset(
//               Assets.iconsCarTopView,
//               height: 200.0.spMin,
//               width: 200.0.spMin,
//             ),
//           ),
//         );
//         oldPoint = point;
//       } else {
//         var list = getPointsBetween(oldPoint, point, 5);
//         var old = oldPoint;
//         for (var e in list) {
//           controller.changeLocationMarker(
//             oldLocation: old,
//             newLocation: e,
//             markerIcon: MarkerIcon(
//               iconWidget: Image.asset(
//                 Assets.iconsCarTopView,
//                 height: 200.0.spMin,
//                 width: 200.0.spMin,
//               ),
//             ),
//           );
//           old = e;
//           await Future.delayed(const Duration(milliseconds: 10));
//           controller.goToLocation(point);
//         }
//       }
//
//     });
//
//     Timer(const Duration(seconds: 30), () async {
//       point = GeoPoint(latitude: 33.540344, longitude: 36.255686);
//       if (oldPoint.latitude == 0) {
//         await controller.addMarker(
//           point,
//           markerIcon: MarkerIcon(
//             iconWidget: Image.asset(
//               Assets.iconsCarTopView,
//               height: 200.0.spMin,
//               width: 200.0.spMin,
//             ),
//           ),
//         );
//         oldPoint = point;
//       } else {
//         var list = getPointsBetween(oldPoint, point, 5);
//         var old = oldPoint;
//         for (var e in list) {
//           controller.changeLocationMarker(
//             oldLocation: old,
//             newLocation: e,
//             markerIcon: MarkerIcon(
//               iconWidget: Image.asset(
//                 Assets.iconsCarTopView,
//                 height: 200.0.spMin,
//                 width: 200.0.spMin,
//               ),
//             ),
//           );
//           old = e;
//           await Future.delayed(const Duration(milliseconds: 10));
//       controller.goToLocation(point);
//         }
//       }
//
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           OSMFlutter(
//             controller: controller,
//             mapIsLoading: loadingMap(),
//             initZoom: 14,
//             maxZoomLevel: 18,
//             stepZoom: 1.0,
//             androidHotReloadSupport: true,
//             onLocationChanged: (myLocation) {
//               Logger().wtf(myLocation.toString());
//             },
//           ),
//           mapTypeSpinner(),
//           Positioned(
//             bottom: 0.0,
//             width: 0.8.sw,
//             child: MyCardWidget(
//               margin: EdgeInsets.symmetric(vertical: 20.0.h),
//               child: Column(
//                 children: [
//                   MyTextWidget.title(text: AppStringManager.enterNamePoint),
//                   10.0.verticalSpace,
//                   MyEditTextWidget(
//                     hint: AppStringManager.pointName,
//                     controller: textController,
//                     maxLength: 40,
//                     maxLines: 1,
//                   ),
//                   10.0.verticalSpace,
//                   MyButton(
//                     text: AppStringManager.select,
//                     onTap: onSelectLocation,
//                   ),
//                   10.0.verticalSpace,
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget mapTypeSpinner() {
//     return Positioned(
//       top: 30.0.h,
//       right: 10.0.w,
//       child: SpinnerWidget(
//         items: mapTypeList,
//         customButton: MyCardWidget(
//           elevation: 10.0,
//           cardColor: AppColorManager.lightGray,
//           child: SvgPicture.asset(
//             Assets.iconsMapManae,
//             height: 30.spMin,
//           ),
//         ),
//         onChanged: (p0) => onChangeMapType(p0.id!),
//       ),
//     );
//   }
//
//   Widget loadingMap() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: const [
//           CircularProgressIndicator(),
//           Text("Map is Loading.."),
//         ],
//       ),
//     );
//   }
// }
