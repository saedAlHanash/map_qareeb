import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qareeb_models/global.dart';

part 'map_control_state.dart';

class MapControlCubit extends Cubit<MapControlInitial> {
  MapControlCubit() : super(MapControlInitial.initial());

  void moveCamera({required LatLng? point}) {
    emit(state.copyWith(point: point, moveCamera: true, state: ''));
  }

  void changeMapType(MyMapType type, LatLng point) {
    emit(state.copyWith(
      type: type,
      state: 'mt',
      point: point,
      moveCamera: false,
    ));
  }

}
