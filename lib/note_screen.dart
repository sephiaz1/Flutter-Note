import 'package:flutter/material.dart';
import 'package:flutter_final_exam/add_note.dart';
import 'package:flutter_final_exam/edit_note.dart';
import 'package:flutter_final_exam/style/app_style.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class NoteScreen extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  Box? _noteBox;

  @override
  void initState() {
    super.initState();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    _noteBox = await Hive.openBox('noteBox');
    setState(() {});
  }

  void _deleteNote(int index) {
    _noteBox!.deleteAt(index);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Note deleted successfully')),
    );
  }

  void _updateNote() {
    setState(() {});
  }

  String _formatDateTime(DateTime dateTime) {
    final monthNames = [
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

    String period = dateTime.hour >= 12 ? 'PM' : 'AM';
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    return '${dateTime.day} ${monthNames[dateTime.month - 1]} ${dateTime.year} ${hour}:${dateTime.minute} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.mainColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Available notes",
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            child: _noteBox == null
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _noteBox == null ? 0 : _noteBox!.length,
                    itemBuilder: (context, index) {
                      var note = _noteBox!.getAt(index);
                      Color noteColor = note['color'] != null
                          ? Color(note['color'])
                          : AppStyle
                              .cardsColor[index % AppStyle.cardsColor.length];

                      return InkWell(
                        onTap: () {
                          if (note != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditNote(
                                  noteKey: index,
                                  selectedColor: noteColor,
                                  updateNote: _updateNote,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to load the note')),
                            );
                          }
                        },
                        child: SizedBox(
                          height: 200,
                          child: Card(
                            color: noteColor,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note['title'] ?? 'No Title',
                                        style: AppStyle.mainTitle,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        '${_formatDateTime(DateTime.parse(note['dateCreated']))}',
                                        style: AppStyle.dateContent,
                                      ),
                                      Text(
                                        'Edited: ${note['lastEdited'] != null ? _formatDateTime(DateTime.parse(note['lastEdited'])) : 'Never'}',
                                        style: AppStyle.dateContent,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Flexible(
                                        child: Text(
                                          note['content'] ?? 'No Content',
                                          style: AppStyle.mainContent,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 4.0,
                                  right: 4.0,
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteNote(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFFD700),
        onPressed: () {
          Color selectedColor = AppStyle
              .cardsColor[_noteBox!.length % AppStyle.cardsColor.length];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(selectedColor: selectedColor),
            ),
          ).then((value) => setState(() {}));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
