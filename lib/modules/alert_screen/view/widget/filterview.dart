import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/config/app_sizer.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/alert_screen/controller/alert_controller.dart';
import 'package:track_route_pro/utils/common_import.dart';

class FilterviewDialog extends StatelessWidget {
  FilterviewDialog({super.key});
  final controller = Get.find<AlertController>();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      alignment: Alignment.topCenter,
      backgroundColor: AppColors.whiteOff,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius_20),
      ),
      child: Obx(() {
        print(''.obs);
        return SizedBox(
            width: 92.w,
            height: 50.h,
            child: Column(
              children: [
                Container(
                  height: 5.h,
                  decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                            AppSizes.radius_20,
                          ),
                          topRight: Radius.circular(
                            AppSizes.radius_20,
                          ))),
                  child: Row(
                    children: [
                      Text(
                        'Alert Settings',
                        style: AppTextStyles(context)
                            .display20W500
                            .copyWith(color: AppColors.selextedindexcolor),
                      ),
                      Spacer(),
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: SvgPicture.asset(
                            'assets/images/svg/ic_close.svg',
                            color: AppColors.whiteOff,
                          )),
                    ],
                  ).paddingSymmetric(horizontal: 20, vertical: 6),
                ),
                alertData(isOn: controller.IgnitionOn, title: 'Ignition On'),
                alertData(isOn: controller.IgnitionOff, title: 'Ignition Off'),
                alertData(
                    isOn: controller.OverSpeed,
                    title: 'Over Speed (80 kmph)'),
                // alertData(
                //     isOn: controller.MovementStop, title: 'Movement Stop'),
                // alertData(isOn: controller.Parking, title: 'Parking'),
                // alertData(
                //     isOn: controller.DevicePowerCut,
                //     title: 'Device Power Cut'),
                alertData(
                    isOn: controller.DeviceLowBattery, title: 'Device Low Battery'),
              ],
            ));
      }),
    ).paddingOnly(top: 4.h);
  }

  Widget alertData({
    required String title,
    required ValueNotifier<bool> isOn,
  }) {
    return Row(
      children: [
        SvgPicture.asset(Assets.images.svg.icFlashGreen),
        SizedBox(
          width: 2.w,
        ),
        Text('${title}'),
        Spacer(),
        AdvancedSwitch(
          controller: isOn,
          initialValue: isOn.value,
          activeColor: AppColors.grayBright,
          inactiveColor: AppColors.grayBright,
          thumb: ValueListenableBuilder<bool>(
            valueListenable:
                isOn, // Listen to the ValueNotifier
            builder: (context, value, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? AppColors.success : AppColors.danger,
                ),
              );
            },
          ),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          width: 40.0,
          height: 20.0,
          enabled: true,
          disabledOpacity: 0.5,
        ).paddingOnly(right: 6.w),
      ],
    ).paddingOnly(left: 6.w, top: 2.h);
  }
}
