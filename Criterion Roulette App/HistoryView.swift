import SwiftUI

// MARK: - History View (Session List)

struct HistoryView: View {
    @ObservedObject var viewModel: PartyViewModel
    @State private var expandedSessionID: UUID?
    @State private var showClearConfirm: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionLabel("Session History")

                if viewModel.sessions.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 10) {
                        ForEach(viewModel.sessions) { session in
                            SessionCard(
                                session: session,
                                isActive: session.id == viewModel.activeSession?.id,
                                isExpanded: expandedSessionID == session.id
                            ) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    expandedSessionID = expandedSessionID == session.id ? nil : session.id
                                }
                            }
                        }
                        .onDelete { offsets in
                            viewModel.deleteSession(at: offsets)
                        }
                    }

                    // Clear all
                    Button { showClearConfirm = true } label: {
                        Text("Clear All Sessions")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(1.5)
                            .foregroundColor(.ffMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(hex: "#B85CE8").opacity(0.2), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                    .confirmationDialog("Clear all session history?", isPresented: $showClearConfirm, titleVisibility: .visible) {
                        Button("Clear All", role: .destructive) { viewModel.clearHistory() }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            .padding(20)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundColor(.ffMuted)
                .padding(.top, 40)
            Text("No Sessions Recorded")
                .font(.custom("Georgia", size: 16).bold())
                .foregroundColor(.ffMuted)
                .tracking(1)
            Text("Save a run to begin your first session")
                .font(.custom("Georgia", size: 13).italic())
                .foregroundColor(.ffMuted.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Session Card

struct SessionCard: View {
    let session: Session
    let isActive: Bool
    let isExpanded: Bool
    let onTap: () -> Void

    @State private var expandedRunID: UUID?

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy · h:mm a"
        return formatter.string(from: session.date)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Session header row
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                if isActive {
                                    Text("ACTIVE")
                                        .font(.system(size: 8, weight: .bold))
                                        .tracking(2)
                                        .foregroundColor(Color(hex: "#5DC86A"))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color(hex: "#5DC86A").opacity(0.12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 3)
                                                .stroke(Color(hex: "#5DC86A").opacity(0.3), lineWidth: 1)
                                        )
                                        .cornerRadius(3)
                                }
                                Text(formattedDate)
                                    .font(.system(size: 11))
                                    .foregroundColor(.ffMuted)
                            }

                            Text(session.playerNames)
                                .font(.custom("Georgia", size: 15).bold())
                                .foregroundColor(.ffGoldLight)
                                .lineLimit(1)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(session.runs.count) \(session.runs.count == 1 ? "run" : "runs")")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.ffCrystal)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.ffCrystal.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color.ffCrystal.opacity(0.25), lineWidth: 1)
                                )
                                .cornerRadius(3)

                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.ffMuted)
                        }
                    }

                    // Dungeon pills
                    if !session.runs.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(uniqueDungeons(in: session)) { dungeon in
                                    DungeonPill(dungeon: dungeon)
                                }
                            }
                        }
                    }
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            // Expanded: individual runs
            if isExpanded {
                Divider().background(Color.ffBorder)

                VStack(spacing: 8) {
                    ForEach(Array(session.runs.enumerated()), id: \.element.id) { index, run in
                        RunRowInSession(
                            run: run,
                            runNumber: index + 1,
                            isExpanded: expandedRunID == run.id
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                expandedRunID = expandedRunID == run.id ? nil : run.id
                            }
                        }
                    }
                }
                .padding(12)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(Color.ffPanel2)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isActive ? Color(hex: "#5DC86A").opacity(0.4) :
                    isExpanded ? Color.ffGoldDim : Color.ffBorder,
                    lineWidth: 1
                )
        )
        .cornerRadius(8)
        .clipped()
    }

    private func uniqueDungeons(in session: Session) -> [Dungeon] {
        var seen = Set<UUID>()
        return session.runs.compactMap { run in
            guard !seen.contains(run.dungeon.id) else { return nil }
            seen.insert(run.dungeon.id)
            return run.dungeon
        }
    }
}

// MARK: - Run Row Inside a Session

struct RunRowInSession: View {
    let run: Run
    let runNumber: Int
    let isExpanded: Bool
    let onTap: () -> Void

    private var isSavage: Bool { run.dungeon.difficulty.lowercased().contains("savage") }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 10) {
                    Text("#\(runNumber)")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundColor(.ffMuted)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(run.dungeon.name)
                            .font(.custom("Georgia", size: 13).bold())
                            .foregroundColor(.ffGoldLight)
                            .lineLimit(1)
                        Text(run.dungeon.difficulty)
                            .font(.system(size: 10))
                            .tracking(0.8)
                            .foregroundColor(isSavage ? Color(hex: "#E8503A") : .ffMuted)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.ffMuted)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.ffPanel)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Role.allCases) { role in
                        if let player = run.assignment(for: role) {
                            ExpandedRoleRow(role: role, player: player)
                                .padding(.horizontal, 12)
                        }
                    }
                }
                .background(Color.ffPanel.opacity(0.6))
                .cornerRadius(6)
                .padding(.top, 2)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

// MARK: - Dungeon Pill

struct DungeonPill: View {
    let dungeon: Dungeon
    private var isSavage: Bool { dungeon.difficulty.lowercased().contains("savage") }

    var body: some View {
        Text(dungeon.name)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(isSavage ? Color(hex: "#E8503A") : .ffCrystal)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background((isSavage ? Color(hex: "#E8503A") : Color.ffCrystal).opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke((isSavage ? Color(hex: "#E8503A") : Color.ffCrystal).opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(3)
    }
}

// MARK: - Role Pill

struct RolePill: View {
    let role: Role
    let playerName: String

    var body: some View {
        Text(playerName)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(role.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(role.color.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(role.color.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(3)
    }
}

// MARK: - Expanded Role Row

struct ExpandedRoleRow: View {
    let role: Role
    let player: Player

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: role.icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(role.color)
                .frame(width: 20)

            Text(role.shortName)
                .font(.system(size: 10, weight: .semibold))
                .tracking(2)
                .foregroundColor(role.color)
                .frame(width: 52, alignment: .leading)

            Text(player.name)
                .font(.custom("Georgia", size: 14))
                .foregroundColor(.ffText)

            Spacer()
        }
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) {
            if role != Role.allCases.last {
                Rectangle()
                    .fill(Color.ffBorder.opacity(0.5))
                    .frame(height: 0.5)
            }
        }
    }
}
