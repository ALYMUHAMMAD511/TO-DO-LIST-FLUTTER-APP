import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit <AppStates>
{
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  late Database database;
  List <Map> newTasks = [];
  List <Map> doneTasks = [];
  List <Map> archivedTasks = [];
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

  void ChangeIndex(int index)
  {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDatabase()   // chelna el async wel await w defna then() fel akher 3chan ab2a damen enu khallas
  {
    openDatabase(
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
        database.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)').then((value)
        {
          print('Table has been Created');
        }).catchError((error)
        {
          print('Error when Creating Table');
        });
      },
      onOpen: (database)
      {
        getDataFromDatabase(database);
        print('Database has been Opened');
      },
    ).then((value)
    {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

   insertToDatabase(
      {
        required String title,
        required String time,
        required String date,
      })
  async {
    await database.transaction((txn)
    {
      return txn.rawInsert(
          'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value)
      {
        print('$value Inserted Successfully');
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
      }).catchError((error)
      {
        print('Error when Inserting new Record ${error.toString()}');
      });
    });
  }

  void getDataFromDatabase(database)
  {
    newTasks = []; // 3chan my3melch add 3al adeem fa bnsafaru
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatabaseLoadingState());
    database.rawQuery('SELECT * FROM tasks').then((value)
    {
      value.forEach((element)
      {
        if (element['status'] == 'new')
          newTasks.add(element);
        else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });
      emit(AppGetDatabaseState());
    });
  }

  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
})
  {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }

  void updateDatabase({
    required String status,
    required int id,
  }) async
  {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status' , id],
    ).then((value)
    {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteDatabase({required int id})
  {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id])
        .then((value)
    {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }
}