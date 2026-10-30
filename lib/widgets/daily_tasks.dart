import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:percent_indicator/percent_indicator.dart';
import '../models/app_state.dart';
import '../theme/colors.dart';
import '../models/task.dart';

class DayTaskPanel extends StatefulWidget {
  const DayTaskPanel({super.key});

  @override
  State<DayTaskPanel> createState() => _DayTaskPanelState();
}

class _DayTaskPanelState extends State<DayTaskPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  bool _wasAllCompleted = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final date = appState.selectedDate;
    final tasks = appState.tasksForSelectedDate;

    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    // Trigger celebration if newly completed
    if (totalCount > 0 && progress == 1.0 && !_wasAllCompleted) {
      _wasAllCompleted = true;
      _celebrationController.forward(from: 0);
    } else if (progress < 1.0) {
      _wasAllCompleted = false;
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Area
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE').format(date),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMMM yyyy').format(date),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      CircularPercentIndicator(
                        radius: 25.0, // Smaller ring
                        lineWidth: 6.0,
                        animation: true,
                        animateFromLastPercent: true,
                        percent: progress,
                        center: Text(
                          "${(progress * 100).toInt()}%",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10.0,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: AppColors.primaryGreen,
                        backgroundColor: Colors.white.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (tasks.isEmpty)
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined,
                          size: 48, color: Colors.grey.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text("No tasks for today",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 16,
                          )),
                      ],
                    ),
                  ),
                ),

              // Task List
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                    bottom: 80), // Prevent overlap with FAB
                children: tasks
                    .map((task) => TaskTile(
                          task: task,
                          onToggle: () =>
                              _confirmToggle(context, appState, task.id),
                          onDelete: () => _confirmDelete(context, appState, task.id),
                          onEdit: () => _showEditTaskDialog(context, appState, task),
                        ))
                    .toList(),
              ),

              // Add Button
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryGreen, AppColors.primaryGreen.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      onPressed: () => _showAddTaskDialog(context, appState),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("ADD NEW TASK",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_wasAllCompleted)
          Positioned.fill(
            child: IgnorePointer(
              child: ConfettiWidget(controller: _celebrationController),
            ),
          ),
      ],
    );
  }

  void _confirmToggle(BuildContext context, AppState appState, String taskId) {
    final now = DateTime.now();
    final selected = appState.selectedDate;
    final isToday = selected.year == now.year &&
        selected.month == now.month &&
        selected.day == now.day;

    if (isToday) {
      appState.toggleTask(taskId);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Update Task?"),
          content: const Text(
              "You are updating a task for a different date. Do you want to proceed?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                appState.toggleTask(taskId);
                Navigator.pop(ctx);
              },
              child: const Text("Confirm"),
            ),
          ],
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, AppState appState, String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              appState.deleteTask(taskId);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController();
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            top: 32,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add New Task",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(ctx).textTheme.titleLarge?.color,
                  )),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "What needs to be done?",
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
                    child: Text(
                      selectedTime == null
                          ? "Select Reminder Time (Optional)"
                          : "Time: ${selectedTime!.format(context)}",
                      style: TextStyle(
                        color: selectedTime == null ? Colors.grey : AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (selectedTime != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          selectedTime = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      appState.addTask(
                        controller.text,
                        appState.selectedDate,
                        time: selectedTime,
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Create Task",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, AppState appState, AppTask task) {
    final controller = TextEditingController(text: task.title);
    TimeOfDay? selectedTime = task.time;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            top: 32,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Edit Task (Long Press)",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(ctx).textTheme.titleLarge?.color,
                  )),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Task title",
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
                    child: Text(
                      selectedTime == null
                          ? "Select Reminder Time (Optional)"
                          : "Time: ${selectedTime!.format(context)}",
                      style: TextStyle(
                        color: selectedTime == null ? Colors.grey : AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (selectedTime != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          selectedTime = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      appState.updateTask(task.id, controller.text, selectedTime);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Save Changes",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final AppTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onToggle,
        onLongPress: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                width: 28,
                height: 28,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppColors.primaryGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.primaryGreen
                      : (Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.4) ??
                          Colors.grey),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.isCompleted
                          ? Colors.grey
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    child: Text(task.title),
                  ),
                  if (task.time != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          task.time!.format(context),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 22, color: Colors.red.withValues(alpha: 0.4)),
                onPressed: onDelete,
                tooltip: "Delete Task",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfettiWidget extends AnimatedWidget {
  const ConfettiWidget({super.key, required AnimationController controller})
      : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as AnimationController;
    return CustomPaint(
      painter: ConfettiPainter(animation.value),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;

  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;

    final paint = Paint();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxDist = size.width * 0.8;

    for (int i = 0; i < 50; i++) {
      // Deterministic random based on index
      final r = Random(i);
      final angle = r.nextDouble() * 2 * pi;
      final dist = r.nextDouble() * maxDist * progress;
      final radius = r.nextDouble() * 5 + 2;

      // Color
      final colorFn = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.purple
      ];
      paint.color =
          colorFn[r.nextInt(colorFn.length)].withValues(alpha: 1 - progress);

      final x = centerX + cos(angle) * dist;
      final y =
          centerY + sin(angle) * dist - (progress * 100); // Move up slightly

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw "Well Done!" text
    if (progress < 0.8) {
      final textSpan = TextSpan(
        text: 'Well Done!',
        style: TextStyle(
          color: AppColors.primaryGreen.withValues(alpha: (1 - progress).clamp(0, 1)),
          fontSize: 40 * (0.5 + progress), // Scale up
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(centerX - textPainter.width / 2,
              centerY - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
