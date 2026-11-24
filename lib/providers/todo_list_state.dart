import '../models/todo.dart';

enum TodoListStatus {
  loaded,
  // serves two cases when the app is has been launched and nothing is happening but it's waiting for a command
  // it servers also the case where an error happens for example the user adds a note then the nlote is not added (addFailure ) , so the app will return to the loaded state waiting for the next command
  adding,
  added,
  addFailure,
  updating,
  upadted,
  updateFailure,
  deleted,
  deleteFailure,
}

class TodoListState {
  const TodoListState({
    this.status = TodoListStatus.loaded,
    this.todos = const [],
    this.transientFailure,
    this.deletingTodoId,
  });

  final TodoListStatus status;
  final List<Todo> todos;
  final String? transientFailure; // is used to store the error that happens on an action in order to display it to the UI (snack bar)
  final String?
  deletingTodoId; // it is used to store the todo id that is being deleted

  @override
  List<Object?> get props => [status, todos, transientFailure, deletingTodoId];

  // copywith
  TodoListState copyWith({
    TodoListStatus? status,
    List<Todo>? todos,
    String? Function()? transientFailure,
    String? Function()? deletingTodoId,
  }) {
    return TodoListState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      transientFailure: transientFailure != null
          ? transientFailure()
          : this.transientFailure,
      deletingTodoId: deletingTodoId != null
          ? deletingTodoId()
          : this.deletingTodoId,
    );
  }
}
