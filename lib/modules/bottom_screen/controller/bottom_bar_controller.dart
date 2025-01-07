import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_route_pro/modules/alert_screen/view/alert_view.dart';
import 'package:track_route_pro/modules/profile/controller/profile_controller.dart';
import 'package:track_route_pro/modules/profile/view/profile_view.dart';
import 'package:track_route_pro/modules/settig_screen/view/setting_view.dart';
import 'package:track_route_pro/modules/track_route_screen/view/track_route_view.dart';
import 'package:track_route_pro/modules/vehicales/view/vehicales_view.dart';

import '../../track_route_screen/controller/track_route_controller.dart';
import '../../vehicales/controller/vehicales_controller.dart';

class BottomBarController extends GetxController {
  // Observable variable to hold the selected index
  var selectedIndex = 2.obs;
  var previousIndex = 2.obs;
  // final PageController pageController = PageController();
  // void animateToPage(int page) {
  //   pageController.animateToPage(
  //     page,
  //     duration: const Duration(milliseconds: 300),
  //     curve: Curves.easeInOut,
  //   );
  //   updateIndex(page);
  // }
  void updateIndex(int index) {
    if(index==2){
      var controller = Get.put(TrackRouteController());
      controller.isExpanded.value = false;
      controller.isedit.value = false;
      controller.stackIndex.value = 0;
      controller.isFilterSelected.value = false;
      controller.isFilterSelectedindex.value = -1;
      controller.polylines.value = [];
      controller.polylines.value = [];
      controller.isShowvehicleDetail.value = false;
      controller.selectedVehicleIndex.value = -1;
      controller.showAllVehicles();
      controller.polylines.value = [];
      if(controller.vehicleList.value.data?.isEmpty ?? false){
        controller.markers.value = [];
        controller.devicesByOwnerID(true);
      }

    }
    if(index==4) {
      var controller = Get.put(ProfileController());
      controller.selectedVehicleIndex.value = -1;
      controller.isReNewSub.value = false;
    }
    previousIndex.value = selectedIndex.value;
    selectedIndex.value = index;

    // You can also add logic here to navigate to different screens based on the index
    // For example:
    // if (index == 0) {
    //   Get.to(SomeOtherScreen());
    // }
  }

  List<Widget> screens = [
    SettingView(),
    AlertView(),
    TrackRouteView(),
    VehicalesView(),
    ProfileView()
  ];
}
