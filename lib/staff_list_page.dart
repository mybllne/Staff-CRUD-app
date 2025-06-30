import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffListPage extends StatelessWidget {
  void _deleteStaff(String id) {
    FirebaseFirestore.instance.collection('staffs').doc(id).delete();
  }

  void _editStaff(BuildContext context, String docId, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final idController = TextEditingController(text: data['id']);
    final ageController = TextEditingController(text: data['age'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Edit Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: idController, decoration: InputDecoration(labelText: 'ID')),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('staffs').doc(docId).update({
                'name': nameController.text,
                'id': idController.text,
                'age': int.tryParse(ageController.text) ?? 0,
              });
              Navigator.pop(context);
            },
            child: Text('Update', style: TextStyle(color: Colors.pink)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCE4EC),
      appBar: AppBar(
        title: Text('Bataras Sdn. Bhd. Staff List'),
        backgroundColor: Colors.pink[300],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/create'),
              icon: Icon(Icons.add),
              label: Text('Add New Staff'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[300],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('staffs')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No staff data found.",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final staff = docs[index];
                    final data = staff.data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.white,
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        title: Text(
                          '${data['name']} (${data['id']})',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.pink[800]),
                        ),
                        subtitle: Text(
                          'Age: ${data['age']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.pink),
                              onPressed: () => _editStaff(context, staff.id, data),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteStaff(staff.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
