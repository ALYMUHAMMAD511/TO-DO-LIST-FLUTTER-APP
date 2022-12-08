import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';
import '../shared/components/constants.dart';
// 1) Create Database
// 2) Create Tables
// 3) Open Database
// 4) Insert to Database
// 5) Get from Database
// 6) Update in Database
// 7) Delete from Database
class HomeLayout extends StatelessWidget
{
  var scaffoldkey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),  //.. 3chan a2dar a-access 3ala ely guwah ka2enu variable (y3ny ka2eny 3amalt variable.)
      child: BlocConsumer <AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state)
        {
          if (state is AppInsertDatabaseState)
          {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state)
        {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldkey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate())
                  {
                    cubit.insertToDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text,
                    );
                  }
                }
                else
                {
                  scaffoldkey.currentState?.showBottomSheet(
                        (context) =>
                        Container(
                          padding: EdgeInsets.all(20.0),
                          color: Colors.white,
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children:
                              [
                                defaultFormField(
                                  controller: titleController,
                                  labelText: "Task Title",
                                  prefixIcon: Icons.title,
                                  onTap: () {},
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return ('Task Title cant be empty');
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 18.0,
                                ),
                                defaultFormField(
                                  controller: timeController,
                                  labelText: "Task Time",
                                  prefixIcon: Icons.watch_later_outlined,
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      builder: (context, child) {
                                        return Theme(
                                            data: ThemeData.dark(),
                                            child: child!);
                                      },
                                    ).then((value) {
                                      timeController.text =
                                          value!.format(context);
                                    });
                                  },
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return ('Task Time cant be empty');
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 18.0,
                                ),
                                defaultFormField(
                                  controller: dateController,
                                  labelText: "Task Date",
                                  prefixIcon: Icons.calendar_month_outlined,
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2023-06-31'),
                                      builder: (context, child) {
                                        return Theme(
                                            data: ThemeData.dark(),
                                            child: child!);
                                      },
                                    ).then((value) {
                                      dateController.text = DateFormat.yMMMd().format(value!);
                                      print(DateFormat.yMMMd().format(value));
                                    });
                                  },
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return ('Task Date cant be empty');
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    elevation: 25.0,
                  ).closed.then((value)
                  {
                    cubit.changeBottomSheetState(
                        isShow: false,
                        icon: Icons.edit
                    );
                  });
                  cubit.changeBottomSheetState(
                      isShow: true,
                      icon: Icons.add
                  );
                }
                // try
                // {
                //   var name = await getName();  // await: astana 3al method deh chwya asebha tru7 w tegy y3ny astanaha tekhlas chughlaha
                //   print(name);
                //   print('Ahmad');
                //   throw('some error !!!!!!');  // throw: bt3mel error
                // }
                // catch (error)
                // {
                //   print('error ${error.toString()}');
                // }
                // getName().then((value)  // then bt2um bel async wel await w kull 7agga w btdmanly el tarteb ely na 3ayzu
                // {
                //   print(value);
                //   print('Ahmad');
                //   throw('some error !!!!!!');     // throw: bt3mel error
                // }).catchError((error){
                //   print('error is ${error.toString()}');
                // });
              },
              child:
              Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index)
              {
                AppCubit.get(context).ChangeIndex(index);
              },
              items:
              [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle_outline,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                  ),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  // Future <String> getName() async // Future <>: 3chan el method deh lesa hategy
  // {
  //   return 'Aly Muhammad';
  // }
}
