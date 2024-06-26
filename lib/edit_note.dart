import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_final_exam/style/app_style.dart';

class EditNote extends StatefulWidget {
  final int noteKey;
  final Color selectedColor;
  final Function() updateNote;

  EditNote({
    required this.noteKey,
    required this.selectedColor,
    required this.updateNote,
  });

  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late Box _noteBox;
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _initializeBox();
    _currentColor = widget.selectedColor;
  }

  Future<void> _initializeBox() async {
    _noteBox = await Hive.openBox('noteBox');
    var note = _noteBox.getAt(widget.noteKey);
    if (note != null) {
      _titleController.text = note['title'] ?? '';
      _contentController.text = note['content'] ?? '';
    }
    setState(() {});
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      var updatedNote = {
        'title': _titleController.text,
        'content': _contentController.text,
        'dateCreated': _noteBox.getAt(widget.noteKey)['dateCreated'],
        'lastEdited': DateTime.now().toIso8601String(),
        'color': _currentColor.value,
      };
      _noteBox.putAt(widget.noteKey, updatedNote);
      widget.updateNote();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note updated successfully')),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
        backgroundColor: _currentColor,
      ),
      body: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: _currentColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
