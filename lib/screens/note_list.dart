import 'package:flutter/material.dart';
import 'package:database_flutter_app/models/note.dart';
import 'package:database_flutter_app/screens/note_detail.dart';
import 'package:database_flutter_app/utils/database_helper.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  late DatabaseHelper _databaseHelper;
  late List<Note> _noteList = [];
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (_noteList.isEmpty) {
      _databaseHelper = DatabaseHelper();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("FAB Pressed");
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
        child: Icon(Icons.add),
        tooltip: "Add New Note",
      ),
    );
  }

  Widget getNoteListView() {
    TextStyle style = Theme.of(context).textTheme.titleMedium!;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(_noteList[position].priority),
              child: getPriorityIcon(_noteList[position].priority),
            ),
            title: Text(_noteList[position].title, style: style),
            subtitle: Text(_noteList[position].date),
            trailing: GestureDetector(
              child: Icon(Icons.delete, color: Colors.grey),
              onTap: () {
                _delete(context, _noteList[position]);
              },
            ),
            onTap: () {
              debugPrint("ListTile item tapped");
              navigateToDetail(_noteList[position], 'Edit Note');
            },
          ),
        );
      },
    );
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));
    if (result == true) {
      updateListView();
    }
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
      case 2:
        return Icon(Icons.arrow_right);
      default:
        return Icon(Icons.arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await _databaseHelper.delete(note.id!);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void updateListView() async {
    List<Note> noteList = await _databaseHelper.getNotesList();
    setState(() {
      _noteList = noteList;
      count = noteList.length;
    });
  }
}