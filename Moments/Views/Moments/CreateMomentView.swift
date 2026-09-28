import SwiftUI

struct CreateMomentView: View {
    @Environment(MomentPlannerViewModel.self) private var planner
    @Environment(\.dismiss) private var dismiss
    @Environment(AppLanguage.self) private var appLanguage
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
                        Text(step < 2 ? Strings.createMomentContinue : Strings.createMomentCreate)
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if step > 0 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) { step -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(MomentsStyle.primaryText)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
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
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
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
                Text(Strings.createMomentStep1Title)
                    .font(MomentsStyle.georgiaItalic(34))
                    .foregroundColor(MomentsStyle.primaryText)

                Text(Strings.createMomentStep1Subtitle)
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
                    name: Strings.createMomentCustomTitle,
                    subtitle: Strings.createMomentCustomSubtitle
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
                Text(Strings.createMomentStep2Title)
                    .font(MomentsStyle.georgiaItalic(34))
                    .foregroundColor(MomentsStyle.primaryText)

                Text(Strings.createMomentStep2Subtitle)
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.secondaryText)
            }
            .padding(.top, 24)
            .padding(.bottom, 32)

            VStack(spacing: 0) {
                // Music
                CustomizeSection(title: Strings.createMomentSectionMusic) {
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
                            subtitle: Strings.createMomentCuratedPlaylist
                        )
                    } else {
                        EmptySelectionRow(icon: "music.note", label: Strings.createMomentAddPlaylist)
                    }
                }
                .padding(.vertical, 16)

                Rectangle()
                    .fill(MomentsStyle.border)
                    .frame(height: 0.5)
                    .padding(.leading, 50)

                // Menu
                CustomizeSection(title: Strings.createMomentSectionMenu) {
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
                        EmptySelectionRow(icon: "fork.knife", label: Strings.createMomentAddDishes)
                    }
                }
                .padding(.vertical, 16)

                Rectangle()
                    .fill(MomentsStyle.border)
                    .frame(height: 0.5)
                    .padding(.leading, 50)

                // Games
                CustomizeSection(title: Strings.createMomentSectionGames) {
                    if let gameNumbers = planner.currentPlan?.gameNumbers, !gameNumbers.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(gameNumbers, id: \.self) { number in
                                let game = gameByNumber(number)
                                SelectionRow(
                                    icon: game?.icon ?? "dice",
                                    title: game?.localizedName ?? "Game \(number)",
                                    subtitle: game?.localizedDescription
                                )
                            }
                        }
                    } else {
                        EmptySelectionRow(icon: "dice", label: Strings.createMomentAddGames)
                    }
                }
                .padding(.vertical, 16)
            }
            .padding(.horizontal, 16)
            .background(MomentsStyle.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: MomentsStyle.cardRadius))
        }
    }

    // MARK: - Step 3: Name It

    @FocusState private var nameFocused: Bool

    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(Strings.createMomentNameTitle)
                    .font(MomentsStyle.georgiaItalic(34))
                    .foregroundColor(MomentsStyle.primaryText)

                Text(Strings.createMomentNameSubtitle)
                    .font(MomentsStyle.systemLight(14))
                    .foregroundColor(MomentsStyle.secondaryText)
            }
            .padding(.top, 24)
            .padding(.bottom, 40)

            VStack(alignment: .leading, spacing: 8) {
                Text(Strings.createMomentNameLabel)
                    .font(.system(size: 9, weight: .light))
                    .tracking(2)
                    .foregroundColor(nameFocused ? MomentsStyle.primaryText : MomentsStyle.secondaryText)
                    .animation(.easeInOut(duration: 0.2), value: nameFocused)

                TextField(Strings.createMomentNamePlaceholder, text: $momentTitle)
                    .font(MomentsStyle.systemLight(16))
                    .foregroundColor(MomentsStyle.primaryText)
                    .focused($nameFocused)
                    .padding(.bottom, 10)
                    .overlay(
                        Rectangle()
                            .fill(MomentsStyle.primaryText.opacity(nameFocused ? 0.7 : 0.2))
                            .frame(height: 0.5)
                            .animation(.easeInOut(duration: 0.2), value: nameFocused),
                        alignment: .bottom
                    )
            }
            .onAppear { nameFocused = true }
        }
    }
}

// MARK: - Vibe Card

private struct VibeCard: View {
    var icon: String
    var name: String
    var subtitle: String
    var action: () -> Void

    @Environment(AppLanguage.self) private var appLanguage

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
