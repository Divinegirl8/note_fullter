import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import '../model/note.dart';

class EditNotePage extends StatefulWidget {
  final Note? note;

  EditNotePage({this.note});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController titleController;
  late quill.QuillController quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');

    if (widget.note != null && widget.note!.content.isNotEmpty) {
      quillController = quill.QuillController(
        document: quill.Document.fromJson(jsonDecode(widget.note!.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      quillController = quill.QuillController.basic();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    _editorFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

Widget buildCustomToolbar() {
  bool isAttributeActive(quill.Attribute attribute) {
    final attrs = quillController.getSelectionStyle().attributes;
    if (attribute.key == 'align') {
      return attrs['align']?.value == attribute.value;
    }
    return attrs.containsKey(attribute.key);
  }

  Widget toolbarButton(IconData icon, String tooltip, quill.Attribute attr) {
    final active = isAttributeActive(attr);
    return GestureDetector(
      onTap: () {
        quillController.formatSelection(
          active ? quill.Attribute.clone(attr, null) : attr,
        );
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? Colors.blueAccent : Colors.transparent,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: active ? Colors.white : Colors.white70),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
      ),
    
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            toolbarButton(Icons.format_bold, 'Bold', quill.Attribute.bold),
            toolbarButton(Icons.format_italic, 'Italic', quill.Attribute.italic),
            toolbarButton(Icons.format_underline, 'Underline', quill.Attribute.underline),
            toolbarButton(Icons.title, 'Heading 1', quill.Attribute.h1),
            toolbarButton(Icons.format_align_left, 'Align Left', quill.Attribute.leftAlignment),
            toolbarButton(Icons.format_align_center, 'Align Center', quill.Attribute.centerAlignment),
            toolbarButton(Icons.format_align_right, 'Align Right', quill.Attribute.rightAlignment),
            toolbarButton(Icons.format_align_justify, 'Justify', quill.Attribute.justifyAlignment),
          ],
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => Navigator.pop(context, 'delete'),
            )
        ],
      ),
      body: Column(
        children: [

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: quill.QuillEditor(
                controller: quillController,
                focusNode: _editorFocusNode,
                scrollController: _scrollController,
               
              ),
            ),
          ),

        
          buildCustomToolbar(),

        
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () {
                final now = DateTime.now();
                final note = Note(
                  id: widget.note?.id ?? const Uuid().v4(),
                  title: titleController.text,
                  content: jsonEncode(quillController.document.toDelta().toJson()),
                  createdAt: widget.note?.createdAt ?? now,
                  updatedAt: now,
                );
                Navigator.pop(context, note);
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

