# Criterion Roulette — FFXIV iOS App

A Final Fantasy XIV companion app that randomly assigns party members to roles and selects a Criterion dungeon for your run.

---

## Features

- **Party Builder** — Add up to 4 named players
- **Random Assignment** — Picks a random Criterion dungeon and assigns each player a unique role (Tank, Healer, Melee DPS, Ranged DPS)
- **Run Log** — Saves every run with dungeon, roles, players, and timestamp; persisted across app launches via UserDefaults
- **FF14 Aesthetic** — Dark crystal theme with gold accents matching the game's UI language

---

## Project Structure

```
CriterionRoulette/
├── CriterionRouletteApp.swift      # App entry point
├── Models/
│   ├── Models.swift                # Role, Dungeon, Player, RoleAssignment, Run
│   └── Extensions.swift            # Color(hex:) + app color palette
├── ViewModels/
│   └── PartyViewModel.swift        # All business logic + persistence
└── Views/
    ├── ContentView.swift            # Root view, tab bar, header, star field
    ├── PartyView.swift              # Party management tab
    ├── AssignmentView.swift         # Roll result tab
    └── HistoryView.swift            # Run log tab
```

---

## Setup in Xcode

1. Open Xcode → **File → New → Project**
2. Choose **App** under iOS
3. Set:
   - Product Name: `CriterionRoulette`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum Deployment Target: **iOS 16.0+**
4. Delete the default `ContentView.swift` Xcode generates
5. Copy all `.swift` files from this project into your Xcode project, maintaining the folder structure (add as groups)
6. Build and run on Simulator or a real device

No third-party dependencies — pure SwiftUI and Foundation only.

---

## Criterion Dungeons Included

| Dungeon | Difficulty |
|---------|------------|
| Another Sildihn Subterrane | Criterion |
| Another Sildihn Subterrane (Savage) | Criterion Savage |
| Another Mount Rokkon | Criterion |
| Another Mount Rokkon (Savage) | Criterion Savage |
| Another Aloalo Island | Criterion |
| Another Aloalo Island (Savage) | Criterion Savage |

To add more dungeons, edit the `Dungeon.all` array in `Models/Models.swift`.

---

## How It Works

### Role Assignment
```swift
let shuffledPlayers = players.shuffled()
let assignments = zip(Role.allCases, shuffledPlayers).map { role, player in
    RoleAssignment(role: role, player: player)
}
```
The four roles (`Tank`, `Healer`, `Melee DPS`, `Ranged DPS`) are in a fixed order. Players are shuffled randomly and zipped with the roles — guaranteeing each player gets exactly one role and every role is filled.

### Persistence
Runs are encoded as JSON and stored in `UserDefaults` under the key `ff14_criterion_run_history`. They survive app restarts and can be deleted individually (swipe to delete) or all at once.

---

## Extending the App

**Add more dungeons** → Append to `Dungeon.all` in `Models.swift`

**Add player jobs/classes** → Add a `job: String?` property to `Player` and a picker in `PartyView`

**Add run notes** → Add a `notes: String` property to `Run` and a text field in `AssignmentView` before saving

**iCloud sync** → Swap `UserDefaults` for `NSUbiquitousKeyValueStore` or Core Data with CloudKit
