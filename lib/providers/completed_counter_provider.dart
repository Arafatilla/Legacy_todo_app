import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo_list_provider.dart';

final completedCountProvider = Provider<int>((ref) {
  final todoListState = ref.watch(todoListProvider);
  final todos = todoListState.value?.todos ?? [];
  return todos.where((t) => t.completed).length;
});
