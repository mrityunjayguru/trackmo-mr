import 'dart:developer';

import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/config/app_sizer.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/track_route_screen/controller/track_route_controller.dart';
import 'package:track_route_pro/modules/track_route_screen/view/widgets/geofence_dialog.dart';
import 'package:track_route_pro/modules/track_route_screen/view/widgets/speed_dialog.dart';
import 'package:track_route_pro/modules/track_route_screen/view/widgets/vehicle_update_dialog.dart';
import 'package:track_route_pro/utils/common_import.dart';

import '../../../../constants/project_urls.dart';
import '../../../../service/model/presentation/vehicle_type/Data.dart';
import '../../../../utils/search_drop_down.dart';
import '../../../../utils/style.dart';
import '../../../../utils/utils.dart';
import '../../../profile/controller/profile_controller.dart';
import '../../../splash_screen/controller/data_controller.dart';

class VehicleSelected extends StatelessWidget {
  VehicleSelected({super.key});

  final controller = Get.isRegistered<TrackRouteController>()
      ? Get.find<TrackRouteController>() // Find if already registered
      : Get.put(TrackRouteController());

  final WidgetStateProperty<Icon?> thumbIcon =
      WidgetStateProperty.resolveWith<Icon?>(
    (Set<WidgetState> states) {
      return const Icon(Icons.close, color: Colors.transparent);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(6.h + 4.8.h),
        child: Column(
          children: [
            SizedBox(
              height: 4.8.h,
            ),
            Obx(
              () => Utils()
                  .topBar(
                      context: context,
                      rightIcon: 'assets/images/svg/ic_arrow_left.svg',
                      onTap: () {
                        controller.stackIndex.value = 0;
                      },
                      name:
                          '${controller.deviceDetail.value.data?[0].vehicleNo ?? ''}')
                  .paddingOnly(top: 12, bottom: 20, left: 10, right: 10),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius_16),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                  color: Color(0xff000000).withOpacity(0.15))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Geofencing',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles(context)
                                              .display14W400
                                              .copyWith(
                                                  color:
                                                      AppColors.color_444650),
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Flexible(
                                        child: SizedBox(
                                          height: 25,
                                          child: Switch(
                                            thumbIcon: thumbIcon,
                                            trackOutlineWidth:
                                                WidgetStatePropertyAll(0),
                                            trackOutlineColor:
                                                WidgetStatePropertyAll(
                                                    Colors.transparent),
                                            activeColor:
                                                AppColors.selextedindexcolor,
                                            value: controller.geofence.value,
                                            inactiveThumbColor:
                                                AppColors.selextedindexcolor,
                                            inactiveTrackColor: AppColors.white,
                                            activeTrackColor: AppColors.black,
                                            onChanged: (value) {
                                              if (value) {
                                                Utils.openDialog(
                                                  context: context,
                                                  child: GeofenceDialog(),
                                                );
                                              } else {
                                                controller.latitudeUpdate.text =
                                                    "";
                                                controller
                                                    .longitudeUpdate.text = "";
                                                controller.areaUpdate.text = "";
                                                controller
                                                    .selectCurrentLocationUpdate
                                                    .value = false;
                                                controller
                                                    .editDevicesByDetails(editGeofence: true,context: context);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Utils.openDialog(
                                      context: context,
                                      child: GeofenceDialog(),
                                    );
                                  },
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppColors.grayLight,
                                    size: 20,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Parking',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles(context)
                                        .display14W400
                                        .copyWith(
                                            color: AppColors.color_444650),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: SizedBox(
                                    height: 25,
                                    child: Switch(
                                      thumbIcon: thumbIcon,
                                      trackOutlineWidth:
                                          WidgetStatePropertyAll(0),
                                      trackOutlineColor: WidgetStatePropertyAll(
                                          Colors.transparent),
                                      activeColor: AppColors.selextedindexcolor,
                                      value: controller.parkingUpdate.value,
                                      inactiveThumbColor:
                                          AppColors.selextedindexcolor,
                                      inactiveTrackColor: AppColors.white,
                                      activeTrackColor: AppColors.black,
                                      onChanged: (value) {
                                        controller.parkingUpdate.value =
                                            !(controller.parkingUpdate.value);
                                        controller.editDevicesByDetails(context: context);
                                      },
                                    ),
                                  ).paddingOnly(right: 20),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Max Speed',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles(context)
                                              .display14W400
                                              .copyWith(
                                                  color:
                                                      AppColors.color_444650),
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Flexible(
                                        child: Text(
                                          "${controller.deviceDetail.value.data?[0].maxSpeed ?? '-'}  Kmph",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles(context)
                                              .display14W400
                                              .copyWith(
                                                  color:
                                                      AppColors.color_444650),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                InkWell(
                                  onTap: () {
                                    Utils.openDialog(
                                      context: context,
                                      child: SpeedDialog(),
                                    );
                                  },
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppColors.grayLight,
                                    size: 20,
                                  ),
                                )
                              ],
                            ),
                          ],
                        )
                            .paddingSymmetric(vertical: 10, horizontal: 10)
                            .paddingSymmetric(horizontal: 2.w, vertical: 1.h),
                      ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "General",
                              style: AppTextStyles(context)
                                  .display14W400
                                  .copyWith(color: AppColors.color_969696),
                            ),
                            InkWell(
                              onTap: () {
                                // controller.isedit.value = true;
                                Utils.openDialog(
                                  context: context,
                                  child: VehicleUpdateDialog(),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                width: 34.w,
                                child: Center(
                                  child: Text(
                                    'Edit Details',
                                    style: AppTextStyles(context)
                                        .display14W400
                                        .copyWith(color: Color(0xffD9E821)),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ],
                        ).paddingOnly(bottom: 15, top: 15),

                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius_16),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                  color: Color(0xff000000).withOpacity(0.15))
                            ]),
                        child: Column(
                          children: [
                            buildRow(
                              context,
                              'Date Added',
                              '${formatDate(controller.deviceDetail.value.data?[0].dateAdded) ?? '-'}',
                            ),
                            SizedBox(height: 10),
                            buildRow(
                              context,
                              'Vehicle Registration No.',
                              '${controller.deviceDetail.value.data?[0].vehicleRegistrationNo ?? '-'}',
                            ),
                            SizedBox(height: 10),
                            buildRow(
                              context,
                              'Driver Name',
                              '${controller.deviceDetail.value.data?[0].driverName ?? '-'}',
                            ),
                            SizedBox(height: 10),
                            buildRow(
                              context,
                              'Driver Mobile No.',
                              '${controller.deviceDetail.value.data?[0].mobileNo ?? '-'}',
                            ),
                            SizedBox(height: 10),
                            buildRow(
                              context,
                              'Vehicle Type',
                              '${controller.deviceDetail.value.data?[0].vehicletype?.vehicleTypeName ?? '-'}',
                            ),
                            SizedBox(height: 10),
                            // buildRow(
                            //   context,
                            //   'Vehicle Brand',
                            //   '${controller.deviceDetail.value.data?[0].vehicleBrand ?? '-'}',
                            // ),
                            // SizedBox(height: 10),
                            buildRow(
                              context,
                              'Vehicle Model',
                              '${controller.deviceDetail.value.data?[0].vehicleModel ?? '-'}',
                            ),
                            SizedBox(height: 10),
                            buildRow(
                              context,
                              'Insurance Expiry Date',
                              formatDate(
                                  '${controller.deviceDetail.value.data?[0].insuranceExpiryDate ?? '-'}'),
                            ),
                            SizedBox(height: 10),
                            buildRow(
                              context,
                              'Pollution Expiry Date',
                              formatDate(
                                  '${controller.deviceDetail.value.data?[0].pollutionExpiryDate ?? '-'}'),
                            ),
                            SizedBox(height: 10),
                            buildRow(
                              context,
                              'Fitness Expiry Date',
                              formatDate(
                                  '${controller.deviceDetail.value.data?[0].fitnessExpiryDate ?? '-'}'),
                            ),
                            SizedBox(height: 10),
                            buildRow(
                              context,
                              'National Permit Expiry Date',
                              formatDate(
                                  '${controller.deviceDetail.value.data?[0].nationalPermitExpiryDate ?? '-'}'),
                            ),
                            SizedBox(height: 8),
                          ],
                        ).paddingSymmetric(horizontal: 3.w, vertical: 1.h),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(
                height: 4.h,
              ),
              // Obx(
              //   () => controller.isedit.value
              //       ? InkWell(
              //           onTap: () {
              //             controller.stackIndex.value = 0;
              //             // controller.isedit.value = false;
              //             // controller.editDevicesByDetails();
              //           },
              //           child: Container(
              //             height: 6.h,
              //             width: 34.w,
              //             child: Center(
              //               child: Text(
              //                 'Submit',
              //                 style: AppTextStyles(context)
              //                     .display16W400
              //                     .copyWith(color: Color(0xffD9E821)),
              //               ),
              //             ),
              //             decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(25),
              //               color: AppColors.black,
              //             ),
              //           ).paddingOnly(bottom: 20),
              //         )
              //       : SizedBox.shrink(),
              // ),
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 2),
                          blurRadius: 2,
                          spreadRadius: 0,
                          color: Color(0xff000000).withOpacity(0.15))
                    ],
                    borderRadius: BorderRadius.circular(AppSizes.radius_8),
                    color: AppColors.backgroundColor),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SvgPicture.asset('assets/images/svg/engine_icon.svg')
                        .paddingSymmetric(horizontal: 3.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Immobilizer/ Engine Lock',
                          style: AppTextStyles(context)
                              .display10W500
                              .copyWith(color: AppColors.color_e92e19),
                        ).paddingOnly(bottom: 3),
                        Text(
                          "Relay On/Off",
                          style: AppTextStyles(context)
                              .display10W500
                              .copyWith(color: AppColors.grayLight),
                        ).paddingOnly(bottom: 3),
                      ],
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        if (controller.relayStatus == "Stop") {
                          Get.showOverlay(
                              asyncFunction: () => controller.startEngine(
                                  controller.deviceDetail.value.data?[0].imei ??
                                      ""),
                              loadingWidget:
                                  LoadingAnimationWidget.dotsTriangle(
                                color: AppColors.selextedindexcolor,
                                size: 50,
                              ));
                        } else {
                          Get.showOverlay(
                              asyncFunction: () => controller.stopEngine(
                                  controller.deviceDetail.value.data?[0].imei ??
                                      ""),
                              loadingWidget:
                                  LoadingAnimationWidget.dotsTriangle(
                                color: AppColors.selextedindexcolor,
                                size: 50,
                              ));
                        }
                      },
                      child: Obx(
                        () => Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(AppSizes.radius_8),
                                  bottomRight:
                                      Radius.circular(AppSizes.radius_8)),
                              color: controller.relayStatus != "Stop"
                                  ? AppColors.color_e92e19
                                  : AppColors.success),
                          child: Column(
                            children: [
                              Icon(
                                Icons.power_settings_new,
                                color: Colors.white,
                              ),
                              Text(
                                controller.relayStatus != "Stop" ? "ON" : "OFF",
                                style: AppTextStyles(context)
                                    .display12W500
                                    .copyWith(color: AppColors.appWhiteColor),
                              ).paddingOnly(top: 1),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ).paddingOnly(bottom: 10),
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'WARNING:',
                        style: TextStyle(
                          color: AppColors.color_e92e19,
                          fontSize: 8,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' When the Vehicle Immobiliser is active, it will instantly shut down the car',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ).paddingOnly(bottom: 20),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radius_20),
                    color: AppColors.backgroundColor),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                      height: 5.h,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius_20),
                          color: AppColors.backgroundColor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Subscription Expiration',
                            style: AppTextStyles(context)
                                .display10W500
                                .copyWith(color: AppColors.grayLight),
                          ).paddingOnly(bottom: 3),
                          Obx(
                            () => Text(
                              formatDateString(
                                  '${controller.deviceDetail.value.data?[0].subscriptionExp ?? '-'}'),
                              style: AppTextStyles(context).display12W600,
                            ),
                          ),
                        ],
                      ).paddingOnly(left: 3.w),
                    )),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        final profile = Get.isRegistered<ProfileController>()
                            ? Get.find<
                                ProfileController>() // Find if already registered
                            : Get.put(ProfileController());
                        profile.renewService(
                            id: controller.deviceDetail.value.data?[0].sId);
                      },
                      child: Container(
                        height: 5.h,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius_20),
                            color: AppColors.black),
                        child: Center(
                          child: Text(
                            'Renew / Extend Subscription',
                            style: AppTextStyles(context)
                                .display12W500
                                .copyWith(color: AppColors.selextedindexcolor),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ).paddingOnly(bottom: 20, top: 10),
            ],
          ),
        ).paddingSymmetric(horizontal: 4.w * 0.9),
      ),
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return '-'; // Handle null case
    try {
      // Parse the date string to a DateTime object
      DateTime dateTime = DateTime.parse(dateStr);
      // Format the date as dd-mm-yyyy
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return '-'; // Handle parsing error
    }
  }

  String formatDateString(String? dateStr) {
    if (dateStr == null) return '-'; // Handle null case
    try {
      // Parse the date string to a DateTime object
      DateTime dateTime = DateTime.parse(dateStr);
      // Format the date as dd-mm-yyyy
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return '-'; // Handle parsing error
    }
  }

  void _selectDate(context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Formatting the picked date
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);

      controller.text = formattedDate; // Update the textfield
    }
  }

  Widget buildRow(BuildContext context, String labelText, String valueText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: SizedBox(
            height: 2.h,
            child: Text(
              labelText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles(context)
                  .display14W400
                  .copyWith(color: AppColors.color_444650),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            valueText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyles(context)
                .display14W400
                .copyWith(color: AppColors.color_444650),
          ),
        ),
      ],
    );
  }
}
