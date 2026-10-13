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
  final TextEditingController _searchController = TextEditingController();

  final FirebaseBackend _firebaseBackend = FirebaseBackend();

  String _searchQuery = '';

  @override
  void dispose() {
    _hymnTitleTextController.dispose();
    _hymnBodyTextController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void openHymn(String hymnId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HymnDetailPage(hymnId: hymnId)),
    );
  }

  void openDialogBox() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Hymn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _hymnTitleTextController,
              decoration: const InputDecoration(labelText: 'Hymn Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hymnBodyTextController,
              decoration: const InputDecoration(labelText: 'Hymn Body'),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await _firebaseBackend.addHymn(
                _hymnTitleTextController.text,
                _hymnBodyTextController.text,
              );

              _hymnTitleTextController.clear();
              _hymnBodyTextController.clear();

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Add Hymn'),
          ),
        ],
      ),
    );
  }

  Widget buildHymnList({required bool inDrawer}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseBackend.getHymns(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final hymns = snapshot.data!.docs;

        final filteredHymns = hymns.where((hymn) {
          final data = hymn.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();

          return title.contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredHymns.isEmpty) {
          return Center(
            child: Text(
              _searchQuery.isEmpty ? 'No hymns available' : 'No hymns found',
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredHymns.length,
          itemBuilder: (context, index) {
            final hymn = filteredHymns[index];
            final docID = hymn.id;
            final data = hymn.data() as Map<String, dynamic>;
            final hymnTitle = (data['title'] ?? '').toString();

            return Card(
              margin: EdgeInsets.symmetric(
                horizontal: inDrawer ? 8 : 12,
                vertical: 5,
              ),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                dense: inDrawer,
                leading: const Icon(Icons.bookmark_outline),
                title: Text(
                  hymnTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: inDrawer
                    ? const Icon(Icons.chevron_right)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(docID),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                onTap: () {
                  if (inDrawer) {
                    Navigator.pop(context);
                  }
                  openHymn(docID);
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

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
                onPressed: widget.themeService.toggleTheme,
                tooltip: widget.themeService.isDarkMode
                    ? 'Light Mode'
                    : 'Dark Mode',
              );
            },
          ),
        ],
      ),

      // Navigation drawer with live hymn search.
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: const Color.fromARGB(255, 80, 118, 185),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.library_music, size: 42, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'AFM Nziyo',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Uyai Va Kristu',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search hymns by title...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              if (_searchQuery.isEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Home'),
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(height: 1),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SEARCH HYMNS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],

              Expanded(child: buildHymnList(inDrawer: true)),

              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About AFM Nziyo'),
                onTap: () {
                  Navigator.pop(context);
                  showAboutDialog(
                    context: context,
                    applicationName: 'AFM Nziyo',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'AFM Hymn Book first version',
                    applicationIcon: const Icon(Icons.library_music, size: 42),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      body: buildHymnList(inDrawer: false),

      floatingActionButton: FloatingActionButton(
        onPressed: openDialogBox,
        child: const Icon(Icons.add),
      ),
    );
  }
}
