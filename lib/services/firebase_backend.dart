import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBackend {
  //Todo: Implement Firebase backend services

  //initialize Firebase
  final CollectionReference hymnsCollection = FirebaseFirestore.instance
      .collection('hymns');

  // add data to Firestore
  Future<void> addHymn(String hymnData) async {
    final counterRef = FirebaseFirestore.instance
        .collection('metadata')
        .doc('hymnCounter');

    final newId = await FirebaseFirestore.instance.runTransaction<int>((
      txn,
    ) async {
      final snapshot = await txn.get(counterRef);
      int next = 1;
      if (snapshot.exists &&
          snapshot.data() != null &&
          snapshot.data()!.containsKey('count')) {
        next = (snapshot.get('count') as int) + 1;
        txn.update(counterRef, {'count': next});
      } else {
        txn.set(counterRef, {'count': next});
      }
      return next;
    });

    final docRef = hymnsCollection.doc(newId.toString());
    await docRef.set({
      'id': newId,
      'hymn': hymnData,
      'timestamp': Timestamp.now(),
    });
  }

  // get data by Id from Firestore
  Future<DocumentSnapshot> getHymnById(String id) {
    return hymnsCollection.doc(id).get();
  }

  // retrieve data from Firestore
  Stream<QuerySnapshot> getHymns() {
    final notesStream = hymnsCollection
        .orderBy('timestamp', descending: false)
        .snapshots();
    return notesStream;
  }

  //update data in Firestore
  Future<void> updateHymn(String id, String newHymnData) {
    return hymnsCollection.doc(id).update({
      'hymn': newHymnData,
      'timestamp': Timestamp.now(),
    });
  }

  // delete data from Firestore
  Future<void> deleteHymn(String id) {
    return hymnsCollection.doc(id).delete();
  }
}
