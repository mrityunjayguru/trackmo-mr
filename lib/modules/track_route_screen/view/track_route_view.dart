import 'dart:developer';

import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/config/app_sizer.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/track_route_screen/controller/track_route_controller.dart';
import 'package:track_route_pro/modules/track_route_screen/view/widgets/map_view.dart';
import 'package:track_route_pro/modules/track_route_screen/view/widgets/vehicle_selected.dart';
import 'package:track_route_pro/modules/track_route_screen/view/widgets/vehicles_detail_bottom_sheet.dart';
import 'package:track_route_pro/modules/track_route_screen/view/widgets/vehicles_filter.dart';
import 'package:track_route_pro/utils/common_import.dart';

import '../../../utils/utils.dart';
import '../../route_history/controller/history_controller.dart';
import '../../route_history/view/route_history_filter.dart';

class TrackRouteView extends StatelessWidget {
  TrackRouteView({super.key});

  final controller = Get.put(TrackRouteController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        controller.stackIndex.value = 0;
        controller.isShowvehicleDetail.value = false;
        controller.isExpanded.value = false;
        controller.removeRoute();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Obx(() {
          return Stack(
            children: [
              if (controller.stackIndex.value == 2)
                RouteHistoryPage()
              else ...[
                MapViewTrackRoute(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: controller.stackIndex.value == 0 ? Offset(-1,0) : Offset(1,0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: controller.stackIndex.value == 0
                      ? VehiclesList()
                      : VehicleSelected(),
                ),
                // controller.stackIndex.value == 0
                //     ? VehiclesList()
                //     : VehicleSelected(),
                if (controller.isShowvehicleDetail.value) ...[
                  DraggableScrollableSheet(
                    initialChildSize: 0.5, // Initial size of the sheet
                    minChildSize: 0.1, // Minimum size before closing
                    maxChildSize: 0.5, // Maximum size of the sheet
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return NotificationListener<
                          DraggableScrollableNotification>(
                        onNotification: (notification) {
                          // When dragged down enough, close the bottom sheet
                          if (notification.extent <= 0.15) {
                            controller.showAllVehicles();
                          }
                          return true;
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                            
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(AppSizes.radius_20))
                              ),
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: Obx(() {
                                  if (controller.deviceDetail.value.data
                                          ?.isNotEmpty ??
                                      false) {
                                    var trackingData = controller.deviceDetail
                                        .value.data?[0].trackingData;
                                    if (trackingData?.location?.latitude !=
                                            null &&
                                        trackingData?.location?.longitude !=
                                            null) {
                                      // Call the address fetching method if lat/long are available
                                      controller.getAddressFromLatLong(
                                        trackingData?.location?.latitude ?? 0.0,
                                        trackingData?.location?.longitude ??
                                            0.0,
                                      );
                                    }
                                    else{
                                      controller.address.value = "Address Unavailable";
                                    }


                                    String date = 'Update unavailable';
                                    String time = "";
                                    if (trackingData
                                            ?.lastUpdateTime?.isNotEmpty ??
                                        false) {
                                      date =
                                          '${DateFormat("dd MMM y").format(DateTime.parse(trackingData?.lastUpdateTime ?? "").toLocal()) ?? ''}';
                                      time =
                                          '${DateFormat("hh:mm").format(DateTime.parse(trackingData?.lastUpdateTime ?? "").toLocal()) ?? ''}';
                                    }
                                    return VehicalDetailBottomSheet(
                                      displayParameters: controller.deviceDetail.value.data?[0].displayParameters,
                                      imei: controller.deviceDetail.value
                                              .data?[0].imei ??
                                          "",
                                      vehicalNo: controller.deviceDetail.value
                                              .data?[0].vehicleNo ??
                                          '',
                                      dateTime: "$date $time",
                                      address:  '${controller.address.value}',
                                      totalkm:
                                          '${trackingData?.totalDistanceCovered ?? ''}',
                                      currentSpeed: controller
                                              .deviceDetail
                                              .value
                                              .data?[0]
                                              .trackingData
                                              ?.currentSpeed ??
                                          0,
                                      deviceID:
                                          '${controller.deviceDetail.value.data?[0].deviceId ?? ""}',
                                      icon: controller.deviceDetail.value
                                              .data?[0].vehicletype?.icons ??
                                          "",
                                      ignition: trackingData?.ignition?.status,
                                      network: trackingData?.network == null
                                          ? null
                                          : (trackingData?.network ==
                                              "Connected"),
                                      gps: trackingData?.gps,
                                      ac: trackingData?.ac,
                                      charging: null,
                                      //todo
                                      door: trackingData?.door,
                                      geofence: controller.deviceDetail.value
                                              .data?[0].area !=
                                          null,
                                      immob: controller.deviceDetail.value
                                                  .data?[0].immobiliser !=
                                              null
                                          ? (controller.deviceDetail.value
                                                  .data?[0].immobiliser ==
                                              "Stop")
                                          : null,
                                      parking: controller
                                          .deviceDetail.value.data?[0].parking,
                                      engine: null,
                                      //todo
                                      fuel:
                                          "${trackingData?.fuelGauge?.quantity ?? "N/A"}",
                                      vehicleName:
                                          "${controller.deviceDetail.value.data?[0].vehicletype?.vehicleTypeName ?? ""}",
                                    );
                                  }
                                  return SizedBox.shrink();
                                }),
                              ),
                            ),
                            // Call driver button
                            Positioned(
                              top: -25,
                              left: 2.w,
                              child: InkWell(
                                onTap: () {
                                  Utils.makePhoneCall(
                                      '${controller.deviceDetail.value.data?[0].mobileNo}');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radius_20),
                                    color: AppColors.black,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height:34,
                                        width:34,
                                        child: CircleAvatar(

                                          backgroundColor:
                                              AppColors.selextedindexcolor,
                                          child: Icon(Icons.call),
                                        ),
                                      ),
                                      Text(
                                        'Call Driver',
                                        style: AppTextStyles(context)
                                            .display14W500
                                            .copyWith(
                                                color: AppColors
                                                    .selextedindexcolor),
                                      ).paddingOnly(left: 6, right: 6),
                                    ],
                                  ).paddingSymmetric(
                                      horizontal: 2.w, vertical: 0.5.h),
                                ),
                              ),
                            ),

                            // Directions button
                            Positioned(
                              top: -25,
                              right: 3.w,
                              child: ElevatedButton(
                                onPressed: () async {
                                  Position? currentPosition =
                                      await controller.getCurrentLocation();
                                  if (currentPosition == null) {
                                    print('Current location not available');
                                    return;
                                  }

                                  LatLng userLocation = LatLng(
                                      currentPosition.latitude,
                                      currentPosition.longitude);

                                  // Fetch the selected vehicle's location
                                  LatLng vehiclePosition = LatLng(
                                    controller.deviceDetail.value.data?[0]
                                            .trackingData?.location?.latitude ??
                                        0.0,
                                    controller
                                            .deviceDetail
                                            .value
                                            .data?[0]
                                            .trackingData
                                            ?.location
                                            ?.longitude ??
                                        0.0,
                                  );

                                  await controller.updateRoute(
                                      userLocation, vehiclePosition);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue,
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(12),
                                ),
                                child: Icon(
                                  Icons.directions,
                                  size: 27,
                                  color: AppColors.whiteOff,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ]
            ],
          );
        }),
        floatingActionButton: Obx(
          () => controller.stackIndex.value == 0
              ? Padding(
                  padding: controller.isShowvehicleDetail.value
                      ? EdgeInsets.only(bottom: 47.h)
                      : EdgeInsets.zero,
                  child: FloatingActionButton(
                    child: SvgPicture.asset(Assets.images.svg.navigation1, fit: BoxFit.fill,),
                    backgroundColor: AppColors.selextedindexcolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: () async {
                      // Fetch the current location
                      Position? position =
                          await controller.getCurrentLocation();
                      if (position != null) {
                        controller.updateCameraPosition(
                            position.latitude, position.longitude);
                      }
                      if (position != null) {
                        // You can do something with the location, e.g., update the map
                        print(
                            'Current location: ${position.latitude}, ${position.longitude}');
                        // Example: center the map to the current location (if you're using Google Maps or similar)
                      } else {
                        print('Failed to fetch location.');
                      }
                    },
                  ),
                )
              : SizedBox.shrink(),
        ),
      ),
    );
  }
}

