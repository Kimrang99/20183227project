
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project20183227/login.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final String date;
  final double rating;

  DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.rating,
  });
}

class RatingStars extends StatelessWidget {
  final double rating;

  const RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }
}

void signOut() async {
  await FirebaseAuth.instance.signOut();
}

class DiaryList extends StatefulWidget {
  final User? user;

  DiaryList({this.user});

  @override
  _DiaryListState createState() => _DiaryListState();
}

class _DiaryListState extends State<DiaryList> {
  final CollectionReference diaryCollection =
      FirebaseFirestore.instance.collection('users');

  List<DiaryEntry> _diaryEntries = [];

  @override
  void initState() {
    super.initState();
    _loadDiaryEntries();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (widget.user != null) {
        _loadDiaryEntries();
      } else {
        setState(() {
          _diaryEntries = [];
        });
      }
    });
  }

  Future<void> _loadDiaryEntries() async {
    final snapshot = await diaryCollection
        .doc(widget.user!.uid)
        .collection('diary')
        .get();

    setState(() {
      _diaryEntries = snapshot.docs.map((doc) {
        final data = doc.data();
        return DiaryEntry(
          id: doc.id,
          title: (data as Map<String, dynamic>)['title'],
          content: (data as Map<String, dynamic>)['content'],
          date: (data as Map<String, dynamic>)['date'],
          rating: (data as Map<String, dynamic>)['rating'],
        );
      }).toList();
    });
  }

  void _addDiaryEntry(DiaryEntry entry) async {
    // 일기 추가
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDiaryCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('diary');

      final docRef = await userDiaryCollection.add({
        'title': entry.title,
        'content': entry.content,
        'date': entry.date,
        'rating': entry.rating,
      });

      setState(() {
        _diaryEntries.add(DiaryEntry(
          id: docRef.id,
          title: entry.title,
          content: entry.content,
          date: entry.date,
          rating: entry.rating,
        ));
      });
    }
  }

  void _deleteDiaryEntry(DiaryEntry entry) async {
    // 일기 삭제
    await diaryCollection.doc(entry.id).delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user!.uid)
        .collection('diary')
        .doc(entry.id)
        .delete();

    setState(() {
      _diaryEntries.remove(entry);
    });
  }


  void _viewDiaryEntry(DiaryEntry entry) {
    // 저장된 일기 보기
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(entry.date),
              elevation: 0.0,
              backgroundColor: Colors.lightBlueAccent.shade100,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '제목: ${entry.title}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      '내용: ${entry.content}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Text(
                          '오늘의 점수:  ',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        RatingStars(rating: entry.rating),
                        Text(
                          '   ${entry.rating}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.lightBlue.shade200,
                        ),
                        onPressed: () {
                          _deleteDiaryEntry(entry);
                          Navigator.pop(context);
                        },
                        child: Text('삭제'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오늘 하루 어땠니?'),
        elevation: 0.0,
        backgroundColor: Colors.lightBlueAccent.shade100,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.output),
            iconSize: 30,
            onPressed: () async {
              signOut();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) => LogIn()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(
            _diaryEntries.length,
            (index) => ListTile(
              title: Text(_diaryEntries[index].date),
              subtitle: Text(_diaryEntries[index].title),
              onTap: () {
                _viewDiaryEntry(_diaryEntries[index]);
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent.shade100,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => DiaryForm(
                onSave: _addDiaryEntry,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class DiaryForm extends StatefulWidget {
  final Function(DiaryEntry) onSave;

  const DiaryForm({Key? key, required this.onSave}) : super(key: key);

  @override
  _DiaryFormState createState() => _DiaryFormState();
}

class _DiaryFormState extends State<DiaryForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedDate = '';
  double _rating = 0.0;

  void _saveDiaryEntry() {
    final title = _titleController.text;
    final content = _contentController.text;
    final date = _selectedDate;

    final diaryEntry = DiaryEntry(
      id: '',
      title: title,
      content: content,
      date: date,
      rating: _rating,
    );

    _titleController.clear();
    _contentController.clear();

    widget.onSave(diaryEntry);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('일기 작성'),
        elevation: 0.0,
        backgroundColor: Colors.lightBlueAccent.shade100,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '날짜 : $_selectedDate',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  IconButton(
                    onPressed: () => _selectDate(context),
                    icon: Icon(Icons.date_range),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: '내용',
                ),
              ),
              SizedBox(height: 16.0),
              Text('오늘의 점수'),
              SizedBox(height: 10.0),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 30.0,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.yellow,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlue.shade200,
                ),
                onPressed: _saveDiaryEntry,
                child: Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (selected != null) {
      setState(() {
        _selectedDate = (DateFormat.yMMMd()).format(selected);
      });
    }
  }
}
