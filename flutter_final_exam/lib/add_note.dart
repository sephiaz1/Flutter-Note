import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_final_exam/style/app_style.dart';

class AddNoteScreen extends StatefulWidget {
  final Color selectedColor;

  AddNoteScreen({required this.selectedColor});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.selectedColor;
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final newNote = {
        'title': _titleController.text,
        'content': _contentController.text,
        'dateCreated': DateTime.now().toIso8601String(),
        'lastEdited': DateTime.now().toIso8601String(),
        'color': _currentColor.value,
      };

      var noteBox = Hive.box('noteBox');
      noteBox.add(newNote);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note'),
        backgroundColor: _currentColor,
      ),
      body: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: _currentColor,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Note Title',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the content';
                          }
                          return null;
                        },
                        maxLines: 10,
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Wrap(
                  spacing: 8.0,
                  children: AppStyle.cardsColor.map((color) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _currentColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentColor == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        child: Icon(Icons.save),
        backgroundColor: _currentColor,
      ),
    );
  }
}
