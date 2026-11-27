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
    // throw 'initial loading failure ';
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

  // add a note method
  Future<void> addTodo(String description) async {
    final initialModel = state.value;
    if (initialModel == null) return;
    state = AsyncData(initialModel.copyWith(status: TodoListStatus.adding));

    try {
      await Future.delayed(Duration(seconds: 1));
      //throw 'addTodo failure ';
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

  // update a note method
  Future<void> updateTodo(String id, String description, bool comp) async {
    final initialModel = state.value;
    if (initialModel == null) return;
    state = AsyncData(initialModel.copyWith(status: TodoListStatus.updating));

    try {
      // simulating the API request time
      await Future.delayed(const Duration(seconds: 1));
      // throw 'updateTodo failure ';
      if (!ref.mounted) return;
      final currentModel = state.value;
      if (currentModel == null) return;
      final updatedTodos = currentModel.todos.map((todo) {
        if (todo.id == id) {
          return Todo(
            id: id,
            description: description,
            completed: comp,
            updatedAt: DateTime.now(),
          );
        }
        return todo;
      }).toList();
      state = AsyncData(
        currentModel.copyWith(
          status: TodoListStatus.upadted,
          todos: updatedTodos,
        ),
      );
      await _saveToprefs(updatedTodos);
    } catch (e) {
      if (!ref.mounted) return;
      final currentModel = state.value;
      if (currentModel == null) return;
      state = AsyncData(
        currentModel.copyWith(
          status: TodoListStatus.updateFailure,
          transientFailure: () => e.toString(),
        ),
      );
    }
  }

  // delete a note method
  Future<void> deleteTodo(String id) async {
    final initialModel = state.value;
    if (initialModel == null) return;
    state = AsyncData(initialModel.copyWith(deletingTodoId: () => id));

    try {
      // simulating the API request time
      await Future.delayed(Duration(seconds: 1));
      // throw 'deleteTodo failure ';
      if (!ref.mounted) return;
      final currentModel = state.value;
      if (currentModel == null) return;
      final updatedTodos = currentModel.todos.where((e) => e.id != id).toList();
      state = AsyncData(
        currentModel.copyWith(
          status: TodoListStatus.deleted,
          todos: updatedTodos,
          deletingTodoId: () => null,
        ),
      );
      await _saveToprefs(updatedTodos);
    } catch (e) {
      final currentModel = state.value;
      if (currentModel == null) return;
      state = AsyncData(
        currentModel.copyWith(
          status: TodoListStatus.deleteFailure,
          transientFailure: () => e.toString(),
          deletingTodoId: () => null,
        ),
      );
    }
  }

  // method to clearTransientFailure and reset the state to loading

  void clearTransientFailure() {
    final currentModel = state.value;
    if (currentModel != null && currentModel.transientFailure != null) {
      // it means an error exists so =>
      AsyncData(
        currentModel.copyWith(
          status: TodoListStatus.loaded,
          deletingTodoId: () => null,
        ),
      );
      // note here in this method we didn't use initial model and a !ref.mounted why because this method is sync not an async method
    }
  }

  void clearStatus() {
    final currentModel = state.value;
    if (currentModel != null) {
      state = AsyncData(
        currentModel.copyWith(
          status: TodoListStatus.loaded,
          transientFailure: () => null,
        ),
      );
    }
  }
}
