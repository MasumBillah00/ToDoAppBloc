import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapptask/bloc/login/login_bloc.dart';
import 'package:todoapptask/repository/todo_repository.dart';
import 'package:todoapptask/view/login_screen/login_screen.dart';
import 'bloc/todoappbloc/todoapp_bloc.dart';
import 'database_helper/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final databaseHelper = TodoDatabaseHelper();

  // Insert the default user if it doesn't exist
  const defaultEmail = 'm.billahkst@gmail.com';
  const defaultPassword = '12345';
  final existingUser = await databaseHelper.getUser(defaultEmail, defaultPassword);
  if (existingUser == null) {
    await databaseHelper.insertUser(defaultEmail, defaultPassword);
  }

  runApp(MyApp(databaseHelper));
}

class MyApp extends StatelessWidget {
  final TodoDatabaseHelper databaseHelper;

  const MyApp(this.databaseHelper, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LoginBloc(databaseHelper),
        ),
        BlocProvider(
          create: (_) => ToDoAppBloc(ToDoAppRepository(databaseHelper)),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: const NewLoginScreen(),
      ),
    );
  }
}
