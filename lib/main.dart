import 'package:asmara_dine/core/splash_screen.dart';
import 'package:asmara_dine/features/menu/logic/event_bloc.dart';
import 'package:asmara_dine/features/menu/logic/event_menu.dart';
import 'package:asmara_dine/features/tables/logic/merge_table_bloc.dart';
import 'package:asmara_dine/features/tables/logic/table_bloc.dart';
import 'package:asmara_dine/features/tables/presentation/table_screen.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TableBloc>(
          create: (_) => TableBloc(),  // 👈 TableBloc initialized once for whole app
        ),
         BlocProvider<MergedTableBloc>(
          create: (_) => MergedTableBloc(),  // 👈 TableBloc initialized once for whole app
        ),
       
        // You can add more blocs here in future like:
        // BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Restaurant Waiter App',
        theme: ThemeData(primarySwatch: Colors.teal),
        home: const SplashScreen(), // 👈 Your first screen
      ),
    );
  }
}
