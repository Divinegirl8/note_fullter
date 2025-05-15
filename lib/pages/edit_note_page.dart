import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
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

  String _selectedCategory = 'General';
  bool _isPinned = false;

  final List<String> _categories = ['General', 'Work', 'Personal', 'Ideas', 'Other'];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    _isPinned = widget.note?.isPinned ?? false; 
    _selectedCategory = widget.note?.category ?? 'General'; 

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

  Future<void> _chooseCategory() async {
    String tempCategory = _selectedCategory;

    final result = await showDialog<Note>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Category',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._categories.map((cat) {
                    final isSelected = cat == tempCategory;
                    return InkWell(
                      onTap: () => setModalState(() => tempCategory = cat),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(cat),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final now = DateTime.now();
                        final note = Note(
                          id: widget.note?.id ?? const Uuid().v4(),
                          title: titleController.text,
                          content: jsonEncode(quillController.document.toDelta().toJson()),
                          category: tempCategory,
                          isPinned: _isPinned,
                          createdAt: widget.note?.createdAt ?? now,
                          updatedAt: now,
                        );
                        Navigator.pop(context, note);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedCategory = tempCategory;
      });
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Choose Category',
            onPressed: _chooseCategory,
          ),
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            tooltip: 'Pin Note',
            onPressed: () {
              setState(() => _isPinned = !_isPinned);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Note',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share clicked')),
              );
            },
          ),
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => Navigator.pop(context, 'delete'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
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
          const SizedBox(height: 72),
        ],
      ),
    );
  }
}
