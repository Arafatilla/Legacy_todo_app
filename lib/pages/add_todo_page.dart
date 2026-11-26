// 3. Extend ConsumerWidget instead of StatelessWidget
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTodoPage extends ConsumerWidget {
  const AddTodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConsumerWidget Example')),
      body: Center(),
    );
  }
}
