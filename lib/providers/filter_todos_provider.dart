import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/todo.dart';
import 'todo_list_provider.dart';

part 'filter_todos_provider.g.dart';

@riverpod
List<Todo> filteredTodos(Ref ref, String filter) {
  final todosAsync = ref.watch(todoListProvider);
  final todos = todosAsync.value?.todos ?? [];
  final sorted = [...todos]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sorted.where((t) {
    if (filter == 'completed') return t.completed;
    if (filter == 'pending') return !t.completed;
    return true;
  }).toList();
}
