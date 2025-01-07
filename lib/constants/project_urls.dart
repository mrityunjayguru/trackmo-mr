class ProjectUrls {
  //static const String userAccessTokenKey = 'USER_ACCESS_TOKEN';

  // static const String baseUrl = "http://3.108.26.115:3100";
  static const String baseUrl = "https://app.trackroutepro.com";
  static const String imgBaseUrl = "https://urmedixx-mfile.s3.ap-south-1.amazonaws.com/";
  static const String login = "/Auth/login";
  static const String forgotPassword = "/Auth/send_otp";
  static const String verifyOTP = "/Auth/verify";
  static const String resetPassword = "/Auth/reset_password";
  static const String splashAdd = "/splashAd/get";
  static const String sendTokenData = "/Auth/updateUser";
  static const String settingAdd = "/setting/get";
  static const String aboutUs = "/about/get";
  static const String support = "/suport/create";
  static const String devicesByOwnerID = "/trackVehicle/getByVehicleID";
  static const String editdevicesByOwnerID = "/vehicle/update";
  static const String vehicleType = "/vehicleType/get";
  static const String renewSubscription = "/vehicle/renewDevice";
  static const String manageSettings = "/managesetting/get";
  static const String faqTopic = "/FaQtopic/get";
  static const String faqList = "/FaQlist/get";
  static const String announcements = "/notification/notificationByID";
  // static const String alerts = "/trackVehicle/Alerts";
  static const String alerts = "/notification/alerts";
  static const String relayCheckStatus = "/relay/checkStatus";
  static const String relayStartEngine = "/relay/engineResume";
  static const String relayStopEngine = "/relay/engineStop";
  static const String routeHistory = "/trackVehicle/rootHistory";
  static const String privacyPolicy = "/privacyPolicy/get";
}
