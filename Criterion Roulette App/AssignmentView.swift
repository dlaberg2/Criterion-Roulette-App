import SwiftUI

struct AssignmentView: View {
    @ObservedObject var viewModel: PartyViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let run = viewModel.currentRun {
                    runContent(run: run)
                } else {
                    emptyState
                }
            }
            .padding(20)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "hourglass")
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundColor(.ffMuted)
                .padding(.top, 60)

            Text("No Assignment Yet")
                .font(.custom("Georgia", size: 16).bold())
                .foregroundColor(.ffMuted)
                .tracking(1)

            Text("Add 4 players and roll for a dungeon\nfrom the Party tab")
                .font(.custom("Georgia", size: 13).italic())
                .foregroundColor(.ffMuted.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Run Content

    @ViewBuilder
    private func runContent(run: Run) -> some View {
        // Dungeon Card
        DungeonCard(dungeon: run.dungeon)
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .opacity
            ))

        // Role Assignment Cards
        VStack(spacing: 10) {
            ForEach(Role.allCases) { role in
                if let player = run.assignment(for: role) {
                    RoleAssignmentRow(role: role, player: player)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
        }

        Spacer(minLength: 20)

        // Action Buttons
        VStack(spacing: 10) {
            // Save button
            Button(action: viewModel.saveCurrentRun) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.lastSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                        .font(.system(size: 15))
                    Text(viewModel.lastSaved ? "Run Saved!" : "Save This Run")
                        .font(.custom("Georgia", size: 14).bold())
                        .tracking(1)
                }
                .foregroundColor(viewModel.lastSaved ? Color.ffHeal : .ffGold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.ffPanel2)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            viewModel.lastSaved ? Color.ffHeal.opacity(0.4) : Color.ffGoldDim,
                            lineWidth: 1
                        )
                )
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.currentRunAlreadySaved)

            // Reroll button
            Button(action: viewModel.rollAssignment) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14))
                    Text("Reroll Assignment")
                        .font(.custom("Georgia", size: 14))
                        .tracking(1)
                }
                .foregroundColor(.ffMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color.ffPanel2)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.ffBorder, lineWidth: 1)
                )
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Color Extension for Role Access

extension Color {
    static let ffHeal = Color(hex: "#5DC86A")
}

// MARK: - Dungeon Card

struct DungeonCard: View {
    let dungeon: Dungeon

    private var isSavage: Bool { dungeon.difficulty.lowercased().contains("savage") }

    var body: some View {
        VStack(spacing: 8) {
            // Badge
            Text("Criterion Dungeon")
                .font(.system(size: 9, weight: .medium))
                .tracking(2.5)
                .foregroundColor(.ffCrystal)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.ffCrystal.opacity(0.35), lineWidth: 1)
                )

            Text(dungeon.name)
                .font(.custom("Georgia", size: 18).bold())
                .foregroundColor(.ffGoldLight)
                .multilineTextAlignment(.center)
                .tracking(0.5)

            HStack(spacing: 6) {
                Text(dungeon.difficulty)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSavage ? Color(hex: "#E8503A") : .ffMuted)
                    .tracking(1)

                if !dungeon.zone.isEmpty {
                    Text("·")
                        .foregroundColor(.ffMuted)
                    Text(dungeon.zone)
                        .font(.system(size: 11))
                        .foregroundColor(.ffMuted)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            LinearGradient(
                colors: [
                    Color.ffCrystal.opacity(0.07),
                    Color(hex: "#8C6FD4").opacity(0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.ffBorder, lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

// MARK: - Role Assignment Row

struct RoleAssignmentRow: View {
    let role: Role
    let player: Player

    var body: some View {
        HStack(spacing: 14) {
            // Role icon circle
            ZStack {
                Circle()
                    .fill(role.color.opacity(0.12))
                    .overlay(Circle().stroke(role.color.opacity(0.3), lineWidth: 1))
                Image(systemName: role.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(role.color)
            }
            .frame(width: 42, height: 42)

            // Role + player info
            VStack(alignment: .leading, spacing: 2) {
                Text(role.shortName)
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(role.color)

                Text(player.name)
                    .font(.custom("Georgia", size: 17))
                    .foregroundColor(.ffText)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.ffPanel2)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.ffBorder, lineWidth: 1)
        )
        .cornerRadius(6)
    }
}
