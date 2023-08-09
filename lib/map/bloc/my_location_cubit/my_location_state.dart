part of 'my_location_cubit.dart';

class MyLocationInitial {
  final LatLng result;
  final CubitStatuses state;
  final String error;
  final bool moveMap;

  const MyLocationInitial({
    required this.result,
    required this.error,
    required this.moveMap,
    required this.state,
  });

  factory MyLocationInitial.initial() {
    return MyLocationInitial(
      result: LatLng(0, 0),
      error: '',
      moveMap: false,
      state: CubitStatuses.init,
    );
  }

  MyLocationInitial copyWith({
    LatLng? result,
    CubitStatuses? state,
    String? error,
    bool? moveMap,
  }) {
    return MyLocationInitial(
      result: result ?? this.result,
      state: state ?? this.state,
      error: error ?? this.error,
      moveMap: moveMap ?? this.moveMap,
    );
  }
}
