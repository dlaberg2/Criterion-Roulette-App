import Foundation
import SwiftUI

@MainActor
class PartyViewModel: ObservableObject {

    // MARK: - Published State

    @Published var players: [Player] = []
    @Published var currentRun: Run?
    @Published var runHistory: [Run] = []
    @Published var isRolling: Bool = false
    @Published var lastSaved: Bool = false

    // MARK: - Persistence Key

    private let historyKey = "ff14_criterion_run_history"

    // MARK: - Init

    init() {
        loadHistory()
    }

    // MARK: - Party Management

    var canAddPlayer: Bool { players.count < 4 }
    var isPartyFull: Bool { players.count == 4 }

    func addPlayer(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              canAddPlayer,
              !players.contains(where: { $0.name.lowercased() == trimmed.lowercased() })
        else { return }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            players.append(Player(name: trimmed))
        }
    }

    func removePlayer(_ player: Player) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            players.removeAll { $0.id == player.id }
        }
    }

    func movePlayer(from source: IndexSet, to destination: Int) {
        players.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Roll Logic

    func rollAssignment() {
        guard isPartyFull else { return }

        isRolling = true
        lastSaved = false

        // Brief animation delay for effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }

            let dungeon = Dungeon.all.randomElement()!
            let shuffledPlayers = self.players.shuffled()
            let roles = Role.allCases

            let assignments = zip(roles, shuffledPlayers).map { role, player in
                RoleAssignment(role: role, player: player)
            }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self.currentRun = Run(dungeon: dungeon, assignments: assignments)
                self.isRolling = false
            }
        }
    }

    // MARK: - Save Run

    func saveCurrentRun() {
        guard let run = currentRun else { return }
        withAnimation {
            runHistory.insert(run, at: 0)
            lastSaved = true
        }
        persistHistory()
    }

    var currentRunAlreadySaved: Bool {
        guard let run = currentRun else { return false }
        return runHistory.contains(where: { $0.id == run.id })
    }

    // MARK: - History Management

    func deleteRun(at offsets: IndexSet) {
        runHistory.remove(atOffsets: offsets)
        persistHistory()
    }

    func clearHistory() {
        withAnimation {
            runHistory.removeAll()
        }
        persistHistory()
    }

    // MARK: - Persistence

    private func persistHistory() {
        do {
            let data = try JSONEncoder().encode(runHistory)
            UserDefaults.standard.set(data, forKey: historyKey)
        } catch {
            print("Failed to save run history: \(error)")
        }
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return }
        do {
            runHistory = try JSONDecoder().decode([Run].self, from: data)
        } catch {
            print("Failed to load run history: \(error)")
        }
    }
}
