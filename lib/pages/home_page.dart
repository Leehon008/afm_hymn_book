import 'package:afmnziyo/pages/hymn_detail.dart';
import 'package:afmnziyo/services/firebase_backend.dart';
import 'package:afmnziyo/services/theme_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AfmHomePage extends StatefulWidget {
  final ThemeService themeService;

  const AfmHomePage({super.key, required this.themeService});

  @override
  State<AfmHomePage> createState() => _AfmHomePageState();
}

class _AfmHomePageState extends State<AfmHomePage> {
  final TextEditingController _hymnTitleTextController =
      TextEditingController();
  final TextEditingController _hymnBodyTextController = TextEditingController();
  final FirebaseBackend _firebaseBackend = FirebaseBackend();

  void openDialogBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Hymn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _hymnTitleTextController,
              decoration: InputDecoration(labelText: 'Hymn Title'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _hymnBodyTextController,
              decoration: InputDecoration(labelText: 'Hymn Body'),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _firebaseBackend.addHymn(
                _hymnTitleTextController.text,
                _hymnBodyTextController.text,
              );
              _hymnTitleTextController.clear();
              _hymnBodyTextController.clear();
              Navigator.of(context).pop();
            },
            child: Text('Add Hymn'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        title: const Text('AFM Nziyo', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 107, 149, 220),
        actions: [
          ListenableBuilder(
            listenable: widget.themeService,
            builder: (context, _) {
              return IconButton(
                icon: Icon(
                  widget.themeService.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  widget.themeService.toggleTheme();
                },
                tooltip: widget.themeService.isDarkMode
                    ? 'Light Mode'
                    : 'Dark Mode',
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseBackend.getHymns(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final hymns = snapshot.data!.docs;
            // Display hymns in a ListView
            return ListView.builder(
              itemCount: hymns.length,
              itemBuilder: (context, index) {
                final hymn = hymns[index];
                String docID = hymn.id;
                Map<String, dynamic> data =
                    hymn.data()! as Map<String, dynamic>;
                String hymnText = data['title'] ?? '';
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: const Icon(
                      Icons.bookmark_outline_outlined,
                      size: 20,
                    ),
                    title: Text(
                      hymnText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(docID, style: TextStyle(fontSize: 16)),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HymnDetailPage(hymnId: docID),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openDialogBox,
        child: Icon(Icons.add),
      ),
    );
  }
}
