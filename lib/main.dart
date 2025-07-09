import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_dashboard/incharge_dashboard_screen.dart';
import 'package:rajfed_qr/Screens/Operator/OperatorDashboard/operator_dashboard.dart';
import 'package:rajfed_qr/Screens/Warehouse/warehouse_home.dart';
import 'Screens/login/login_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  Widget initialRoute = LoginPage();
  WidgetsFlutterBinding.ensureInitialized();
  var token = await SharedPreferenceHelper.instance.getToken();
  var userType = await SharedPreferenceHelper.instance.getUserType();
  print("Token: $token");
  print("UserType: $userType");
  if (userType == 10) {
    initialRoute = OperatorDashboard();
  } else if (userType == 2) {
    initialRoute = InchargeDashboard();
  } else if (userType == 13) {
    initialRoute = WarehouseHome();
  }
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  const MyApp({this.initialRoute, super.key});
  final Widget? initialRoute;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rajfed Qr',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primaryColor: Color(0xFFB7D77A), // Main color
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFB7D77A),
          primary: Color(0xFFB7D77A),
          secondary: Colors.green[700]!,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFFB7D77A),
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 10,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.green[400],
          textTheme: ButtonTextTheme.primary,
        ),
        useMaterial3: true,
      ),
      home: initialRoute,
    );
  }
}
