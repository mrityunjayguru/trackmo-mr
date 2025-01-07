import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/modules/route_history/controller/history_controller.dart';
import 'package:track_route_pro/service/model/presentation/track_route/DisplayParameters.dart';
import 'package:track_route_pro/utils/utils.dart';

import '../config/app_sizer.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_textstyle.dart';
import '../gen/assets.gen.dart';
import '../modules/track_route_screen/controller/track_route_controller.dart';

class VehicleDataWidget extends StatelessWidget {

  final String odo;
  final String fuel;
  final String speed;
  final String deviceId;
  final bool? doorIsActive;
  final bool showStats, showDeviceId;
  final String doorSubTitle;
  final bool? engineIsActive;
  final DisplayParameters? displayParameters;
  final String engineSubTitle;
  final bool? parkingIsActive;
  final String parkingSubTitle;
  final bool? immobilizerIsActive;
  final String immobilizerSubTitle;
  final bool? geofenceIsActive;
  final String geofenceSubTitle;
  final bool? gpsIsActive;
  final String gpsSubTitle;
  final bool? networkIsActive;
  final String networkSubTitle;
  final bool? acIsActive;
  final String acSubTitle;
  final bool? chargingIsActive;
  final String chargingSubTitle;
  final String address;
  final String lastUpdate;
  final String vehicleName;
  final String imei;

  VehicleDataWidget({
    required this.odo,
    required this.fuel,
    required this.speed,
    required this.deviceId,
    required this.doorIsActive,
    this.showStats = false,
    this.showDeviceId = true,
    required this.doorSubTitle,
    required this.engineIsActive,
    required this.engineSubTitle,
    required this.parkingIsActive,
    required this.parkingSubTitle,
    required this.immobilizerIsActive,
    required this.immobilizerSubTitle,
    required this.geofenceIsActive,
    required this.geofenceSubTitle,
    required this.gpsIsActive,
    required this.gpsSubTitle,
    required this.networkIsActive,
    required this.networkSubTitle,
    required this.acIsActive,
    required this.acSubTitle,
    required this.chargingIsActive,
    required this.chargingSubTitle,
    required this.address,
    required this.lastUpdate,
    required this.vehicleName, required this.imei, this.displayParameters,
  });

