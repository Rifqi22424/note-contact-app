import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String uid; // Menambahkan parameter UID di konstruktor

  HomePage({required this.uid});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _ageController = TextEditingController();
  late TextEditingController _noController = TextEditingController();
  late CollectionReference<Map<String, dynamic>> _users;

  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _noController = TextEditingController();

    _users = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('userData');
  }

  Future<void> addUser() {
    return _users
        .add({
          'name': _nameController.text,
          'age': int.parse(_ageController.text),
          'no': int.parse(_noController.text),
          'timestamp': FieldValue.serverTimestamp(), // Add timestamp field
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> updateUser(DocumentSnapshot<Object?> user) {
    return _users
        .doc(user.id)
        .update({
          'name': _nameController.text,
          'age': int.parse(_ageController.text),
          'no': int.parse(_noController.text),
          'timestamp': FieldValue.serverTimestamp(), // Update timestamp field
        })
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> deleteUser(DocumentSnapshot<Object?> user) {
    return _users
        .doc(user.id)
        .delete()
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Contact App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _noController,
              decoration: InputDecoration(labelText: 'Nomor Hp'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              addUser();
            },
            child: Text('Add User'),
          ),
          StreamBuilder(
            stream: _users
                .orderBy('timestamp', descending: true)
                .snapshots(), // Order by timestamp in descending order
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              return Expanded(
                child: ListView(
                  children: snapshot.data!.docs
                      .map((DocumentSnapshot<Map<String, dynamic>> document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(data['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${data['age']} years old'),
                          Text('No: ${data['no']}'), // Menampilkan field 'no'
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              _nameController.text = data['name'];
                              _ageController.text = data['age'].toString();
                              _noController.text = data['no'].toString();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Edit User'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: _nameController,
                                            decoration: InputDecoration(
                                                labelText: 'Name'),
                                          ),
                                          TextField(
                                            controller: _ageController,
                                            decoration: InputDecoration(
                                                labelText: 'Age'),
                                          ),
                                          TextField(
                                            controller: _noController,
                                            decoration: InputDecoration(
                                                labelText: 'Nomor Hp'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          updateUser(document);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Save'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              deleteUser(document);
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
