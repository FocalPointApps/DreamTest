import 'package:flutter_smartlook/flutter_smartlook.dart';

class CustomIntegrationListener implements IntegrationListener {
  @override
  void onSessionReady(String? dashboardSessionUrl) {
    print('---------');
    print('DashboardUrl:');
    print(dashboardSessionUrl);
  }

  @override
  void onVisitorReady(String? dashboardVisitorUrl) {
    print('---------');
    print('DashboardVisitorUrl:');
    print(dashboardVisitorUrl);
  }
}