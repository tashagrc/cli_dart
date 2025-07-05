// dart run
// dart pub get
// dart format .
// dart analyze

import "dart:io";
import "dart:math";
import 'dart:async';

class CustomTask {
  String title;
  bool isDone;

  CustomTask(this.title, this.isDone);

  @override
  String toString() => "$title - ${isDone ? "✅ Done" : "⏳ Not Done"}";
}

// custom exception
class TaskNotFoundException implements Exception {
  final int index;
  TaskNotFoundException(this.index);

  @override
  String toString() =>
      "TaskNotFoundException: Task at index $index does not exist.";
}

List<CustomTask> tasks = [];

void main(List<String> arguments) async {
  do {
    print("1. Add task");
    print("2. List tasks");
    print("3. Simulate running tasks");

    stdout.write("Enter your input: ");
    int selection = int.parse(stdin.readLineSync()!);

    switch (selection) {
      case 1:
        addTask();
      case 2:
        listTasks();
      case 3:
        stdout.write("Enter what task you want to finish (start 0): ");
        int taskNum = int.parse(stdin.readLineSync()!);
        // catch the error
        try {
          // await bcs the task run in bg
          await Future.wait([
            runTask(taskNum,
                onFailure: () => print("task failed"),
                onSuccess: () => print("task succeed")),
            showLoadingDots()
          ]);
        } on TaskNotFoundException catch (e) {
          print(e);
        }
      default:
        print("Incorrect choice");
    }
  } while (true);
}

void addTask() {
  stdout.write("Enter task name: ");
  String taskName = stdin.readLineSync()!;

  tasks.add(CustomTask(taskName, false));
}

void listTasks() {
  if (tasks.isEmpty) {
    // cannot use == [] they are not same object
    print("No tasks");
    return;
  }

  print("Here is list of tasks");
  for (final t in tasks) {
    print(t);
  }
}

Future<void> runTask(int taskNum,
    {required void Function() onSuccess,
    required void Function() onFailure}) async {
  if (taskNum < 0 || taskNum > tasks.length - 1) {
    throw TaskNotFoundException(taskNum);
  }

  // set delayed
  await Future.delayed(Duration(seconds: 3), () {
    // random
    var r = Random();
    bool res = r.nextBool();

    // update task status
    if (res) {
      tasks[taskNum].isDone = res;
      onSuccess();
    } else {
      onFailure();
    }
  });
}

Future<void> showLoadingDots() async {
  const dotFrames = ['.', '..', '...'];
  for (int i = 0; i < 3; i++) {
    stdout.write('\rLoading${dotFrames[i]}   ');
    await Future.delayed(Duration(seconds: 1));
  }
  print('\rDone!         ');
}
