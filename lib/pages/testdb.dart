import 'package:flutter/material.dart';
import 'package:bus_ticket_app/core/db/testdb.dart';

class Testdb extends StatefulWidget {
  const Testdb({super.key});

  @override
  State<Testdb> createState() => _TestdbState();
}

class _TestdbState extends State<Testdb> {
  final TestDB _testDB = TestDB();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Database')),
      body: Center(
        child: FutureBuilder(
          future: _testDB.fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // Dữ liệu đã là List<Map<String, dynamic>>
              final List<Map<String, dynamic>> jsonList =
                  snapshot.data as List<Map<String, dynamic>>;

              return ListView.builder(
                itemCount: jsonList.length,
                itemBuilder: (context, index) {
                  final item = jsonList[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${item['id']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Name: ${item['name']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Email: ${item['email']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Text('No data available');
            }
          },
        ),
      ),
    );
  }
}
