import Foundation
import SwiftUI
import Combine

@MainActor
class PartyViewModel: ObservableObject {

    // MARK: - Published State

    @Published var players: [Player] = []
    @Published var currentRun: Run?
    @Published var sessions: [Session] = []
    @Published var isRolling: Bool = false
    @Published var lastSaved: Bool = false

    // MARK: - Active Session
    // The session being built during the current sitting. Committed to sessions[] on end/save.

    private(set) var activeSession: Session?

    // MARK: - Persistence Key

    private let sessionsKey = "ff14_criterion_sessions"

    // MARK: - Init

    init() {
        loadSessions()
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

        // If party composition changes, close the active session so the next
        // save starts a fresh one with the new roster.
        if activeSession != nil {
            commitActiveSession()
        }
    }

    func removePlayer(_ player: Player) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            players.removeAll { $0.id == player.id }
        }
        if activeSession != nil {
            commitActiveSession()
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

    // MARK: - Save Run into Active Session

    func saveCurrentRun() {
        guard let run = currentRun else { return }

        if activeSession == nil {
            // Start a brand-new session for this party
            activeSession = Session(players: players, runs: [run])
        } else {
            activeSession?.runs.append(run)
        }

        // Upsert active session at the top of the sessions list
        if let active = activeSession {
            if let idx = sessions.firstIndex(where: { $0.id == active.id }) {
                sessions[idx] = active
            } else {
                withAnimation { sessions.insert(active, at: 0) }
            }
        }

        withAnimation { lastSaved = true }
        persistSessions()
    }

    var currentRunAlreadySaved: Bool {
        guard let run = currentRun else { return false }
        return activeSession?.runs.contains(where: { $0.id == run.id }) ?? false
    }

    // MARK: - End Session Manually

    func endSession() {
        commitActiveSession()
    }

    private func commitActiveSession() {
        activeSession = nil
        // Sessions list already up to date — nothing extra needed
    }

    // MARK: - History Management

    func deleteSession(at offsets: IndexSet) {
        // If we're deleting the active session, clear it too
        for idx in offsets {
            if sessions[idx].id == activeSession?.id {
                activeSession = nil
            }
        }
        withAnimation { sessions.remove(atOffsets: offsets) }
        persistSessions()
    }

    func clearHistory() {
        withAnimation { sessions.removeAll() }
        activeSession = nil
        persistSessions()
    }

    // MARK: - Persistence

    private func persistSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: sessionsKey)
        } catch {
            print("Failed to save sessions: \(error)")
        }
    }

    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey) else { return }
        do {
            sessions = try JSONDecoder().decode([Session].self, from: data)
        } catch {
            print("Failed to load sessions: \(error)")
        }
    }
}
