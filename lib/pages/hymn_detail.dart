import 'package:afmnziyo/services/firebase_backend.dart';
import 'package:flutter/material.dart';

class HymnDetailPage extends StatefulWidget {
  final String hymnId;

  const HymnDetailPage({super.key, required this.hymnId});

  @override
  State<HymnDetailPage> createState() => _HymnDetailPageState();
}

class _HymnDetailPageState extends State<HymnDetailPage> {
  final FirebaseBackend _firebaseBackend = FirebaseBackend();
  void hymn() async {
    final hymn = await _firebaseBackend.getHymnById(widget.hymnId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.hymnId),
              FutureBuilder(
                future: _firebaseBackend.getHymnById(widget.hymnId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  } else if (snapshot.hasError) {
                    return const Text('Error');
                  } else if (snapshot.hasData) {
                    final hymnData = snapshot.data!;
                    final data = hymnData.data() as Map<String, dynamic>;
                    final hymnTitle = data['title'] ?? 'Hymn';
                    if (hymnTitle.length > 20) {
                      return Text(hymnTitle.substring(0, 20) + '...');
                    }
                    return Text(hymnTitle);
                  } else {
                    return const Text('Hymn not found');
                  }
                },
              ),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Icon(Icons.preview_outlined),
              //         Icon(Icons.bookmark_outline_outlined),
              //       ],
              //     ),
              //   ],
              // ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 107, 149, 220),
        ),
        body: FutureBuilder(
          future: _firebaseBackend.getHymnById(widget.hymnId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final hymnData = snapshot.data!;
              final data = hymnData.data() as Map<String, dynamic>;
              final hymnText = data['hymn'] ?? 'No hymn data available';

              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 0.3,
                    margin: EdgeInsets.all(5.0),
                    child: ListTile(
                      subtitle: Text(hymnText, style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              );
            } else {
              return Center(child: Text('Hymn not found'));
            }
          },
        ),
      ),
    );
  }
}
