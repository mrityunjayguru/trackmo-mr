import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/config/app_sizer.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/track_route_screen/controller/track_route_controller.dart';
import 'package:track_route_pro/modules/track_route_screen/controller/track_route_controller.dart';
import 'package:track_route_pro/modules/track_route_screen/controller/track_route_controller.dart';
import 'package:track_route_pro/modules/vehicales/controller/vehicales_controller.dart';
import 'package:track_route_pro/service/model/presentation/track_route/DisplayParameters.dart';
import 'package:track_route_pro/utils/common_import.dart';

import '../../../../constants/project_urls.dart';
import '../../../../utils/custom_vehicle_data.dart';
import '../../../../utils/utils.dart';

class VehicalDetailBottomSheet extends StatelessWidget {
  final controller = Get.isRegistered<VehicalesController>()
      ? Get.find<VehicalesController>()
      : Get.put(VehicalesController());
  final trackController = Get.isRegistered<TrackRouteController>()
      ? Get.find<TrackRouteController>()
      : Get.put(TrackRouteController());
  VehicalDetailBottomSheet({
    required this.vehicalNo,
    required this.dateTime,
    required this.address,
    required this.totalkm,
    required this.imei,
    required this.currentSpeed,
    required this.deviceID,
    super.key,
    required this.icon,
    required this.fuel,
    this.ignition,
    this.gps,
    this.network,
    this.ac,
    required this.vehicleName,
    this.charging,
    this.immob,
    this.parking,
    this.door,
    this.geofence,
    this.engine, this.displayParameters,
  });

  final String vehicalNo, icon, fuel, vehicleName;
  final String dateTime;
  final String address;
  final String totalkm;
  final String deviceID;
  final String imei;
  final bool? ignition,
      gps,
      network,
      ac,
      charging,
      immob,
      parking,
      door,
      geofence,
      engine;

  final double currentSpeed;
  final DisplayParameters? displayParameters;

  @override
  Widget build(BuildContext context) {
    // debugPrint("HELLOOOOOOOOO");
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteOff,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 4),
            color: Color(0xff000000).withOpacity(0.2),
          )
        ],
        borderRadius: BorderRadius.only(topLeft: Radius.circular(AppSizes.radius_16), topRight: Radius.circular(AppSizes.radius_16)),
      ),
      child: Column(
        children: [
          VehicleDataWidget(
            displayParameters: displayParameters,
                  showDeviceId: false,
                  odo: totalkm,
                  fuel: fuel,
                  speed: currentSpeed.toString(),
                  deviceId: deviceID,
                  doorIsActive: door,
                  doorSubTitle: door == null ? "N/A" : (door! ? "OPEN" : "CLOSED"),
                  engineIsActive: engine,
                  engineSubTitle:
                      engine == null ? "N/A" : (engine! ? "OPEN" : "CLOSED"),
                  parkingIsActive: parking,
                  parkingSubTitle:
                      parking == null ? "N/A" : (parking! ? "ON" : "OFF"),
                  immobilizerIsActive: immob,
                  immobilizerSubTitle:
                      immob == null ? "N/A" : (immob! ? "ON" : "OFF"),
                  geofenceIsActive: geofence,
                  geofenceSubTitle:
                      geofence == null ? "N/A" : (geofence! ? "ON" : "OFF"),
                  gpsIsActive: gps,
                  gpsSubTitle: gps == null ? "N/A" : (gps! ? "ON" : "OFF"),
                  networkIsActive: network,
                  networkSubTitle:
                      network == null ? "N/A" : (network! ? "AVAILABLE" : "OFF"),
                  acIsActive: ac,
                  acSubTitle: ac == null ? "N/A" : (ac! ? "ON" : "OFF"),
                  chargingIsActive: charging,
                  chargingSubTitle:
                      charging == null ? "N/A" : (charging! ? "ON" : "OFF"),
                  address: address,
                  lastUpdate: dateTime,
                  vehicleName: vehicalNo,
                  showStats: true,
                  imei: imei)
              .paddingOnly(left: 4.w, right: 4.w, top: 5.h),
          Container(
            width: context.width,
            decoration: BoxDecoration(
              color: AppColors.color_f4f4f4,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(AppSizes.radius_16), topRight: Radius.circular(AppSizes.radius_16)),
            ),
            child: GestureDetector(
              onTap: (){
                Clipboard.setData(ClipboardData(text: deviceID));
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied to clipboard!'),  duration: Duration(seconds: 2), // Short duration
                      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      behavior: SnackBarBehavior.floating, // Makes it floating),
                    ));
              },
              child: Container(
                width: context.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Device ID',
                            style: AppTextStyles(context)
                                .display12W400
                                .copyWith(color: AppColors.grayLight),
                          ),
                          Row(
                            children: [
                              Text(
                                deviceID+"    ",
                                style: AppTextStyles(context).display12W500.copyWith(color: AppColors.grayLight),
                              ),
                              SvgPicture.asset( 'assets/images/svg/copy_icon.svg'),
                              SizedBox(width: 4,),
                            ],
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      behavior: HitTestBehavior
                          .deferToChild,
                      onTap: () {
                        trackController.showAllVehicles();
                        trackController.isShowvehicleDetail
                            .value = false;
                        trackController.isvehicleSelected
                            .value = true;
                        trackController.isedit.value =
                        false;
                        trackController.stackIndex.value =
                        1;
                        trackController.isExpanded.value =
                        false;
                        // trackController.checkRelayStatus(trackController
                        //     .vehicleList
                        //     .value
                        //     .data?[index]
                        //     .imei ??
                        //     '');
                        trackController.devicesByDetails(imei);
                      },
                      child: Text(
                        'Manage',
                        style: AppTextStyles(context)
                            .display13W500
                            .copyWith(
                            color:
                            AppColors.blue),
                      ),
                    )
                  ],
                ),
              ) .paddingSymmetric(horizontal: 4.w, vertical: 8),
            ),
          ) .paddingSymmetric(horizontal: 4.w),
        ],
      ),
    );
  }

  Widget vahicalesItem({
    required BuildContext context,
    bool? isActive,
    required String title,
    required String subTitle,
    required String image,
  }) {
    if (isActive == null) {
      return Row(
        children: [
          SizedBox(
            width: 55,
            child: Column(
              children: [
                CircleAvatar(
                    child: SvgPicture.asset(
                      image,
                      colorFilter:
                          ColorFilter.mode(AppColors.black, BlendMode.srcIn),
                    ),
                    backgroundColor: AppColors.grayLighter),
                SizedBox(
                  height: 1.h,
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles(context)
                        .display11W800
                        .copyWith(color: AppColors.grayLight),
                  ),
                ),
                SizedBox(
                  height: 0.6.h,
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    subTitle,
                    style: AppTextStyles(context)
                        .display11W800
                        .copyWith(color: AppColors.grayLight),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 4,
          )
        ],
      );
    }
    return Row(
      children: [
        SizedBox(
          width: 55,
          child: Column(
            children: [
              CircleAvatar(
                  child: SvgPicture.asset(
                    image,
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  backgroundColor:
                      isActive ? AppColors.success : AppColors.errorColor),
              SizedBox(
                height: 1.h,
              ),
              FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles(context)
                      .display11W800
                      .copyWith(color: AppColors.grayLight),
                ),
              ),
              SizedBox(
                height: 0.6.h,
              ),
              FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  subTitle,
                  style: AppTextStyles(context)
                      .display11W800
                      .copyWith(color: AppColors.grayLight),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          width: 4,
        )
      ],
    );
  }
}
