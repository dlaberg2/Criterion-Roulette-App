import Foundation
import SwiftUI

// MARK: - Role

enum Role: String, CaseIterable, Codable, Identifiable {
    case tank    = "Tank"
    case healer  = "Healer"
    case melee   = "Melee DPS"
    case ranged  = "Ranged DPS"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .tank:   return "shield.fill"
        case .healer: return "cross.fill"
        case .melee:  return "flame.fill"
        case .ranged: return "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .tank:   return Color(hex: "#3A8FE8")
        case .healer: return Color(hex: "#5DC86A")
        case .melee:  return Color(hex: "#E8503A")
        case .ranged: return Color(hex: "#B85CE8")
        }
    }

    var shortName: String {
        switch self {
        case .tank:   return "TANK"
        case .healer: return "HEAL"
        case .melee:  return "MELEE"
        case .ranged: return "RANGE"
        }
    }
}

// MARK: - Dungeon

struct Dungeon: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let difficulty: String
    let zone: String

    init(id: UUID = UUID(), name: String, difficulty: String, zone: String) {
        self.id = id
        self.name = name
        self.difficulty = difficulty
        self.zone = zone
    }
}

// MARK: - All Criterion Dungeons

extension Dungeon {
    static let all: [Dungeon] = [
        Dungeon(name: "Another Sildihn Subterrane",
                difficulty: "Criterion",
                zone: "Old Sharlayan"),
        Dungeon(name: "Another Sildihn Subterrane (Savage)",
                difficulty: "Criterion Savage",
                zone: "Old Sharlayan"),
        Dungeon(name: "Another Mount Rokkon",
                difficulty: "Criterion",
                zone: "Garlemald"),
        Dungeon(name: "Another Mount Rokkon (Savage)",
                difficulty: "Criterion Savage",
                zone: "Garlemald"),
        Dungeon(name: "Another Aloalo Island",
                difficulty: "Criterion",
                zone: "Solution Nine"),
        Dungeon(name: "Another Aloalo Island (Savage)",
                difficulty: "Criterion Savage",
                zone: "Solution Nine"),
    ]
}

// MARK: - Player

struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }

    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Role Assignment

struct RoleAssignment: Codable, Identifiable {
    let id: UUID
    let role: Role
    let player: Player

    init(id: UUID = UUID(), role: Role, player: Player) {
        self.id = id
        self.role = role
        self.player = player
    }
}

// MARK: - Run

struct Run: Identifiable, Codable {
    let id: UUID
    let dungeon: Dungeon
    let assignments: [RoleAssignment]
    let date: Date

    init(id: UUID = UUID(), dungeon: Dungeon, assignments: [RoleAssignment], date: Date = .now) {
        self.id = id
        self.dungeon = dungeon
        self.assignments = assignments
        self.date = date
    }

    func assignment(for role: Role) -> Player? {
        assignments.first(where: { $0.role == role })?.player
    }
}
