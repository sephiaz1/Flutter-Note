import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_final_exam/style/app_style.dart';

class NoteCard extends StatelessWidget {
  final Function()? onTap;
  final int noteId;

  NoteCard({
    required this.onTap,
    required this.noteId,
  });

  @override
  Widget build(BuildContext context) {
    Box noteBox = Hive.box('noteBox');
    var note = noteBox.get(noteId);

    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppStyle.cardsColor[note['colorIndex']],
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
      ),
    );
  }
}
