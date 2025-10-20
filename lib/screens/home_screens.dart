import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreens> {
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController todoController = TextEditingController();
  String message = "";

  Future<void> addTodo() async {
    String todoText = todoController.text.trim();
    try {
      await FirebaseFirestore.instance.collection("todo").add({
        'title': todoController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'check': false,
      });
      setState(() {
        message = "Berhasil menambahkan todo";
        todoController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      todoController.clear();
    } catch (e) {
      setState(() {
        message = "Gagal menambahkan todo: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TODO App"),
        actions: [
          IconButton(
            onPressed: () {
             showDialog(context: context, builder: (context) {
              return AlertDialog(
                title: Text("Konfirmasi Logout"),
                content: Text("Apakah Anda yakin ingin logout?"),
                
              );
               
             },);
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              "Selamat datang, ${user?.displayName ?? 'User'}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("todo")
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    {
                      return Center(child: CircularProgressIndicator());
                    }
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Tidak ada todo"));
                  }
                  final data = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final todo = data[index];
                      return ListTile(
                        title: Text(todo['title']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("todo")
                                .doc(todo.id)
                                .delete();
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: TextField(
          controller: todoController,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                addTodo();
              },
              icon: Icon(Icons.send),
            ),
            border: OutlineInputBorder(),
            labelText: "Masukkan Todo",
          ),
        ),
      ),
    );
  }
}
