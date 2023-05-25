import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import '../localization/set_localization.dart';
import 'firebase_service.dart';

GetIt locator = GetIt.instance;

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
  new GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  void setupLocator() {
    locator.registerLazySingleton(() => NavigationService());
    locator.registerLazySingleton(() => SetLocalization.instance!);



  }
}