import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PartyViewModel()
    @State private var selectedTab: Tab = .party

    enum Tab { case party, assignment, history }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.ffDark.ignoresSafeArea()

            // Star background
            StarFieldView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                AppHeaderView()

                // Tab content
                TabView(selection: $selectedTab) {
                    PartyView(viewModel: viewModel, selectedTab: $selectedTab)
                        .tag(Tab.party)

                    AssignmentView(viewModel: viewModel)
                        .tag(Tab.assignment)

                    HistoryView(viewModel: viewModel)
                        .tag(Tab.history)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: selectedTab)

                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Star Field Background

struct StarFieldView: View {
    let stars: [(CGFloat, CGFloat, CGFloat)] = (0..<40).map { _ in
        (CGFloat.random(in: 0...1),
         CGFloat.random(in: 0...1),
         CGFloat.random(in: 0.1...0.4))
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<stars.count, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(stars[i].2))
                    .frame(width: 2, height: 2)
                    .position(
                        x: stars[i].0 * geo.size.width,
                        y: stars[i].1 * geo.size.height
                    )
            }
            // Subtle crystal glow overlays
            RadialGradient(
                colors: [Color.ffCrystal.opacity(0.07), .clear],
                center: .init(x: 0.2, y: 0.3),
                startRadius: 0,
                endRadius: geo.size.width * 0.5
            )
            RadialGradient(
                colors: [Color(hex: "#8C6FD4").opacity(0.06), .clear],
                center: .init(x: 0.8, y: 0.7),
                startRadius: 0,
                endRadius: geo.size.width * 0.5
            )
        }
    }
}

// MARK: - App Header

struct AppHeaderView: View {
    var body: some View {
        VStack(spacing: 6) {
            CrystalIcon()
                .frame(width: 36, height: 36)
                .padding(.top, 8)

            Text("CRITERION ROULETTE")
                .font(.custom("Georgia", size: 16).bold())
                .tracking(3)
                .foregroundColor(.ffGold)

            Text("Final Fantasy XIV")
                .font(.custom("Georgia", size: 11))
                .tracking(1.5)
                .foregroundColor(.ffMuted)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .ffGoldDim, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 100, height: 1)
                .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity)
        .background(Color.ffPanel)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.ffBorder)
                .frame(height: 1)
        }
    }
}

// MARK: - Crystal SVG-style Icon

struct CrystalIcon: View {
    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let r = min(cx, cy) - 2

            // Outer hexagon
            let outerPoints = hexPoints(cx: cx, cy: cy, r: r)
            var outerPath = Path()
            outerPath.move(to: outerPoints[0])
            outerPoints.dropFirst().forEach { outerPath.addLine(to: $0) }
            outerPath.closeSubpath()
            context.stroke(outerPath, with: .color(.ffGold), lineWidth: 1)

            // Inner hexagon
            let innerPoints = hexPoints(cx: cx, cy: cy, r: r * 0.6)
            var innerPath = Path()
            innerPath.move(to: innerPoints[0])
            innerPoints.dropFirst().forEach { innerPath.addLine(to: $0) }
            innerPath.closeSubpath()
            context.fill(innerPath, with: .color(Color.ffCrystal.opacity(0.15)))
            context.stroke(innerPath, with: .color(.ffCrystal.opacity(0.6)), lineWidth: 0.5)

            // Lines from center to outer vertices (every other)
            let strokeStyle = Color.ffGold.opacity(0.35)
            for i in [0, 2, 4] {
                var linePath = Path()
                linePath.move(to: CGPoint(x: cx, y: cy))
                linePath.addLine(to: outerPoints[i])
                context.stroke(linePath, with: .color(strokeStyle), lineWidth: 0.5)
            }

            // Center dot
            let dotRect = CGRect(x: cx - 2.5, y: cy - 2.5, width: 5, height: 5)
            context.fill(Path(ellipseIn: dotRect), with: .color(.ffGold.opacity(0.8)))
        }
    }

    private func hexPoints(cx: CGFloat, cy: CGFloat, r: CGFloat) -> [CGPoint] {
        (0..<6).map { i in
            let angle = Double(i) * .pi / 3 - .pi / 2
            return CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: ContentView.Tab

    var body: some View {
        HStack(spacing: 0) {
            tabButton(label: "Party", icon: "person.3.fill", tab: .party)
            tabButton(label: "Assignment", icon: "dice.fill", tab: .assignment)
            tabButton(label: "Run Log", icon: "scroll.fill", tab: .history)
        }
        .background(Color.ffPanel)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.ffBorder).frame(height: 1)
        }
    }

    @ViewBuilder
    private func tabButton(label: String, icon: String, tab: ContentView.Tab) -> some View {
        let isActive = selectedTab == tab
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
            }
            .foregroundColor(isActive ? .ffGold : .ffMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                isActive
                ? Color.ffGold.opacity(0.05)
                : Color.clear
            )
            .overlay(alignment: .top) {
                if isActive {
                    Rectangle()
                        .fill(Color.ffGold)
                        .frame(height: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
