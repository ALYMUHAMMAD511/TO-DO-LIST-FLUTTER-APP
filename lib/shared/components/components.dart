import 'package:flutter/material.dart';

Widget DefaultFormField(
    {
      required TextEditingController controller,
      required TextInputType type,
      required Function validate,
      required String label,
      required IconData prefix,
      IconData? suffix,
      Function? onSubmit,
      Function? onChange,
          Function? onTap,
      VoidCallback? suffixPressed,
      bool IsPassword = false,
      bool isClickable = true,
    }) =>
    TextFormField(
decoration: InputDecoration(
labelText: label,
border: OutlineInputBorder(),
prefixIcon: Icon(prefix),
suffixIcon: suffix != null ? IconButton(
icon: Icon(suffix),
onPressed: suffixPressed!= null ? suffixPressed :null,) : null,
),
validator: (value)
{
return validate(value);
},
keyboardType: type,
obscureText: IsPassword,
      enabled: isClickable,
onFieldSubmitted: onSubmit != null ? onSubmit() : null, //do null checking
onChanged: onChange != null ? onChange() : null, //do null checking
onTap: onTap!(),
controller: controller,
    );