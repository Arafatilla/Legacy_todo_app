import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/todo.dart';
import 'todo_list_state.dart';

part 'todo_list_provider.g.dart';

@riverpod
class TodoList extends _$TodoList {
  static const _storageKey = 'todos';

  FutureOr<TodoListState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    final todos = jsonString == null
        ? <Todo>[]
        : (jsonDecode(jsonString) as List<dynamic>)
              .map((json) => Todo.fromJson(json as Map<String, dynamic>))
              .toList();
    await Future.delayed(const Duration(seconds: 2));
    // We use jsonDecode() to convert the jsonString into a List<dynamic>.
    // Then, we use .map() to iterate over each element in the list.
    // Each element is a Map<String, dynamic>, which we convert into a
    // Todo object using Todo.fromJson().
    // The map() method produces an Iterable<Todo>.
    // Finally, .toList() converts the Iterable<Todo> into a List<Todo>.
    // Note : when the build function is first executed the state becomes AyncLoading if an error occurs it becomes and AysncError
    return TodoListState(todos: todos);
  }

  // a method to save a next todo or a deleted to do into the storagekey to keep the shared prefernces updated

  Future<void> _saveToprefs(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonSting = jsonEncode(todos.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonSting);
  }

  Future<void> addTodo(String description) async {
    final initialModel = state.value;
    if (initialModel == null) return;
    state = AsyncData(initialModel.copyWith(status: TodoListStatus.adding));

    try {
      await Future.delayed(Duration(seconds: 1));

      if (!ref.mounted) return;
      final currentModel = state.value;
      if (currentModel == null) return;
      final newTodo = Todo(id: const Uuid().v4(), description: description);
      final updatedTodos = [newTodo, ...currentModel.todos];
      state = AsyncData(
        currentModel.copyWith(
          status: TodoListStatus.added,
          todos: updatedTodos,
        ),
      );
      await _saveToprefs(updatedTodos);
    } catch (e) {
      // here is the disadvantage of using riverpod without mutations

      if (!ref.mounted) return;
      final currentModel = state.value;
      if (currentModel == null) return;
      state = AsyncData(
        currentModel.copyWith(
          status: TodoListStatus.addFailure,
          transientFailure: () => e.toString(),
        ),
      );
    }
  }
}
