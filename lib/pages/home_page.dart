// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;

// import '../model/note.dart';
// import 'edit_note_page.dart';
// import 'view_note_page.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<Note> notes = [];
//   String searchQuery = '';

//   @override
//   Widget build(BuildContext context) {
//     List<Note> filteredNotes = notes.where((note) {
//       final plainText = getPlainText(note.content);
//       return note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
//           plainText.toLowerCase().contains(searchQuery.toLowerCase());
//     }).toList();

//     DateTime today = DateTime.now();
//     List<DateTime> daysList =
//         List.generate(6, (index) => today.add(Duration(days: index)));

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: false,
//         title: Text(
//           '${_getMonthName(today.month)} ${today.year}',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           PopupMenuButton<String>(
//             icon: Icon(Icons.more_vert),
//             onSelected: (value) {
//               // Handle menu actions if needed
//             },
//             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//               const PopupMenuItem<String>(
//                 value: 'settings',
//                 child: Text('Settings'),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'about',
//                 child: Text('About'),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search for notes',
//                 filled: true,
//                 fillColor: Colors.grey[200],
//                 contentPadding:
//                     EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 prefixIcon: Icon(Icons.search),
//               ),
//               onChanged: (val) {
//                 setState(() => searchQuery = val);
//               },
//             ),
//           ),

//           // Horizontal date selector
//           SizedBox(
//             height: 90,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: EdgeInsets.symmetric(horizontal: 12),
//               itemCount: daysList.length,
//               itemBuilder: (context, index) {
//                 final day = daysList[index];
//                 final bool isToday = day.day == today.day &&
//                     day.month == today.month &&
//                     day.year == today.year;

//                 return Container(
//                   width: 60,
//                   margin: EdgeInsets.only(top: 10, left: 6, right: 6),
//                   padding: EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                     color: isToday ? Colors.black : Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.black, width: 1.5),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         _getDayName(day.weekday),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: isToday ? Colors.white : Colors.black,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                       SizedBox(height: 2),
//                       Text(
//                         '${day.day}',
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: isToday ? Colors.white : Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Notes list or no notes message
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
//               child: filteredNotes.isEmpty
//                   ? Center(
//                       child: Text(
//                         'No notes yet',
//                         style: TextStyle(fontSize: 18, color: Colors.grey),
//                       ),
//                     )
//                   : GridView.builder(
//                       padding: const EdgeInsets.all(0),
//                       itemCount: filteredNotes.length,
//                       gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//                         maxCrossAxisExtent: 250,
//                         mainAxisSpacing: 12,
//                         crossAxisSpacing: 12,
//                         childAspectRatio: 3 / 2,
//                       ),
//                       itemBuilder: (context, index) {
//                         final note = filteredNotes[index];
//                         return GestureDetector(
//                           onTap: () async {
//                             final result = await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => ViewNotePage(note: note),
//                               ),
//                             );

//                             if (result == 'delete') {
//                               setState(() {
//                                 notes.removeWhere((n) => n.id == note.id);
//                               });
//                             } else if (result is Note) {
//                               setState(() {
//                                 final idx = notes.indexWhere((n) => n.id == result.id);
//                                 if (idx != -1) notes[idx] = result;
//                               });
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color:
//                                   Colors.primaries[index % Colors.primaries.length][100],
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black12,
//                                   blurRadius: 4,
//                                   offset: Offset(2, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   note.title,
//                                   style: TextStyle(
//                                       fontSize: 16, fontWeight: FontWeight.bold),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Text(
//                                   getPlainText(note.content),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 Spacer(),
//                                 Text(
//                                   '${note.updatedAt.toLocal()}'.split('.')[0],
//                                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.black,
//         shape: CircleBorder(),
//         child: Icon(Icons.add, color: Colors.white),
//         onPressed: () async {
//           final newNote = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => EditNotePage()),
//           );
//           if (newNote != null) {
//             setState(() => notes.add(newNote));
//           }
//         },
//       ),
//     );
//   }

//   String _getMonthName(int month) {
//     const monthNames = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December'
//     ];
//     return monthNames[month - 1];
//   }

//   String _getDayName(int weekday) {
//     const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return dayNames[weekday - 1];
//   }

//   String getPlainText(String deltaJson) {
//     if (deltaJson.isEmpty) return '';
//     try {
//       final doc = quill.Document.fromJson(jsonDecode(deltaJson));
//       return doc.toPlainText();
//     } catch (e) {
//       return '';
//     }
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../model/note.dart';
import 'edit_note_page.dart';
import 'view_note_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<Note> filteredNotes = notes.where((note) {
      final plainText = getPlainText(note.content);
      return note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          plainText.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    DateTime today = DateTime.now();
    List<DateTime> daysList =
        List.generate(6, (index) => today.add(Duration(days: index)));

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          '${_getMonthName(today.month)} ${today.year}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              // Handle menu actions if needed
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: Text('About'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for notes',
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                setState(() => searchQuery = val);
              },
            ),
          ),

          // Horizontal date selector
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: daysList.length,
              itemBuilder: (context, index) {
                final day = daysList[index];
                final bool isToday = day.day == today.day &&
                    day.month == today.month &&
                    day.year == today.year;

                return Container(
                  width: 60,
                  margin: EdgeInsets.only(top: 10, left: 6, right: 6),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDayName(day.weekday),
                        style: TextStyle(
                          fontSize: 14,
                          color: isToday ? Colors.white : Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Notes list or no notes message
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
              child: filteredNotes.isEmpty
                  ? Center(
                      child: Text(
                        'No notes yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: filteredNotes.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 3 / 2,
                      ),
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewNotePage(note: note),
                              ),
                            );

                            if (result == 'delete') {
                              setState(() {
                                notes.removeWhere((n) => n.id == note.id);
                              });
                            } else if (result is Note) {
                              setState(() {
                                final idx = notes.indexWhere((n) => n.id == result.id);
                                if (idx != -1) notes[idx] = result;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors
                                  .primaries[index % Colors.primaries.length][100],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.title,
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: quill.QuillEditor.basic(
                                    controller: quill.QuillController(
                                      document: quill.Document.fromJson(
                                          jsonDecode(note.content)),
                                      selection:
                                          const TextSelection.collapsed(offset: 0),
                                    ),
                             
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditNotePage()),
          );
          if (newNote != null) {
            setState(() => notes.add(newNote));
          }
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  String _getDayName(int weekday) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[weekday - 1];
  }

  String getPlainText(String deltaJson) {
    if (deltaJson.isEmpty) return '';
    try {
      final doc = quill.Document.fromJson(jsonDecode(deltaJson));
      return doc.toPlainText();
    } catch (e) {
      return '';
    }
  }
}

