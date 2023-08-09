import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';


class MyAnimatedMarkerLayer<T> extends ImplicitlyAnimatedWidget {
  final AnimatedMarkerLayerOptions<T> options;

  MyAnimatedMarkerLayer({
    Key? key,
    required this.options,
  }) : super(
          key: key,
          duration: options.duration,
          curve: options.curve,
        );

  @override
  AnimatedWidgetBaseState createState() => _MyAnimatedMarkerLayerState();
}

class _MyAnimatedMarkerLayerState extends AnimatedWidgetBaseState<MyAnimatedMarkerLayer>
    with AutomaticKeepAliveClientMixin {
  Tween<double>? _latitude;
  Tween<double>? _longitude;

  Marker get marker => widget.options.marker;

  double get latitude => _latitude?.evaluate(animation) ?? marker.point.latitude;

  double get longitude => _longitude?.evaluate(animation) ?? marker.point.longitude;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _latitude = visitor(_latitude, widget.options.marker.point.latitude,
        (dynamic value) => Tween<double>(begin: value as double)) as Tween<double>?;
    _longitude = visitor(_longitude, widget.options.marker.point.longitude,
        (dynamic value) => Tween<double>(begin: value as double)) as Tween<double>?;
  }

  @override
  void didUpdateWidget(covariant MyAnimatedMarkerLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final map = FlutterMapState.maybeOf(context)!;
    final pxPoint = map.project(LatLng(latitude, longitude));
    final width = marker.width - marker.anchor.left;
    final height = marker.height - marker.anchor.top;
    var sw = CustomPoint(pxPoint.x + width, pxPoint.y - height);
    var ne = CustomPoint(pxPoint.x - width, pxPoint.y + height);
    if (!map.pixelBounds.containsPartialBounds(Bounds(sw, ne))) {
      return const SizedBox();
    }
    final pos = pxPoint - map.pixelOrigin;
    final markerWidget = (marker.rotate ?? widget.options.rotate ?? false)
        // Counter rotated marker to the map rotation
        ? Transform.rotate(
            angle: -map.rotationRad,
            origin: marker.rotateOrigin ?? widget.options.rotateOrigin,
            alignment: marker.rotateAlignment ?? widget.options.rotateAlignment,
            child: marker.builder(context),
          )
        : marker.builder(context);
    return Positioned(
      key: marker.key,
      width: marker.width,
      height: marker.height,
      left: pos.x - width,
      top: pos.y - height,
      child: markerWidget,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class AnimatedMarkerLayerOptions<T> {
  final Duration duration;
  final Curve curve;
  final Marker marker;
  final bool? rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;
  final Stream<T>? stream;

  AnimatedMarkerLayerOptions({
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
    required this.marker,
    this.rotate,
    this.rotateOrigin,
    this.rotateAlignment,
    this.stream,
  });
}
