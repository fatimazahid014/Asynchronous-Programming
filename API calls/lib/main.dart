import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Todo {
  final int id;
  final String title;

  Todo({required this.id, required this.title});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
    );
  }
}

class TodoModel {
  List<Todo> todos = [];

  Future<void> fetchTodos() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));
    final List<dynamic> responseData = jsonDecode(response.body);
    todos = responseData.map((json) => Todo.fromJson(json)).toList();
  }
}

class TodoController {
  final TodoModel model;

  TodoController(this.model);

  Future<void> fetchTodos() async {
    await model.fetchTodos();
  }
}

class TodoListView extends StatefulWidget {
  final TodoController controller;

  TodoListView({required this.controller});

  @override
  _TodoListViewState createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Response'),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<void>(
        future: widget.controller.fetchTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: widget.controller.model.todos.length,
              itemBuilder: (context, index) {
                final todo = widget.controller.model.todos[index];
                return ListTile(
                  title: Text('ID: ${todo.id}'),
                  subtitle: Text(todo.title),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todoModel = TodoModel();
    final todoController = TodoController(todoModel);
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListView(controller: todoController),
    );
  }
}
