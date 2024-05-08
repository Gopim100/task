import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'allUsers.dart'; // Assuming this is the screen to navigate to after user creation

class UserCreationScreen extends StatefulWidget {
  const UserCreationScreen({Key? key}) : super(key: key);

  @override
  _UserCreationScreenState createState() => _UserCreationScreenState();
}

class _UserCreationScreenState extends State<UserCreationScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _createUser(BuildContext context) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Navigator.pop(context);
        return;
      }

      await FirebaseFirestore.instance.collection('createdUsers').add({
        'uid': currentUser.uid,
        '_userName': _userNameController.text.trim(),
        '_password': _passwordController.text.trim(),
      });
      print('User details added to Firestore');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AllUsers()),
      );
    } catch (e) {
      print('Error creating user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating user: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Username and Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _createUser(context),
              child: Text('Create User'),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
