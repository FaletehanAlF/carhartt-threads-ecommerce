import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CarharttApp(),
    ),
  );
}

class CarharttApp extends StatelessWidget {
  const CarharttApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Carhartt Shop',
      routerConfig: appRouter,
    );
  }
}