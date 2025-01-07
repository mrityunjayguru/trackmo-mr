import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/config/app_sizer.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/profile/controller/profile_controller.dart';
import 'package:track_route_pro/utils/common_import.dart';

import '../../../../constants/project_urls.dart';
import '../../../../service/model/presentation/track_route/track_route_vehicle_list.dart';
import '../../../../utils/utils.dart';
import '../../../splash_screen/controller/data_controller.dart';

class ReNewSubscription extends StatefulWidget {
  const ReNewSubscription({super.key});

  @override
  State<ReNewSubscription> createState() => _ReNewSubscriptionState();
}

class _ReNewSubscriptionState extends State<ReNewSubscription> {
  final controller = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>() // Find if already registered
      : Get.put(ProfileController());
  final dataController = Get.isRegistered<DataController>()
      ? Get.find<DataController>() // Find if already registered
      : Get.put(DataController());
  ValueNotifier<int> selectedIndex = ValueNotifier(-1);

  @override
  void dispose() {
    super.dispose();
    selectedIndex.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Obx(
              () => Row(
                children: [
                  Image.network(
                      width: 25,
                      height: 25,
                      "${ProjectUrls.imgBaseUrl}${dataController.settings.value.logo}",
                      errorBuilder: (context, error, stackTrace) =>
                          SvgPicture.asset(
                            Assets.images.svg.icIsolationMode,
                            color: AppColors.black,
                          )).paddingOnly(right:8),
                  Text(
                    'Renew Subscription ',
                    style: AppTextStyles(context).display20W500,
                  ),
                  Spacer(),
                  Text(
                    'v${controller.appVersion}',
                    style: AppTextStyles(context).display16W500,
                  ),
                ],
              ).paddingOnly(top: 12, right: 3.w * 0.9, left: 3.w * 0.9),
            ),
            SizedBox(height: 16),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 100.w - (4.w * 0.9),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff00000026).withOpacity(0.15),
                        blurRadius: 2,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      )
                    ],
                    color: AppColors.whiteOff,
                    borderRadius: BorderRadius.circular(AppSizes.radius_24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username',
                        style: AppTextStyles(context)
                            .display12W400
                            .copyWith(color: AppColors.grayLight),
                      ),
                      Text(
                        '${controller.name ?? ''}',
                        style: AppTextStyles(context).display14W600,
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      if(controller.expiringVehicles.length<1)Text("No devices available currently for renewal", style: AppTextStyles(context).display20W600)
                      else Text('List of Devices',
                          style: AppTextStyles(context).display20W500),
                      SizedBox(
                        height: 0.5.h,
                      ),
                      SizedBox(
                        height: controller.expiringVehicles.length < 10
                            ? controller.expiringVehicles.length * (6.h)
                            : 50.h,
                        child: ValueListenableBuilder(
                          valueListenable: selectedIndex,
                          builder:
                              (BuildContext context, value, Widget? child) {
                            return ListView.builder(
                              shrinkWrap: true,
                              // Ensures it fits within the parent
                              itemCount: controller.expiringVehicles.length,
                              itemBuilder: (context, index) {
                                // Get the vehicle data
                                Data vehicle =
                                controller.expiringVehicles[index];
                                bool isSelected =
                                    controller.selectedVehicleIndex.value ==
                                        index;
                                return Row(
                                  children: [
                                    Checkbox(
                                      value: controller
                                          .selectedVehicleIndex.value ==
                                          index,
                                      onChanged: (value) {
                                        controller
                                            .toggleVehicleSelection(index);
                                        selectedIndex.value = index;
                                      },
                                    ),
                                    Flexible(
                                      child: Text(
                                        vehicle.vehicleNo ?? 'Unknown',
                                        overflow: TextOverflow.ellipsis,
                                        // Display the vehicle number
                                        style: AppTextStyles(context)
                                            .display12W600,
                                      ).paddingOnly(right: 2.w),
                                    ),
                                    Text(
                                      'Expiring ${DateFormat("dd MMM y").format(DateTime.parse(vehicle.subscriptionExp ?? DateFormat("dd-MM-yyyy").format(DateTime.now()))) ?? 'Unknown'}',
                                      // Display the expiration date
                                      style: AppTextStyles(context)
                                          .display11W400
                                          .copyWith(
                                          color: AppColors.grayLight),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ).paddingSymmetric(horizontal: 4.w, vertical: 3.h),
                ),
                Positioned(
                  bottom: -2.5.h, // Positioned outside the card
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        if(controller.selectedVehicleIndex.value!=-1){
                          controller.renewService();
                        }
                        else{
                          Utils.getSnackbar("Error", "Please select an item for renewal");
                        }
                      },
                      child: Container(
                        width: 50.w,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius_24),
                          color: AppColors.black,
                        ),
                        child: Center(
                          child: Text(
                            'Request Renewal',
                            style: AppTextStyles(context)
                                .display14W400
                                .copyWith(color: AppColors.selextedindexcolor),
                          ).paddingSymmetric(horizontal: 3.w, vertical: 1.4.h),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 35),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  controller.isReNewSub.value = false;
                  controller.selectedVehicleIndex.value = -1;
                },
                child: Container(
                  width: 50.w,
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(AppSizes.radius_24),
                    color: AppColors.black,
                  ),
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: AppTextStyles(context)
                          .display14W400
                          .copyWith(color: AppColors.selextedindexcolor),
                    ).paddingSymmetric(horizontal: 10.w, vertical: 1.4.h),
                  ),
                ),
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 4.w * 0.9),
      ),
    );
  }
}
