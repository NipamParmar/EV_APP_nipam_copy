import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersList extends StatelessWidget {
  const AdminUsersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Analytics")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var user = snapshot.data!.docs[index];
              return ListTile(
                leading: CircleAvatar(child: Text(user['name'][0])),
                title: Text(user['name']),
                subtitle: Text("Revenue: ₹${user['walletBalance']}"),
                trailing: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("120 kWh", style: TextStyle(color: Color(0xFF28C76F), fontWeight: FontWeight.bold)),
                    Text("Energy Used", style: TextStyle(fontSize: 10)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}