import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:learn_hiragana_app/bloc/bottom_nav_cubit.dart';
import 'package:learn_hiragana_app/components/main_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HiraSpark',
      theme: ThemeData(
        scaffoldBackgroundColor: HexColor("#0a0908"),
        useMaterial3: true,
      ),
      home:  BlocProvider(
        create: (context) => BottomNavCubit(),
        child: const MainWrapper(),
    ));
  }
}

