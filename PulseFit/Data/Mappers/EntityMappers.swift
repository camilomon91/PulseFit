import Foundation

extension WorkoutRow {
    func toDomain(exercises: [Exercise]) -> Workout {
        Workout(id: id, userID: user_id, name: name, notes: notes, createdAt: created_at, exercises: exercises)
    }
}

extension ExerciseRow {
    func toDomain() -> Exercise {
        Exercise(id: id, workoutID: workout_id, name: name, targetSets: target_sets, targetReps: target_reps, createdAt: created_at)
    }
}

extension MealRow {
    func toDomain() -> Meal {
        Meal(id: id, userID: user_id, name: name, calories: calories, protein: protein, carbs: carbs, fats: fats, createdAt: created_at)
    }
}

extension CheckInRow {
    func toDomain() -> CheckIn {
        CheckIn(id: id, userID: user_id, workoutID: workout_id, startedAt: started_at, endedAt: ended_at)
    }
}

extension ExerciseSetRow {
    func toDomain() -> ExerciseSet {
        ExerciseSet(
            id: id,
            checkInID: check_in_id,
            exerciseID: exercise_id,
            setIndex: set_index,
            reps: reps,
            weight: weight,
            startedAt: started_at,
            endedAt: ended_at,
            restSecondsBeforeSet: rest_seconds_before_set
        )
    }
}

extension MealLogRow {
    func toDomain() -> MealLog {
        MealLog(id: id, userID: user_id, mealID: meal_id, eatenAt: eaten_at)
    }
}
