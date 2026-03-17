import SwiftUI

struct CreateMomentView: View {
    @Environment(MomentPlannerViewModel.self) private var planner
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var momentTitle = ""

    var body: some View {
        VStack(spacing: 0) {
            // Progress capsules
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Capsule()
                        .fill(index <= step ? MomentsStyle.primaryText : MomentsStyle.border)
                        .frame(height: 2)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    switch step {
                    case 0:
                        vibeStep
                    case 1:
                        customizeStep
                    case 2:
                        nameStep
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)

            // Bottom button
            if step > 0 {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(MomentsStyle.border)
                        .frame(height: 0.5)

                    Button {
                        handleContinue()
                    } label: {
                        Text(step < 2 ? "CONTINUE" : "CREATE MOMENT")
                            .font(.system(size: 10, weight: .light))
                            .tracking(3)
                            .foregroundColor(MomentsStyle.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(MomentsStyle.primaryText)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
                .background(MomentsStyle.background)
            }
        }
        .background(MomentsStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if step > 0 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) { step -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(MomentsStyle.primaryText)
                }
            }
        }
    }

    // MARK: - Actions

    private func handleContinue() {
        if step == 1 {
            momentTitle = planner.currentPlan?.title ?? ""
            withAnimation(.easeInOut(duration: 0.3)) { step = 2 }
        } else if step == 2 {
            let trimmed = momentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                planner.setTitle(trimmed)
            }
            planner.startMoment()
            dismiss()
        }
    }

    // MARK: - Step 1: Pick a Vibe

    private var vibeStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What kind of evening?")
                    .font(MomentsStyle.georgiaItalic(34))
                    .foregroundColor(MomentsStyle.primaryText)

                Text("Pick a vibe or start from scratch")
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.secondaryText)
            }
            .padding(.top, 24)
            .padding(.bottom, 32)

            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(momentTemplates) { template in
                    VibeCard(template: template) {
                        Haptics.select()
                        planner.createFromTemplate(template)
                        withAnimation(.easeInOut(duration: 0.3)) { step = 1 }
                    }
                }

                VibeCard(
                    icon: "sparkles",
                    name: "Custom",
                    subtitle: "Build your own evening"
                ) {
                    Haptics.select()
                    planner.createCustom()
                    withAnimation(.easeInOut(duration: 0.3)) { step = 1 }
                }
            }
        }
    }

    // MARK: - Step 2: Customize

    private var customizeStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your evening")
                    .font(MomentsStyle.georgiaItalic(34))
                    .foregroundColor(MomentsStyle.primaryText)

                Text("Customize to make it yours")
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.secondaryText)
            }
            .padding(.top, 24)
            .padding(.bottom, 32)

            VStack(alignment: .leading, spacing: 24) {
                // Music
                CustomizeSection(title: "MUSIC") {
                    if let playlistId = planner.currentPlan?.playlistId,
                       let playlist = CuratedPlaylists.all.first(where: { $0.id == playlistId }) {
                        SelectionRow(
                            icon: "music.note",
                            title: playlist.name,
                            subtitle: playlist.subtitle
                        )
                    } else if let playlistId = planner.currentPlan?.playlistId, !playlistId.isEmpty {
                        SelectionRow(
                            icon: "music.note",
                            title: playlistId.replacingOccurrences(of: "-", with: " ").capitalized,
                            subtitle: "Curated playlist"
                        )
                    } else {
                        EmptySelectionRow(icon: "music.note", label: "Add a playlist")
                    }
                }

                Rectangle()
                    .fill(MomentsStyle.border)
                    .frame(height: 0.5)

                // Menu
                CustomizeSection(title: "MENU") {
                    if let dishIds = planner.currentPlan?.dishIds, !dishIds.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(dishIds, id: \.self) { dishId in
                                SelectionRow(
                                    icon: "fork.knife",
                                    title: dishId.replacingOccurrences(of: "-", with: " ").capitalized,
                                    subtitle: nil
                                )
                            }
                        }
                    } else {
                        EmptySelectionRow(icon: "fork.knife", label: "Add dishes")
                    }
                }

                Rectangle()
                    .fill(MomentsStyle.border)
                    .frame(height: 0.5)

                // Games
                CustomizeSection(title: "GAMES") {
                    if let gameNumbers = planner.currentPlan?.gameNumbers, !gameNumbers.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(gameNumbers, id: \.self) { number in
                                let game = gameByNumber(number)
                                SelectionRow(
                                    icon: game?.icon ?? "dice",
                                    title: game?.name ?? "Game \(number)",
                                    subtitle: game?.description
                                )
                            }
                        }
                    } else {
                        EmptySelectionRow(icon: "dice", label: "Add games")
                    }
                }
            }
        }
    }

    // MARK: - Step 3: Name It

    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Give your moment a name")
                    .font(MomentsStyle.georgiaItalic(34))
                    .foregroundColor(MomentsStyle.primaryText)

                Text("Something to remember the evening by")
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.secondaryText)
            }
            .padding(.top, 24)
            .padding(.bottom, 40)

            VStack(alignment: .leading, spacing: 8) {
                Text("NAME")
                    .font(.system(size: 9, weight: .light))
                    .tracking(2)
                    .foregroundColor(MomentsStyle.secondaryText)

                TextField("e.g. Friday Night Dinner", text: $momentTitle)
                    .font(MomentsStyle.systemLight(16))
                    .foregroundColor(MomentsStyle.primaryText)
                    .padding(.bottom, 10)
                    .overlay(
                        Rectangle()
                            .fill(MomentsStyle.border)
                            .frame(height: 0.5),
                        alignment: .bottom
                    )
            }
        }
    }
}

// MARK: - Vibe Card

private struct VibeCard: View {
    var icon: String
    var name: String
    var subtitle: String
    var action: () -> Void

    init(template: MomentTemplate, action: @escaping () -> Void) {
        self.icon = template.icon
        self.name = template.name
        self.subtitle = template.subtitle
        self.action = action
    }

    init(icon: String, name: String, subtitle: String, action: @escaping () -> Void) {
        self.icon = icon
        self.name = name
        self.subtitle = subtitle
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HairlineCard {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(MomentsStyle.primaryText)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(name)
                            .font(MomentsStyle.systemMedium(14))
                            .foregroundColor(MomentsStyle.primaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Text(subtitle)
                            .font(MomentsStyle.systemLight(12))
                            .foregroundColor(MomentsStyle.secondaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 100)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Customize Section

private struct CustomizeSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 10, weight: .light))
                .tracking(3)
                .foregroundColor(MomentsStyle.secondaryText)

            content
        }
    }
}

// MARK: - Selection Row

private struct SelectionRow: View {
    let icon: String
    let title: String
    let subtitle: String?

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(MomentsStyle.surfaceSecondary)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(MomentsStyle.primaryText)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(MomentsStyle.systemMedium(14))
                    .foregroundColor(MomentsStyle.primaryText)

                if let subtitle {
                    Text(subtitle)
                        .font(MomentsStyle.systemLight(12))
                        .foregroundColor(MomentsStyle.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Empty Selection Row

private struct EmptySelectionRow: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(MomentsStyle.surfaceSecondary)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(MomentsStyle.inactive)
                )

            Text(label)
                .font(MomentsStyle.systemLight(14))
                .foregroundColor(MomentsStyle.secondaryText)

            Spacer()
        }
    }
}

// MARK: - Helpers

private func gameByNumber(_ number: Int) -> Game? {
    (lightGames + deepGames).first(where: { $0.number == number })
}

#Preview {
    NavigationStack {
        CreateMomentView()
            .environment(MomentPlannerViewModel())
    }
}
