import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultFormField({
  required TextEditingController controller,
  TextInputType? type,
  bool isPassword = false,
  VoidCallback? onTap,
  final FormFieldValidator<String>? validate,
  required String labelText,
  required IconData? prefixIcon,
  IconData? suffixIcon,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      onTap: onTap,
      validator: validate,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: Icon(suffixIcon),
      ),
    );

Widget buildTaskItem(Map model, context) =>
    Dismissible(
  key: Key(model['id'].toString()),
  onDismissed: (direction)
  {
    AppCubit.get(context).deleteDatabase(id: model['id']);
  },
  child: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      children: 
      [
        CircleAvatar(
          radius: 40.0,
          child: Text(
              '${model['time']}'
          ),
        ),
        SizedBox(
          width: 18.0,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
            [
              Text(
                '${model['title']}',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${model['date']}',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 18.0,
        ),
        IconButton(
          onPressed: ()
          {
            AppCubit.get(context).updateDatabase(
                status: 'done',
                id: model['id'],
            );
          },
          icon: Icon(
            Icons.check_box,
            color: CupertinoColors.activeGreen,
          )
      ),
        IconButton(
            onPressed: ()
            {
              AppCubit.get(context).updateDatabase(
                  status: 'archive',
                  id: model['id'],
              );
            },
            icon: Icon(
              Icons.archive,
              color: Colors.black45,
            ),
        ),
      ],
    ),
  ),
);

Widget tasksBuilder({required List <Map> tasks}) =>
    ConditionalBuilder(
  condition: tasks.length > 0,
  builder: (context) => ListView.separated(
      itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 20.0),
        child: Container(
          width: double.infinity,
          height: 1.0,
          color: Colors.grey[300],
        ),
      ),
      itemCount: tasks.length),
  fallback: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
      [
        Icon(
          Icons.menu,
          size: 100.0,
          color: Colors.grey,
        ),
        Text(
          'No Tasks yet, Please, Add some Tasks',
          style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey
          ),
        ),
      ],
    ),
  ),
);