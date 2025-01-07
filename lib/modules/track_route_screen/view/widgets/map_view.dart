import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:track_route_pro/modules/track_route_screen/controller/track_route_controller.dart';
import 'package:track_route_pro/utils/common_import.dart';

import '../../../../constants/project_urls.dart';

class MapViewTrackRoute extends StatelessWidget {
  MapViewTrackRoute({super.key});
  final controller = Get.put(TrackRouteController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GoogleMap(
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        onMapCreated: controller.onMapCreated,
        initialCameraPosition: CameraPosition(
          target: controller.currentLocation.value,
          zoom: 5,
        ),
        markers:Set<Marker>.of(controller.markers),
        polylines: Set<Polyline>.of(controller.polylines),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        minMaxZoomPreference: MinMaxZoomPreference(0, 16),
      ),
    );
  }
}
