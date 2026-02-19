import Foundation
import Combine

@MainActor
final class WorkoutController: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var exercisesByWorkout: [UUID: [Exercise]] = [:]
    @Published var errorMessage: String?

    private let dataService = DataService()

    func loadWorkouts() async {
        do {
            workouts = try await dataService.fetchWorkouts()
            for workout in workouts {
                exercisesByWorkout[workout.id] = try await dataService.fetchExercises(workoutId: workout.id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addWorkout(name: String, notes: String?) async {
        do {
            try await dataService.createWorkout(name: name, notes: notes)
            await loadWorkouts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveWorkout(_ workout: Workout) async {
        do {
            try await dataService.updateWorkout(workout)
            await loadWorkouts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeWorkout(id: UUID) async {
        do {
            try await dataService.deleteWorkout(id: id)
            await loadWorkouts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addExercise(workoutId: UUID, name: String, sets: Int, reps: Int) async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Exercise name can't be empty."
            return
        }

        do {
            try await dataService.addExercise(workoutId: workoutId, name: trimmedName, targetSets: sets, targetReps: reps)
            exercisesByWorkout[workoutId] = try await dataService.fetchExercises(workoutId: workoutId)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveExercise(_ exercise: Exercise) async {
        do {
            try await dataService.updateExercise(exercise)
            exercisesByWorkout[exercise.workoutId] = try await dataService.fetchExercises(workoutId: exercise.workoutId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeExercise(_ exercise: Exercise) async {
        do {
            try await dataService.deleteExercise(id: exercise.id)
            exercisesByWorkout[exercise.workoutId] = try await dataService.fetchExercises(workoutId: exercise.workoutId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
