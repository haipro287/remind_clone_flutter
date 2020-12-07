class Endpoints {
  Endpoints._();

  static const String host = "http://192.168.1.35:3000";

  // base url
  static const String baseUrl = "$host/api";

  // receiveTimeout
  static const int receiveTimeout = 5000;

  // connectTimeout
  static const int connectionTimeout = 3000;

  static const String loginAPI = baseUrl + "/user/auth/login";

  static const String getUserClassroomsAPI = baseUrl + "/classroom/my-class";
}
