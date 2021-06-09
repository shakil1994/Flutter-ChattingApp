import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showOnlySnackBar (BuildContext context, String message){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('$message'),
    action: SnackBarAction(label: 'View Bag', onPressed: () => Navigator.of(context).pop(),)
  ));
}