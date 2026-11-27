// 3. Extend ConsumerWidget instead of StatelessWidget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_list_provider.dart';
import '../providers/todo_list_state.dart';

class AddTodoPage extends ConsumerStatefulWidget {
  const AddTodoPage({super.key});

  @override
  ConsumerState<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends ConsumerState<AddTodoPage> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<TodoListState>>(todoListProvider, (previous, next) {
      next.whenData((state) {
        switch (state.status) {
          case TodoListStatus.added:
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Todo added")));
            Navigator.pop(context); // in order to return to the homePage
          case TodoListStatus.addFailure:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error : ${next.value!.transientFailure}'),
              ),
            );
            ref.read(todoListProvider.notifier).clearTransientFailure(); // this to prevent the snack bar from being displeid multiple times
          case _:
        }
      });
    });
    final addState = ref.watch(todoListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Todo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: "description"),
              enabled: addState.value?.status != TodoListStatus.adding,
            ),
            const SizedBox(height: 16),
            switch (addState.value?.status) {
              TodoListStatus.adding => const CircularProgressIndicator(),
              _ => ElevatedButton(
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    ref
                        .read(todoListProvider.notifier)
                        .addTodo(_controller.text);
                  }
                },
                child: const Text("Add"),
              ),
            },
          ],
        ),
      ),
    );
  }
}
