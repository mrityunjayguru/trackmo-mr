import 'package:sizer/sizer.dart';

import '../../../../common/textfield/apptextfield.dart';
import '../../../../config/app_sizer.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_textstyle.dart';
import '../../../../utils/common_import.dart';
import '../../../../utils/utils.dart';
import '../../controller/track_route_controller.dart';
import 'edit_text_field.dart';

class GeofenceDialog extends StatelessWidget {
  GeofenceDialog({super.key});

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
    return Container(
      color: AppColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Add Geofencing',
                  style: AppTextStyles(context).display16W600,
                ),
              ),
              InkWell(
                onTap: () {
                  controller.geofence.value = controller.deviceDetail.value.data?[0].location?.latitude !=null && controller.deviceDetail.value.data?[0].location?.latitude != 0;
                  controller.latitudeUpdate.text = ( controller.deviceDetail.value.data?[0].location?.latitude ?? '').toString();
                  controller.longitudeUpdate.text = ( controller.deviceDetail.value.data?[0].location?.longitude ?? '').toString();
                  controller.parkingUpdate.value =  controller.deviceDetail.value.data?[0].parking ?? false;
                  controller.areaUpdate.text = ( controller.deviceDetail.value.data?[0].area ?? '').toString();
                },
                child: Container(

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radius_24),
                    color: AppColors.black,
                  ),
                  child: Center(
                    child: Text(
                      'Reset',
                      style: AppTextStyles(context)
                          .display12W500
                          .copyWith(color: AppColors.selextedindexcolor),
                    ).paddingSymmetric(horizontal: 4.w, vertical: 1.1.h),
                  ),
                ).paddingSymmetric(vertical: 1.4.h),
              ),
            ],
          ),
          Row(

            children: [
              Text(
                'Latitude   ',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles(context)
                    .display14W400
                    .copyWith(color: AppColors.color_444650),
              ),
              SizedBox(width: 4.w),
              Expanded(
                  child: EditTextField(
                    controller: controller.latitudeUpdate,
                    hintText: "Latitude",
                  )),
            ],
          ).paddingSymmetric(vertical: 12),
          Row(

            children: [
              Text(
                'Longitude',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles(context)
                    .display14W400
                    .copyWith(color: AppColors.color_444650),
              ),
              SizedBox(width: 4.w),
              Expanded(
                  child: EditTextField(
                    controller: controller.longitudeUpdate,
                    hintText: "Longitude",
                  )),
            ],
          ).paddingSymmetric(vertical: 12),
          Text(
            'Or',
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles(context)
                .display14W400
                .copyWith(color: AppColors.color_444650),
          ).paddingSymmetric(vertical: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Current Location',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles(context)
                    .display14W400
                    .copyWith(color: AppColors.color_444650),
              ),
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
                    value: controller.selectCurrentLocationUpdate.value,
                    inactiveThumbColor:
                    AppColors.selextedindexcolor,
                    inactiveTrackColor: AppColors.backgroundColor,
                    activeTrackColor: AppColors.black,
                    onChanged: (value) {
                      controller.selectCurrentLocationUpdate.value = !controller.selectCurrentLocationUpdate.value;
                    },
                  ),
                ),
              ),
            ],
          ).paddingSymmetric(vertical: 12),
          Row(
            children: [
              Text(
                'Area',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles(context)
                    .display14W400
                    .copyWith(color: AppColors.color_444650),
              ),
              SizedBox(width: 4.w),
              Expanded(
                  child: EditTextField(
                    controller: controller.areaUpdate,
                    hintText: "Area",
                  )),
              SizedBox(width: 4.w),
              Text(
                'Radius In Feet',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles(context)
                    .display11W400
                    .copyWith(color: AppColors.color_444650),
              ),
            ],
          ).paddingSymmetric(vertical: 12),
          InkWell(
            onTap: () {
              controller.geofence.value =
              !(controller
                  .geofence.value);
              controller
                  .editDevicesByDetails(editGeofence: true, context: context);
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radius_24),
                color: AppColors.black,
              ),
              child: Center(
                child: Text(
                  'Set Speed Alert',
                  style: AppTextStyles(context)
                      .display12W500
                      .copyWith(color: AppColors.selextedindexcolor),
                ).paddingSymmetric(horizontal: 4.w, vertical: 1.1.h),
              ),
            ).paddingSymmetric(vertical: 1.4.h, horizontal: 25),
          ),
        ],
      ),
    );
  }
}
