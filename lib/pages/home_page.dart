// 3. Extend ConsumerWidget instead of StatelessWidget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo.dart';
import '../providers/completed_counter_provider.dart';
import '../providers/filter_todos_provider.dart';
import '../providers/todo_list_provider.dart';
import '../providers/todo_list_state.dart';
import 'add_todo_page.dart';
import 'update_todo_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<TodoListState>>(todoListProvider, (previous, next) {
      next.whenData((state) {
        switch (state.status) {
          case TodoListStatus.deleted:
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Todo Deleted ")));
          case TodoListStatus.deleteFailure:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error : ${next.value!.transientFailure}"),
              ),
            );
            ref.watch(todoListProvider.notifier).clearTransientFailure();
          case _:
        }
      });
    });
    final todosAsync = ref.watch(todoListProvider);

    return todosAsync.when(
      data: (todoListState) {
        final todos = todoListState.todos;
        final completedtedCount = ref.watch(completedCountProvider);
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text('$completedtedCount/${todos.length} Completed '),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddTodoPage()),
                    );
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: "All"),
                  Tab(text: "completed"),
                  Tab(text: "pending"),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                TodoList(filter: "All"),
                TodoList(filter: "completed"),
                TodoList(filter: "pending"),
              ],
            ),
          ),
        );
      },
      error: (error, StackTrace) {
        return Scaffold(
          appBar: AppBar(title: const Text('Iniatialization error')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  "Failed to fetch data : \n${todosAsync.error}",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(todoListProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class TodoList extends ConsumerWidget {
  const TodoList({super.key, required this.filter});
  final String filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredTodosProvider(filter));
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return TodoItem(todo: filtered[index]);
      },
    );
  }
}

// TodoItem  widget

class TodoItem extends ConsumerWidget {
  final Todo todo;
  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletingTodoId = ref.watch(
      todoListProvider.select((state) => state.value?.deletingTodoId),
    );
    return ListTile(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => UpdateTodoPage(todo: todo)));
      },
      title: Text(
        todo.description,
        style: TextStyle(
          decoration: todo.completed ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: deletingTodoId == todo.id
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(),
            )
          : IconButton(
              onPressed: () {
                ref.read(todoListProvider.notifier).deleteTodo(todo.id);
              },
              icon: const Icon(Icons.delete),
            ),
    );
  }
}
