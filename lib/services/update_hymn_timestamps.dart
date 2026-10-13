import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final db = FirebaseFirestore.instance;
  final collection = db.collection('hymns'); // Change if needed

  final snapshot = await collection.get();

  WriteBatch batch = db.batch();
  int batchCount = 0;
  int updated = 0;

  for (final doc in snapshot.docs) {
    if (!doc.data().containsKey('timestamp')) {
      batch.update(doc.reference, {'timestamp': FieldValue.serverTimestamp()});

      batchCount++;
      updated++;

      if (batchCount == 450) {
        await batch.commit();
        batch = db.batch();
        batchCount = 0;
      }
    }
  }

  if (batchCount > 0) {
    await batch.commit();
  }
}
