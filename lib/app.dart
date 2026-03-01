import 'package:flutter/material.dart';
import 'core/router.dart';

class DentalApp extends StatelessWidget {
  const DentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: "Dental App",
      theme: ThemeData(primarySwatch: Colors.teal),
    );
  }
}