  var controller = Get.put(TrackRouteController());
  var routeHistoryController = Get.put(HistoryController());
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle',
                    style: AppTextStyles(context)
                        .display12W400
                        .copyWith(color: AppColors.grayLight),
                  ),
                  Text(
                    vehicleName,
                    style: AppTextStyles(context)
                        .display14W500
                        .copyWith(color: AppColors.black),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Last Update',
                    style: AppTextStyles(context)
                        .display12W400
                        .copyWith(color: AppColors.grayLight),
                  ),
                  Text(
                    lastUpdate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles(context)
                        .display14W500
                        .copyWith(color: AppColors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        Container(
          decoration: BoxDecoration(
              color: AppColors.selextedindexcolor,
              borderRadius: BorderRadius.circular(AppSizes.radius_24)),
          child: Row(
            children: [
              SvgPicture.asset('assets/images/svg/ic_location.svg'),
              Flexible(
                child: Text(
                  address,
                  style: AppTextStyles(context).display13W500,
                ).paddingOnly(left: 5),
              )
            ],
          ).paddingOnly(left: 6, bottom: 7, top: 7),
        ),
        SizedBox(height: 1.5.h),
        if (showStats) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vehicle Stats',
                style: AppTextStyles(context).display14W600,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(AppSizes.radius_20),
                    color: AppColors.whiteOff),
                child: InkWell(
                  onTap: () {
                    controller.isShowvehicleDetail.value = false;
                    controller.selectedVehicleIndex.value = -1;
                    controller.showAllVehicles();
                    controller.stackIndex.value=2;
                    routeHistoryController.name.value = vehicleName;
                    routeHistoryController.address.value = address;
                    routeHistoryController.updateDate.value = lastUpdate;
                    routeHistoryController.imei.value = imei;
                    routeHistoryController.generateTimeList();
                    routeHistoryController.showMap.value=false;
                    routeHistoryController.data.value=[];
                  },
                  child: Container(
                    height: 5.h,
                    width: 30.w,
                    decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(AppSizes.radius_20),
                        color: AppColors.black),
                    child: Center(
                      child: Text(
                        'Route History',
                        style: AppTextStyles(context)
                            .display13W500
                            .copyWith(
                            color: AppColors.selextedindexcolor),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
        ],
        Container(
          decoration: BoxDecoration(
              color: AppColors.whiteOff,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 1),
                  color: Color(0xff000000).withOpacity(0.2),
                )
              ],
              borderRadius: BorderRadius.circular(AppSizes.radius_24)),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.grayBright,
                      child:
                      SvgPicture.asset(Assets.images.svg.icSpeedometer),
                    ).paddingOnly(left: 3),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Odometer',
                            style: AppTextStyles(context)
                                .display11W400
                                .copyWith(color: AppColors.grayLight),
                          ).paddingOnly(left: 3),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  Utils.formatInt(
                                      data: odo),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                  style: AppTextStyles(context).display12W600,
                                ),
                              ),
                              Text(
                                ' KM',
                                style: AppTextStyles(context)
                                    .display11W400
                                    .copyWith(color: AppColors.grayLight),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 3,
                child: Row(
                  children: [
                    SizedBox(
                      width: 2.w,
                    ),
                    Container(
                      height: 4.h,
                      color: AppColors.selextedindexcolor,
                      width: 2,
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Speed',
                            style: AppTextStyles(context)
                                .display11W400
                                .copyWith(color: AppColors.grayLight),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  Utils.toStringAsFixed(
                                      data: speed),
                                  style: AppTextStyles(context).display12W600,
                                ),
                              ),
                              Text(
                                ' Kmph',
                                style: AppTextStyles(context)
                                    .display11W400
                                    .copyWith(color: AppColors.grayLight),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radius_24),
                      border:
                      Border.all(color: AppColors.selextedindexcolor)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: fuel =="N/A" ? AppColors.selextedindexcolor:AppColors.grayBright,
                        child:
                        SvgPicture.asset('assets/images/svg/ic_fuel.svg'),
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Fuel',
                                  style: AppTextStyles(context)
                                      .display10W400
                                      .copyWith(color: AppColors.grayLight),
                                ),
                                Text(
                                  '(Aprrox)',
                                  style: AppTextStyles(context)
                                      .display10W400
                                      .copyWith(color: AppColors.grayLight),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child:  Text(
                                    Utils.toStringAsFixed(
                                        data: fuel),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles(context)
                                        .display12W600,
                                  ),
                                ),
                                Text(
                                  ' Ltr',
                                  style: AppTextStyles(context)
                                      .display11W400
                                      .copyWith(color: AppColors.grayLight),
                                ),
                              ],
                            ),

                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 1.5.h),
        if(displayParameters!=null)SizedBox(
          height: 10.h,
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            thickness: 2,
            child: ListView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              children: _buildVehicleItems(context),
            ),
          ),
        ),
        if(displayParameters!=null)SizedBox(height: 1.5.h),
        if(showDeviceId)Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device ID',
              style: AppTextStyles(context)
                  .display12W400
                  .copyWith(color: AppColors.grayLight),
            ),
            Text(
              deviceId,
              style: AppTextStyles(context).display12W500,
            ),
          ],
        )
      ],
    );
  }


  List<Widget> _buildVehicleItems(BuildContext context) {
    return [
      if(displayParameters?.door!=null)_buildVehicleItem(context, 'Door', doorIsActive, doorSubTitle,
          'assets/images/svg/ic_door.svg'),
      if(displayParameters?.engine!=null)_buildVehicleItem(context, 'Engine', engineIsActive, engineSubTitle,
          'assets/images/svg/ic_engine_icon.svg'),
      if(displayParameters?.parking!=null)_buildVehicleItem(context, 'Parking', parkingIsActive, parkingSubTitle,
          'assets/images/svg/ic_parking_icon.svg'),
      if(displayParameters?.relay!=null)_buildVehicleItem(context, 'Immobilizer', immobilizerIsActive,
          immobilizerSubTitle, 'assets/images/svg/ic_relay_icon.svg'),
      if(displayParameters?.geoFencing!=null)_buildVehicleItem(context, 'Geofence', geofenceIsActive, geofenceSubTitle,
          'assets/images/svg/ic_geofence_icon.svg'),
      if(displayParameters?.gps!=null)_buildVehicleItem(context, 'GPS', gpsIsActive, gpsSubTitle,
          'assets/images/svg/gps.svg'),
      if(displayParameters?.network!=null)_buildVehicleItem(context, 'Network', networkIsActive, networkSubTitle,
          'assets/images/svg/ic_signal_tower.svg'),
      if(displayParameters?.ac!=null)_buildVehicleItem(
          context, 'AC', acIsActive, acSubTitle, 'assets/images/svg/ic_ac.svg'),
      if(displayParameters?.charging!=null)_buildVehicleItem(context, 'Charging', chargingIsActive, chargingSubTitle,
          'assets/images/svg/ic_charging_icon.svg'),
    ];
  }

  Widget _buildVehicleItem(BuildContext context, String title, bool? isActive,
      String subTitle, String iconPath) {
    return Row(
      children: [
        SizedBox(
          width: 55,
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: isActive == null
                    ? AppColors.grayLighter
                    : (isActive ? AppColors.success : AppColors.errorColor),
                child: SvgPicture.asset(
                  iconPath,
                  colorFilter: isActive == null
                      ? ColorFilter.mode(AppColors.black, BlendMode.srcIn)
                      : ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              SizedBox(height: 1.h),
              FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles(context)
                      .display11W500
                      .copyWith(color: AppColors.black),
                ),
              ),
              // SizedBox(height: 0.3.h),
              // FittedBox(
              //   fit: BoxFit.contain,
              //   child: Text(
              //     subTitle,
              //     style: AppTextStyles(context)
              //         .display11W800
              //         .copyWith(color: AppColors.black),
              //   ),
              // ),
            ],
          ),
        ),
        SizedBox(width: 4),
      ],
    );
  }
}
