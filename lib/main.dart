import 'package:flutter/material.dart';
import 'User_Pages/logo_page.dart';
import 'User_Pages/signup_page.dart';
import 'User_Pages/home_page.dart';
import 'User_Pages/product_list_page.dart';
import 'User_Pages/product_page.dart';
import 'User_Pages/cart_page.dart';
import 'User_Pages/checkout_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CheckoutPage(),
    );
  }
}
