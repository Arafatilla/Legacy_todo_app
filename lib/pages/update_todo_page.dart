// 3. Extend ConsumerWidget instead of StatelessWidget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo.dart';

class UpdateTodoPage extends ConsumerStatefulWidget {
  const UpdateTodoPage({super.key, required this.todo});
  final Todo todo;

  @override
  ConsumerState<UpdateTodoPage> createState() => _UpdateTodoPageState();
}

class _UpdateTodoPageState extends ConsumerState<UpdateTodoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConsumerWidget Example')),
    );
  }
}