/*

import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/config/app_sizer.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/track_route_screen/controller/track_route_controller.dart';
import 'package:track_route_pro/modules/track_route_screen/view/widgets/map_view.dart';
import 'package:track_route_pro/modules/track_route_screen/view/widgets/vehicle_selected.dart';
import 'package:track_route_pro/modules/track_route_screen/view/widgets/vehicles_detail_bottom_sheet.dart';
import 'package:track_route_pro/modules/track_route_screen/view/widgets/vehicles_filter.dart';
import 'package:track_route_pro/utils/common_import.dart';

class TrackRouteView extends StatelessWidget {
  TrackRouteView({super.key});

  final controller = Get.put(TrackRouteController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        controller.stackIndex.value = 0;
      },
      child: Scaffold(
        body: Obx(() {
          return controller.stackIndex.value == 0
              ? Stack(
                  fit: StackFit.loose,
                  children: [
                    MapViewTrackRoute(),
                    VehiclesList(),
                  ],
                )
              : VehicleSelected();
        }),
        floatingActionButton: Obx(
          () => controller.stackIndex.value == 0
              ? Padding(
                  padding: controller.isShowvehicleDetail.value
                      ? EdgeInsets.only(bottom: 16.h)
                      : EdgeInsets.zero,
                  child: FloatingActionButton(
                    child: SvgPicture.asset(Assets.images.svg.navigation1),
                    backgroundColor: AppColors.selextedindexcolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: () => null,
                  ),
                )
              : SizedBox.shrink(),
        ),
        bottomSheet: BottomSheet(
          enableDrag: false, // Disables drag to close
          onClosing: () {}, // Handle closing if needed
          builder: (context) {
            return Obx(
              () => controller.isShowvehicleDetail.value
                  ? Stack(
                      clipBehavior: Clip
                          .none, // Allows overflow for the button and avatar
                      children: [
                        Container(
                          height: 42.h,
                          child: VehicalDetailBottomSheet(
                            vehicalNo: 'POI3522',
                            dateTime: '5 Min ago (08 Sep 2024 10:06 PM)',
                            adress: 'Sector 3, Rewari, Haryana, India',
                            totalkm: '120',
                            currentSpeed: 40.2,
                            deviceID: 'CAR1234567_TRP_123',
                          ),
                        ),
                        Positioned(
                          top:
                              -25, // Adjust the value to position 50% above the bottom sheet
                          left: 2.w, // Adjust horizontal position
                          child: InkWell(
                            onTap: () {
                              print('is Tapped');
                              controller.makePhoneCall(
                                  '12316545'); // Calling the function
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radius_34),
                                color: AppColors.black,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        AppColors.selextedindexcolor,
                                    child: Icon(Icons.call),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Call Driver',
                                        style: AppTextStyles(context)
                                            .display14W500
                                            .copyWith(
                                                color: AppColors
                                                    .selextedindexcolor),
                                      ),
                                      Text(
                                        'Driver Name',
                                        style: AppTextStyles(context)
                                            .display14W500
                                            .copyWith(
                                                color: AppColors
                                                    .selextedindexcolor),
                                      ),
                                    ],
                                  ).paddingOnly(left: 6),
                                ],
                              ).paddingSymmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                            ),
                          ),
                        ),
                        Positioned(
                          top:
                              -25, // Adjust the value to position 50% above the bottom sheet
                          right: 3.w, // Adjust horizontal position
                          child: ElevatedButton(
                            onPressed: () {
                              // Button action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                            child: Icon(
                              Icons.directions,
                              color: AppColors.whiteOff,
                              // size: 2,
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

 */
