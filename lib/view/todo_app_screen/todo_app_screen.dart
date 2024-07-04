import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapptask/view/login_screen/login_screen.dart';
import 'package:todoapptask/view/todo_app_screen/complete_task_screen.dart';
import 'package:todoapptask/view/todo_app_screen/deleted_item_screen.dart';
import 'package:todoapptask/view/todo_app_screen/favoruite_item_screen.dart';
import '../../bloc/todoappbloc/todoapp_bloc.dart';
import '../../bloc/todoappbloc/todoapp_event.dart';
import '../../bloc/todoappbloc/todoapp_state.dart';
import '../todo_app_widget/button_widget.dart';
import '../todo_app_widget/drawer_widget.dart';

class ToDoAppScreen extends StatefulWidget {
  const ToDoAppScreen({super.key});

  @override
  State<ToDoAppScreen> createState() => _ToDoAppScreenState();
}

class _ToDoAppScreenState extends State<ToDoAppScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ToDoAppBloc>().add(FetchTaskList());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 1:
        return  FavouriteScreen(onItemTapped:_onItemTapped,);
      case 2:
        return  CompleteTasksScreen(onItemTapped:_onItemTapped);
      case 3:
        return  DeletedItemScreen(onItemTapped:_onItemTapped);
      case 4:
        return const NewLoginScreen();
      default:
        return BlocBuilder<ToDoAppBloc, TodoappState>(
          builder: (context, state) {
            switch (state.listStatus) {
              case ListStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case ListStatus.failure:
                return const Center(child: Text('Something went wrong'));
              case ListStatus.success:
                return ListView.builder(
                  itemCount: state.taskItemList.length,
                  itemBuilder: (context, index) {
                    final item = state.taskItemList[index];
                    final isSelected = state.selectedList.contains(item);

                    return Card(
                      color: Colors.grey[900], // Dark background color
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            if (value == true) {
                              context.read<ToDoAppBloc>().add(SelectItem(item: item));
                            } else {
                              context.read<ToDoAppBloc>().add(UnSelectItem(item: item));
                            }
                          },
                        ),
                        title: Text(
                          item.value,
                          style: TextStyle(
                            color: isSelected ? Colors.red : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                context.read<ToDoAppBloc>().add(FavouriteItem(item: item));
                              },
                              icon: Icon(
                                item.isFavourite ? Icons.favorite : Icons.favorite_outline,
                                color: Colors.amberAccent,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 15),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 30,
                              ),
                              onPressed: () {
                                _showHideConfirmationDialog(context, item.id, item.value);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
        child: Scaffold(
          appBar: _selectedIndex == 0
              ? AppBar(
                  title: const Text(
                    'TODO APP',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                  ),
                  centerTitle: true,
                )
              : null,
          drawer:  ToDo_Drawer(onItemTapped: _onItemTapped),
          body: _getBody(),
          floatingActionButton: const FloatingActionButtonWidget(),

          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.amber[200], size: 35),
                activeIcon: Icon(Icons.home, color: Colors.amber[600], size: 35),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite, color: Colors.amber[200], size: 35),
                activeIcon: Icon(Icons.favorite, color: Colors.amber[600], size: 35),
                label: 'Favourite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_box, color: Colors.amber[200], size: 35),
                activeIcon: Icon(Icons.check_box, color: Colors.amber[600], size: 35),
                label: 'Completed Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.logout, color: Colors.amber[200], size: 35),
                activeIcon: Icon(Icons.logout, color: Colors.amber[600], size: 35),
                label: 'Logout',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.amber[800],
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  void _showHideConfirmationDialog(BuildContext context, String taskId, String taskValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<ToDoAppBloc>().add(HideItem(id: taskId, value: taskValue));
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
