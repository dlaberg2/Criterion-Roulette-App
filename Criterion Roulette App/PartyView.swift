import SwiftUI

struct PartyView: View {
    @ObservedObject var viewModel: PartyViewModel
    @Binding var selectedTab: ContentView.Tab
    @State private var playerNameInput: String = ""
    @State private var shakeInput: Bool = false
    @FocusState private var inputFocused: Bool

    let avatarColors: [Color] = [
        Color(hex: "#4A90D9"), Color(hex: "#5DC86A"),
        Color(hex: "#E8503A"), Color(hex: "#B85CE8")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Section header
                SectionLabel("Party Members")

                // Player input
                HStack(spacing: 10) {
                    TextField("Enter player name...", text: $playerNameInput)
                        .textFieldStyle(.plain)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.ffText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.ffPanel2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(inputFocused ? Color.ffGoldDim : Color.ffBorder, lineWidth: 1)
                        )
                        .cornerRadius(6)
                        .focused($inputFocused)
                        .disabled(!viewModel.canAddPlayer)
                        .onSubmit { tryAddPlayer() }
                        .modifier(ShakeEffect(trigger: shakeInput))

                    Button(action: tryAddPlayer) {
                        Text("Add")
                            .font(.custom("Georgia", size: 13).bold())
                            .tracking(1)
                            .foregroundColor(.ffGold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.ffPanel2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.ffGoldDim, lineWidth: 1)
                            )
                            .cornerRadius(6)
                    }
                    .disabled(!viewModel.canAddPlayer)
                    .buttonStyle(.plain)
                }

                // Player list
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.players.enumerated()), id: \.element.id) { index, player in
                        PlayerChipView(
                            player: player,
                            color: avatarColors[index % avatarColors.count],
                            onRemove: { viewModel.removePlayer(player) }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                }

                // Status note
                HStack {
                    Spacer()
                    statusText
                    Spacer()
                }

                Spacer(minLength: 24)

                // Roll button
                RollButton(
                    isEnabled: viewModel.isPartyFull,
                    isRolling: viewModel.isRolling
                ) {
                    viewModel.rollAssignment()
                    withAnimation { selectedTab = .assignment }
                }
            }
            .padding(20)
        }
    }

    @ViewBuilder
    private var statusText: some View {
        if viewModel.isPartyFull {
            Text("Party ready — roll for your dungeon!")
                .font(.custom("Georgia", size: 13).italic())
                .foregroundColor(.ffGoldDim)
        } else {
            Text("\(viewModel.players.count)/4 players · add \(4 - viewModel.players.count) more")
                .font(.custom("Georgia", size: 13).italic())
                .foregroundColor(.ffMuted)
        }
    }

    private func tryAddPlayer() {
        guard !playerNameInput.trimmingCharacters(in: .whitespaces).isEmpty,
              viewModel.canAddPlayer
        else {
            withAnimation(.default) { shakeInput.toggle() }
            return
        }
        viewModel.addPlayer(name: playerNameInput)
        playerNameInput = ""
    }
}

// MARK: - Player Chip

struct PlayerChipView: View {
    let player: Player
    let color: Color
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            // Avatar
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .overlay(Circle().stroke(color.opacity(0.3), lineWidth: 1))
                Text(player.initials)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(color)
            }
            .frame(width: 32, height: 32)

            Text(player.name)
                .font(.custom("Georgia", size: 16))
                .foregroundColor(.ffText)

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.ffMuted)
            }
            .buttonStyle(.plain)
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

// MARK: - Roll Button

struct RollButton: View {
    let isEnabled: Bool
    let isRolling: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isRolling {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .rotationEffect(.degrees(isRolling ? 360 : 0))
                        .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: isRolling)
                }
                Text(isRolling ? "Rolling..." : "✦  Roll for Dungeon  ✦")
                    .font(.custom("Georgia", size: 14).bold())
                    .tracking(2)
            }
            .foregroundColor(isEnabled ? .ffGold : .ffMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.ffPanel2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isEnabled ? Color.ffGoldDim : Color.ffBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isRolling)
        .opacity(isEnabled ? 1 : 0.4)
    }
}

// MARK: - Shake Modifier

struct ShakeEffect: AnimatableModifier {
    var trigger: Bool
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { _ in
                withAnimation(.easeInOut(duration: 0.05).repeatCount(5, autoreverses: true)) {
                    offset = 6
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    offset = 0
                }
            }
    }

    var animatableData: EmptyAnimatableData { EmptyAnimatableData() }
}

// MARK: - Section Label

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .medium))
            .tracking(2.5)
            .foregroundColor(.ffMuted)
    }
}
