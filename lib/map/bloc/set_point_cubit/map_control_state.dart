part of 'map_control_cubit.dart';

class MapControlInitial {
  final LatLng point;
  final LatLng oldPoint;
  final String state;
  final bool moveCamera;
  final double bearing;

  final MyMapType type;

  const MapControlInitial({
    required this.oldPoint,
    required this.point,
    required this.state,
    required this.bearing,
    required this.moveCamera,
    required this.type,
  });

  factory MapControlInitial.initial() {
    return const MapControlInitial(
      point: LatLng(0, 0),
      oldPoint: LatLng(0, 0),
      bearing: 0.0,
      type: MyMapType.normal,
      state: '',
      moveCamera: true,
    );
  }

  // @override
  // List<Object> get props => [point];

  MapControlInitial copyWith({
    LatLng? point,
    String? state,
    bool? moveCamera,
    double? bearing,
    MyMapType? type,
  }) =>
      MapControlInitial(
        point: point ?? this.point,
        type: type ?? this.type,
        state: state ?? this.state,
        bearing: bearing ?? this.bearing,
        moveCamera: moveCamera ?? this.moveCamera,
        oldPoint: point == null ? oldPoint : this.point,
      );
}
