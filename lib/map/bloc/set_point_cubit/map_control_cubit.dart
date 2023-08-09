import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:qareeb_models/global.dart';


part 'map_control_state.dart';

class MapControlCubit extends Cubit<MapControlInitial> {
  MapControlCubit() : super(MapControlInitial.initial());

  void moveCamera({required LatLng? point}) {
    emit(state.copyWith(point: point, moveCamera: true, state: ''));
  }

  void changeMapType(MapType type, LatLng point) {
    emit(state.copyWith(
      type: type,
      state: 'mt',
      point: point,
      moveCamera: false,
    ));
  }

}
