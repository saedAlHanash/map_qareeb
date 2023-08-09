import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:qareeb_models/global.dart';

part 'my_location_state.dart';

void showErrorSnackBar({required String message, required BuildContext context}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.redAccent,
    ),
  );
}

class MyLocationCubit extends Cubit<MyLocationInitial> {
  MyLocationCubit() : super(MyLocationInitial.initial());

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  ///
  ///
  Future<void> getMyLocation(
    BuildContext context, {
    bool? latestLocation,
    bool? moveMap,
  }) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      if (context.mounted) {
        showErrorSnackBar(
            message: 'Location services are disabled.', context: context);
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        if (context.mounted) {
          showErrorSnackBar(
              message: 'Location permissions are denied', context: context);
        }
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      if (context.mounted) {
        showErrorSnackBar(
            message: 'Location permissions are permanently denied, '
                'we cannot request permissions.',
            context: context);
      }
    }

    emit(state.copyWith(state: CubitStatuses.loading, moveMap: moveMap));

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final pos = (latestLocation ?? false)
        ? await Geolocator.getLastKnownPosition()
        : await Geolocator.getCurrentPosition();

    if (pos != null) {
      final latLng = LatLng(pos.latitude, pos.longitude);

      emit(state.copyWith(result: latLng, state: CubitStatuses.done));
    }
  }
}
