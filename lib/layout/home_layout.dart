import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/components/components.dart';

// 1) Create Database
// 2) Create Tables
// 3) Open Database
// 4) Insert to Database
// 5) Get from Database
// 6) Update in Database
// 7) Delete from Database

class HomeLayout extends StatefulWidget {
  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout>
{
  int currentIndex = 0;
  List<Widget> screens =
  [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles =
  [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];
  late Database database;
  var scaffoldkey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  void initState()
  {
    super.initState();
    createDatabase();
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        title: Text(
          titles[currentIndex],
        ),
      ),
      body: screens[currentIndex],
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (isBottomSheetShown) {
              if (formKey.currentState!.validate())
              {
                insertToDatabase(
                    title: titleController.text,
                    time: timeController.text,
                    date: dateController.text
                ).then((value)
                {
                  Navigator.pop(context);
                  isBottomSheetShown = false;
                    setState(() {
                      fabIcon = Icons.edit;
                    });
                });
                }
              }
              else {
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
                              DefaultFormField(
                                controller: titleController,
                                type: TextInputType.text,
                                validate: (String value) {
                                  if (value.isEmpty) {
                                    return 'Title must not be Empty';
                                  }
                                  return null;
                                  },
                                label: 'Task Title',
                                prefix: Icons.title,
                                onTap: () {
                                  print('Title Tapped');
                                  },
                              ),
                              SizedBox(
                                height: 18.0,
                              ),
                              DefaultFormField(
                                controller: timeController,
                                type: TextInputType.datetime,
                                validate: (String value) {
                                  if (value.isEmpty) {
                                    return 'Time must not be Empty';
                                  }
                                  return null;
                                },
                                label: 'Task Time',
                                prefix: Icons.watch_later_outlined,
                                onTap: () {
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((value) {
                                    timeController.text = value!.format(context).toString();
                                    print(value.format(context));
                                  });
                                },
                              ),
                              SizedBox(
                                height: 18.0,
                              ),
                              DefaultFormField(
                                controller: dateController,
                                type: TextInputType.datetime,
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2023-05-03'),
                                  ).then((value) {
                                    dateController.text = DateFormat.yMMMd().format(value!);
                                    print(dateController.text);
                                  });
                                },
                                validate: (String value) {
                                  if (value.isEmpty) {
                                    return 'Date must not be Empty';
                                  }

                                  return null;
                                },
                                label: 'Task Date',
                                prefix: Icons.calendar_today,
                              ),
                            ],
                          ),
                        ),
                      ),
                  elevation: 25.0,
                );
                isBottomSheetShown = true;
                setState(() {
                  fabIcon = Icons.add;
                });
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
              fabIcon,
            ),
          ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index)
        {
          setState(()
          {
            currentIndex = index;
          });
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
  }
  // Future <String> getName() async // Future <>: 3chan el method deh lesa hategy
  // {
  //   return 'Aly Muhammad';
  // }

  void createDatabase() async         // 3chan openDatabase() future
  {
    database = await openDatabase(
      'todo.db',
      version: 1,    // b-update el version lma aghyar structure el database
      onCreate: (database, version) async  // el object da hayetmely abll ely fu2
      {
        print('Database has been Created');
        // In the () of the create table we put our table columns which are:
        // int id (PRIMARY KEY 3chan huwa auto generated) (int = INTEGER in sql)
        // String title (String = TEXT in sql)
        // String date
        // String time
        // String status
        await database.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)').then((value)
        {
          print('Table has been Created');
        }).catchError((error)
        {
          print('Error when Creating Table');
        });
          // 3chan bt-return future void

      },
      onOpen: (database)
      {
        print('Database has been Opened');
      },
    );
  }

  Future insertToDatabase(
    {
    required String title,
    required String time,
    required String date,
    })
  async {
    return await database.transaction((txn)
    {
      txn.rawInsert('INSERT INTO tasks(title, date, time, status) VALUES("$title", "$time", "$date", "new")')
          .then((value)
      {
        print('$value Inserted Successfully');
      }).catchError((error)
      {
        print('Error when Inserting new Record ${error.toString()}');
      });
      return null;
    });
  }
}
