import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class ExerciseScreen extends ConsumerWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutDays = ref.watch(workoutDaysNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWorkoutDayDialog(context, ref),
          ),
        ],
      ),
      body: workoutDays.isEmpty
          ? _buildEmptyState(context, ref)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workoutDays.length,
              itemBuilder: (context, index) {
                final day = workoutDays[index];
                return _buildWorkoutDayCard(context, ref, day);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Workout Plans Yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first workout plan to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddWorkoutDayDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Create Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutDayCard(BuildContext context, WidgetRef ref, WorkoutDay day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          day.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${day.exercises.length} exercises',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditWorkoutDayDialog(context, ref, day),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
              onPressed: () => _showDeleteConfirmation(context, ref, day),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (day.exercises.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No exercises yet. Add some!',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: day.exercises.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final exercise = day.exercises[index];
                      return _buildExerciseTile(context, ref, day, exercise);
                    },
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddExerciseDialog(context, ref, day.id),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Exercise'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTile(BuildContext context, WidgetRef ref, WorkoutDay day, Exercise exercise) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Text(
          '${day.exercises.indexOf(exercise) + 1}',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        exercise.name,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${exercise.sets} sets - ${exercise.details}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _showEditExerciseDialog(context, ref, day.id, exercise),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
            onPressed: () => _showDeleteExerciseConfirmation(context, ref, day.id, exercise.id),
          ),
        ],
      ),
    );
  }

  void _showAddWorkoutDayDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Workout Plan'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Plan Name',
            hintText: 'e.g., Push Day, Leg Day',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(workoutDaysNotifierProvider.notifier).addWorkoutDay(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditWorkoutDayDialog(BuildContext context, WidgetRef ref, WorkoutDay day) {
    final controller = TextEditingController(text: day.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Workout Plan'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Plan Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(workoutDaysNotifierProvider.notifier).updateWorkoutDay(day.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, WorkoutDay day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout Plan'),
        content: Text('Are you sure you want to delete "${day.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(workoutDaysNotifierProvider.notifier).deleteWorkoutDay(day.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context, WidgetRef ref, String workoutDayId) {
    final nameController = TextEditingController();
    final setsController = TextEditingController(text: '3');
    final detailsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'e.g., Bench Press',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: setsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Sets',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsController,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  hintText: 'e.g., 8-12 reps, RPE 8',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final exercise = Exercise(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  sets: int.tryParse(setsController.text) ?? 3,
                  details: detailsController.text,
                );
                ref.read(workoutDaysNotifierProvider.notifier).addExercise(workoutDayId, exercise);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditExerciseDialog(BuildContext context, WidgetRef ref, String workoutDayId, Exercise exercise) {
    final nameController = TextEditingController(text: exercise.name);
    final setsController = TextEditingController(text: exercise.sets.toString());
    final detailsController = TextEditingController(text: exercise.details);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: setsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Sets',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsController,
                decoration: const InputDecoration(
                  labelText: 'Details',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref.read(workoutDaysNotifierProvider.notifier).updateExercise(
                  workoutDayId,
                  exercise.id,
                  name: nameController.text,
                  sets: int.tryParse(setsController.text),
                  details: detailsController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteExerciseConfirmation(BuildContext context, WidgetRef ref, String workoutDayId, String exerciseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: const Text('Are you sure you want to delete this exercise?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(workoutDaysNotifierProvider.notifier).deleteExercise(workoutDayId, exerciseId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
