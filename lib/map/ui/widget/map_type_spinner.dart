import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:map_package/map/ui/widget/map_widget.dart';
import 'package:map_package/map/utile.dart';
import 'package:qareeb_models/global.dart';

import '../../bloc/set_point_cubit/map_control_cubit.dart';

final mapTypeList = [
  SpinnerItem(name: 'خريطة عادية', id: MyMapType.normal.index),
  SpinnerItem(name: 'قمر صناعي', id: MyMapType.word.index),
  SpinnerItem(name: 'مختلطة', id: MyMapType.mix.index),
];

class MapTypeSpinner extends StatelessWidget {
  const MapTypeSpinner({Key? key, required this.controller}) : super(key: key);

  final MapController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30.0.h,
      right: 10.0.w,
      child: PopupMenuButton<MyMapType>(
        initialValue: context.read<MapControlCubit>().state.type,
        onSelected: (MyMapType item) {
          context.read<MapControlCubit>().changeMapType(item, controller.center.gll);
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
          return <PopupMenuEntry<MyMapType>>[
            const PopupMenuItem<MyMapType>(
              value: MyMapType.normal,
              child: Text('خريطة عادية'),
            ),
            const PopupMenuItem<MyMapType>(
              value: MyMapType.word,
              child: Text('قمر صناعي'),
            ),
            const PopupMenuItem<MyMapType>(
              value: MyMapType.mix,
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
      //         .changeMyMapType(MyMapType.values[p0.id], controller.center);
      //   },
      // ),
    );
  }
}