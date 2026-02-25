import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_dashboard/incharge_dashboard_screen.dart';
import 'package:rajfed_qr/Screens/OpenSource/farmer_desk_screen/farmer_desk_screen.dart';
import 'package:rajfed_qr/Screens/Operator/OperatorDashboard/operator_dashboard.dart';
import 'package:rajfed_qr/Screens/Warehouse/warehouse_dashboard.dart';
import 'package:upgrader/upgrader.dart';
import 'Screens/Admin/admin_home_screen.dart';
import 'package:rajfed_qr/Screens/Registration/screens/information_page.dart';
import 'package:rajfed_qr/Screens/Registration/screens/jan_aadhar_page.dart';
import 'package:rajfed_qr/Screens/Registration/screens/farmer_detail_page.dart';
import 'package:rajfed_qr/Screens/Registration/screens/bataidar_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Widget initialRoute = FarmerDeskScreen();

  // Ensure token is loaded (value not used here). If you plan to use it later, restore assignment.
  await SharedPreferenceHelper.instance.getToken();
  var userType = await SharedPreferenceHelper.instance.getUserType();

  if (userType == 10) {
    initialRoute = OperatorDashboard();
  } else if (userType == 2) {
    initialRoute = InchargeDashboard();
  } else if (userType == 13) {
    initialRoute = WareHouseDashboard();
  } else if (userType == 7) {
    initialRoute = AdminHomeScreen();
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final Widget? initialRoute;

  const MyApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    // Seed color used throughout the theme
    const seedColor = Color(0xFFB7D77A);

    return MaterialApp(
      title: 'Rajfed Kishan',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        primaryColor: seedColor,
        // App bar styling
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB7D77A),
          foregroundColor: Colors.black,
          centerTitle: true,
          elevation: 0,
          surfaceTintColor: Colors.transparent, // ⭐ IMPORTANT
        ),
        // Unified input decoration theme so all textfields/dropdowns align visually
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide(color: seedColor, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ),
      // Register the information page route so it can be opened by name
      routes: {
        InformationPage.routeName: (ctx) => const InformationPage(),
        JanAadharPage.routeName: (ctx) => const JanAadharPage(),
        FarmerDetailPage.routeName: (ctx) => const FarmerDetailPage(),
        BataidarPage.routeName: (ctx) => const BataidarPage(),
      },
      home: UpgradeAlert(
        upgrader: Upgrader(durationUntilAlertAgain: Duration.zero),
        child: initialRoute!,
      ),
    );
  }
}
