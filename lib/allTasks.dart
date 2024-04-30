import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ediTaskScreen.dart';
import 'taskCreation.dart';

class AllTasks extends StatefulWidget {
  const AllTasks({Key? key}) : super(key: key);

  @override
  State<AllTasks> createState() => _AllTasksState();
}

class _AllTasksState extends State<AllTasks> {
  Future<void> _deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance
          .collection('createTasks')
          .doc(taskId)
          .delete();
      print('Task deleted successfully');
    } catch (e) {
      print('Error deleting task: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting task: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _markAsCompleted(String taskId) async {
    try {
      await FirebaseFirestore.instance
          .collection('createTasks')
          .doc(taskId)
          .update({'completed': true});
      print('Task marked as completed');
    } catch (e) {
      print('Error marking task as completed: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking task as completed: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Tasks'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('createTasks')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<DocumentSnapshot> tasks = snapshot.data!.docs;

                if (tasks.isEmpty) {
                  return Center(
                    child: Text('No tasks found'),
                  );
                }

                List<DocumentSnapshot> completedTasks = [];
                List<DocumentSnapshot> incompleteTasks = [];
                for (var task in tasks) {
                  if (task['completed']) {
                    completedTasks.add(task);
                  } else {
                    incompleteTasks.add(task);
                  }
                }

                List<Widget> taskWidgets = [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Incompleted Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  ..._buildTaskList(incompleteTasks),
                ];

                if (completedTasks.isNotEmpty) {
                  taskWidgets.addAll([
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Completed Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    ..._buildTaskList(completedTasks),
                  ]);
                }

                return Column(
                  children: taskWidgets,
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserCreationScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add Task',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTaskList(List<DocumentSnapshot> tasks) {
    return tasks.map((task) {
      String taskId = task.id;
      Map<String, dynamic> taskData = task.data() as Map<String, dynamic>;
      String formattedDueDate = '';
      if (taskData['_dueDate'] != null) {
        Timestamp timestamp = taskData['_dueDate'];
        DateTime dueDate = timestamp.toDate();
        formattedDueDate = '${dueDate.month}/${dueDate.day}/${dueDate.year}';
      }
      return ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${taskData['_taskTitle']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${taskData['_description']}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Due Date: $formattedDueDate',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!taskData['completed']) ...[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTaskScreen(
                        taskId: taskId,
                        taskTitle: taskData['_taskTitle'],
                        description: taskData['_description'],
                        dueDate: taskData['_dueDate'],
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteTask(taskId);
                },
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color.fromRGBO(12, 201, 226, 1),
                ),
                child: DropdownButton<String>(
                  value: taskData['completed'] ? 'Completed' : 'Open',
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue == 'Completed') {
                        _markAsCompleted(taskId);
                      } else {}
                    });
                  },
                  items: <String>['Open', 'Completed']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,style: TextStyle(color: Colors.black),),
                    );
                  }).toList(),
                ),
              )
            ],
          ],
        ),
      );
    }).toList();
  }
}
