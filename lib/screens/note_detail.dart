import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:database_flutter_app/utils/database_helper.dart';
import 'package:database_flutter_app/models/note.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  late String appBarTitle;
  late Note note;
  late DatabaseHelper databaseHelper;

  var _formKey = GlobalKey<FormState>();

  var _priorities = ["High", "Low"];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    appBarTitle = widget.appBarTitle;
    note = widget.note;
    databaseHelper = DatabaseHelper();

    // Setting the text on the TextFields.
    titleController.text = note.title;
    descriptionController.text = note.description;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.titleLarge!;

    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: DropdownButton<String>(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    onChanged: (String? newItemSelected) {
                      if (newItemSelected != null) {
                        updatePriorityAsInt(newItemSelected);
                      }
                    },
                    style: textStyle,
                    value: updatePriorityAsString(note.priority),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: TextFormField(
                    style: textStyle,
                    controller: titleController,
                    validator: (String? userInput) {
                      if (userInput == null || userInput.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                    onFieldSubmitted: (String value) {
                      updateTitle();
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      labelText: "Title",
                      labelStyle: textStyle,
                      hintText: "Enter note title",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: TextFormField(
                    style: textStyle,
                    controller: descriptionController,
                    validator: (String? userInput) {
                      if (userInput == null || userInput.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                    onFieldSubmitted: (String value) {
                      updateDescription();
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      labelText: "Description",
                      labelStyle: textStyle,
                      hintText: "Enter note description",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                            // splashColor: Colors.yellow,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              save();
                            }
                          },
                          child: Text("Save"),
                        ),
                      ),
                      SizedBox(width: 5.0),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                            
                          ),
                          onPressed: () {
                            debugPrint("Delete Button pressed");
                            delete();
                          },
                          child: Text("Delete"),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true); // passing the true value to noteList screen.
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
      default:
        note.priority = 1; // Provide a default case or ensure assignment
    }
  }

  String? updatePriorityAsString(int value) {
    if (value == null) return null; // Handle null case if necessary
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
      default:
        priority = _priorities[0]; // Provide a default case or ensure assignment
    }
    return priority;
  }

  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDescription() {
    note.description = descriptionController.text;
  }

  void save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if (note.id != null) {
      result = await databaseHelper.update(note);
    } else {
      result = await databaseHelper.insert(note);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Note Saved successfully');
    } else {
      _showAlertDialog('Status', 'Error saving note, Please try again later');
    }
  }

  void delete() async {
    moveToLastScreen();
    if (note.id == null) {
      _showAlertDialog('Status', 'No note was deleted');
      return;
    } else {
      int result = await databaseHelper.delete(note.id!);
      if (result != 0) {
        _showAlertDialog('Status', 'Note Deleted Successfully');
      } else {
        _showAlertDialog('Status',
            'Error occurred while deleting note, please try again later');
      }
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (context) => alertDialog);
  }
}