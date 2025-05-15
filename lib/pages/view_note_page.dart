import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../model/note.dart';
import 'edit_note_page.dart';

class ViewNotePage extends StatelessWidget {
  final Note note;

  ViewNotePage({required this.note});

  @override
  Widget build(BuildContext context) {
    String plainText = _getPlainText(note.content);

    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedNote = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditNotePage(note: note)),
              );
              Navigator.pop(context, updatedNote);
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
        
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  plainText,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _getPlainText(String deltaJson) {
    if (deltaJson.isEmpty) return '';
    try {
      final doc = quill.Document.fromJson(jsonDecode(deltaJson));
      return doc.toPlainText();
    } catch (e) {
     
      return deltaJson;
    }
  }
}

