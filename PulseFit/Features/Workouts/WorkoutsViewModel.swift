import Foundation

@MainActor
final class WorkoutsViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []

    private let exercisesRepository: ExercisesRepository

    init(exercisesRepository: ExercisesRepository) {
        self.exercisesRepository = exercisesRepository
    }

    func load(userID: UUID) async {
        exercises = await exercisesRepository.fetchLibrary(userID: userID)
    }
}
