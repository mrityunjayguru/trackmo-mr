import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/common/textfield/apptextfield.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/support/controller/support_controller.dart';
import 'package:track_route_pro/utils/common_import.dart';

import '../../../constants/project_urls.dart';
import '../../splash_screen/controller/data_controller.dart';

class SupportView extends StatelessWidget {
  SupportView({super.key});
  final controller = Get.put(SupportController());
  final dataController =  Get.isRegistered<DataController>()
      ? Get.find<DataController>() // Find if already registered
      : Get.put(DataController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteOff,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(

          width: 100.w,
          decoration: BoxDecoration(color: AppColors.black),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8.h,
              ),
              Obx(()=>
                  Image.network(
                      width: 120,
                      height: 50,
                      "${ProjectUrls.imgBaseUrl}${dataController.settings.value.appLogo}",
                      errorBuilder: (context, error, stackTrace) =>
                          SvgPicture.asset(
                            Assets.images.svg.icIsolationMode,
                            color: AppColors.black,
                          )),
              ),
              Row(
                children: [
                  Text(
                    'Support',
                    style: AppTextStyles(context).display32W700.copyWith(
                          color: AppColors.whiteOff,
                        ),
                  ),
                  Spacer(),
                  InkWell(
                      onTap: () {
                        Get.back();
                        controller.isSucessSubmit.value = false;
                      },
                      child: SvgPicture.asset("assets/images/svg/close_icon.svg", ))
                ],
              ),
              SizedBox(
                height: 4.h,
              ),
            ],
          ).paddingSymmetric(horizontal: 6.w),
        ),
        Obx(
          () => controller.isSucessSubmit.value
              ? Container(
                  child: Column(
                    children: [
                      Text(
                        'Thank you for your submission!',
                        style: AppTextStyles(context)
                            .display32W700
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Text('We will contact you within 24 hours',
                          style: AppTextStyles(context).display24W400),
                    ],
                  ),
                ).paddingSymmetric(horizontal: 6.w, vertical: 4.h)
              : Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registered Email ID',
                          style: AppTextStyles(context)
                              .display12W400
                              .copyWith(color: AppColors.grayLight),
                        ),
                        Obx(
                          () => Text(
                            '${controller.userEmail.value}',
                            style: AppTextStyles(context)
                                .display14W600
                                .copyWith(color: AppColors.grayLight),
                          ),
                        ),
                        AppTextFormField(
                            color: AppColors.textfield,
                            controller: controller.deviceID,
                            suffixIcon: "assets/images/svg/paste_icon.svg",
                            onSuffixTap: () async {
                              ClipboardData data = await Clipboard.getData('text/plain') ?? ClipboardData(text: "");
                              controller.deviceID.text = data.text ?? "";
                            },
                            hintText: 'Device ID'),
                        SizedBox(
                          height: 1.h,
                        ),
                        AppTextFormField(
                            color: AppColors.textfield,
                            controller: controller.subject,
                            hintText: 'Subject'),
                        SizedBox(
                          height: 1.h,
                        ),
                        AppTextFormField(
                            maxLines: 10,
                            height: 25.h,
                            contentPadding: EdgeInsets.all(16),
                            color: AppColors.textfield,
                            controller: controller.description,
                            hintText: 'How can we assist you today?'),
                        SizedBox(
                          height: 2.h,
                        ),
                        InkWell(
                          onTap: () {
                            controller.submitSupportRequest();
                          },
                          child: Container(
                            height: 6.h,
                            child: Center(
                              child: Text(
                                'Submit',
                                style: AppTextStyles(context)
                                    .display18W500
                                    .copyWith(color: Color(0xffD9E821)),
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: AppColors.black,
                            ),
                          ).paddingOnly(bottom: 20),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 6.w, vertical: 2.h),
                  ),
                ),
        )
      ]),
    );
  }
}
