import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: PartyViewModel
    @State private var expandedRunID: UUID?
    @State private var showClearConfirm: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionLabel("Run History")

                if viewModel.runHistory.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 10) {
                        ForEach(viewModel.runHistory) { run in
                            RunHistoryCard(
                                run: run,
                                isExpanded: expandedRunID == run.id
                            ) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    expandedRunID = expandedRunID == run.id ? nil : run.id
                                }
                            }
                        }
                        .onDelete { offsets in
                            viewModel.deleteRun(at: offsets)
                        }
                    }

                    // Clear all button
                    Button {
                        showClearConfirm = true
                    } label: {
                        Text("Clear All Runs")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(1.5)
                            .foregroundColor(.ffMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(hex: "#B85CE8").opacity(0.2), lineWidth: 1)
                            )
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                    .confirmationDialog(
                        "Clear all run history?",
                        isPresented: $showClearConfirm,
                        titleVisibility: .visible
                    ) {
                        Button("Clear All", role: .destructive) {
                            viewModel.clearHistory()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundColor(.ffMuted)
                .padding(.top, 40)

            Text("No Runs Recorded")
                .font(.custom("Georgia", size: 16).bold())
                .foregroundColor(.ffMuted)
                .tracking(1)

            Text("Complete a run and save it\nto see it here")
                .font(.custom("Georgia", size: 13).italic())
                .foregroundColor(.ffMuted.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Run History Card

struct RunHistoryCard: View {
    let run: Run
    let isExpanded: Bool
    let onTap: () -> Void

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d · h:mm a"
        return formatter.string(from: run.date)
    }

    private var isSavage: Bool {
        run.dungeon.difficulty.lowercased().contains("savage")
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main row — always visible
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(run.dungeon.name)
                                .font(.custom("Georgia", size: 14).bold())
                                .foregroundColor(.ffGoldLight)
                                .multilineTextAlignment(.leading)

                            Text(run.dungeon.difficulty)
                                .font(.system(size: 10, weight: .medium))
                                .tracking(1)
                                .foregroundColor(isSavage ? Color(hex: "#E8503A") : .ffMuted)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(formattedDate)
                                .font(.system(size: 11))
                                .foregroundColor(.ffMuted)

                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.ffMuted)
                        }
                    }

                    // Role pills
                    HStack(spacing: 6) {
                        ForEach(Role.allCases) { role in
                            if let player = run.assignment(for: role) {
                                RolePill(role: role, playerName: player.name)
                            }
                        }
                    }
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            // Expanded detail
            if isExpanded {
                Divider()
                    .background(Color.ffBorder)

                VStack(spacing: 0) {
                    ForEach(Role.allCases) { role in
                        if let player = run.assignment(for: role) {
                            ExpandedRoleRow(role: role, player: player)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(Color.ffPanel2)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isExpanded ? Color.ffGoldDim : Color.ffBorder,
                    lineWidth: isExpanded ? 1 : 1
                )
        )
        .cornerRadius(8)
        .clipped()
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
