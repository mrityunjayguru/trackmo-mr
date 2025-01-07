import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/config/app_sizer.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/vehicales/controller/vehicales_controller.dart';
import 'package:track_route_pro/service/model/presentation/track_route/track_route_vehicle_list.dart';
import 'package:track_route_pro/utils/common_import.dart';

import '../../../../constants/project_urls.dart';
import '../../../../utils/custom_vehicle_data.dart';
import '../../../../utils/utils.dart';



class VehicalDetailCard extends StatelessWidget {
  VehicalDetailCard({super.key, required this.vehicleInfo});

  final Data vehicleInfo;

  @override
  String address = "";
  final controller = Get.isRegistered<VehicalesController>()
      ? Get.find<VehicalesController>() // Find if already registered
      : Get.put(VehicalesController());


  @override
  Widget build(BuildContext context) {
    String date = 'Update unavailable';
    String time = "";
    if (vehicleInfo.trackingData?.lastUpdateTime?.isNotEmpty ?? false) {
      date =
      '${DateFormat("dd MMM y").format(DateTime.parse(vehicleInfo.trackingData?.lastUpdateTime ?? "").toLocal()) ?? ''}';
      time =
      '${DateFormat("hh:mm").format(DateTime.parse(vehicleInfo.trackingData?.lastUpdateTime ?? "").toLocal()) ?? ''}';
    }

    var trackingData = vehicleInfo.trackingData;

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
        borderRadius: BorderRadius.circular(AppSizes.radius_16),
      ),
      child: FutureBuilder<String>(
        future: (trackingData?.location?.latitude != null &&
            trackingData?.location?.longitude != null)
            ? controller.getAddressFromLatLong(
          trackingData?.location?.latitude ?? 0.0,
          trackingData?.location?.longitude ?? 0.0,
        )
            : Future.value("Address Unavailable"),
        builder: (context, snapshot) {
          String address = "Fetching Address...";
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              address = "Error Fetching Address";
            } else {
              address = snapshot.data ?? "Address Unavailable";
            }
          }

          return VehicleDataWidget(
            displayParameters: vehicleInfo.displayParameters,
            vehicleName: vehicleInfo.vehicleNo ?? '',
            address: address,
            lastUpdate: date + " " + time,
            odo: (vehicleInfo.trackingData?.totalDistanceCovered ?? "")
                .toString(),
            fuel: (vehicleInfo.trackingData?.fuelGauge?.quantity ?? "")
                .toString(),
            speed: (vehicleInfo.trackingData?.currentSpeed ?? "").toString(),
            deviceId: vehicleInfo.trackingData?.deviceID ?? '',
            doorIsActive: vehicleInfo.trackingData?.door,
            doorSubTitle: vehicleInfo.trackingData?.door == null
                ? "N/A"
                : ((vehicleInfo.trackingData!.door!) ? "OPEN" : "CLOSED"),
            engineIsActive: null,
            engineSubTitle: "N/A",
            parkingIsActive: vehicleInfo.parking,
            parkingSubTitle: vehicleInfo.parking == null
                ? "N/A"
                : ((vehicleInfo.parking!) ? "ON" : "OFF"),
            immobilizerIsActive: vehicleInfo.immobiliser == null
                ? null
                : (vehicleInfo.immobiliser! == "Stop"),
            immobilizerSubTitle: vehicleInfo.immobiliser == null
                ? "N/A"
                : ((vehicleInfo.immobiliser! == "Stop") ? "ON" : "OFF"),
            geofenceIsActive: vehicleInfo.area != null,
            geofenceSubTitle: vehicleInfo.area != null ? "ON" : "OFF",
            gpsIsActive: vehicleInfo.trackingData?.gps,
            gpsSubTitle: vehicleInfo.trackingData?.gps == null
                ? "N/A"
                : ((vehicleInfo.trackingData!.gps!) ? "ON" : "OFF"),
            networkIsActive: vehicleInfo.trackingData?.network == null
                ? null
                : vehicleInfo.trackingData?.network == "Connected",
            networkSubTitle: vehicleInfo.trackingData?.network == null
                ? "N/A"
                : (vehicleInfo.trackingData?.network == "Connected")
                ? "AVAILABLE"
                : "OFF",
            acIsActive: vehicleInfo.trackingData?.ac,
            acSubTitle: vehicleInfo.trackingData?.ac == null
                ? "N/A"
                : ((vehicleInfo.trackingData!.ac!) ? "ON" : "OFF"),
            chargingIsActive: null,
            chargingSubTitle: "N/A",
            imei: vehicleInfo.imei ?? "",
          ).paddingSymmetric(horizontal: 4.w, vertical: 1.5.h);
        },
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
