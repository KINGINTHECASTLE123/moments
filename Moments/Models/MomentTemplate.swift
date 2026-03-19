import Foundation

struct MomentTemplate: Identifiable {
    let id: String
    let vibe: String
    let icon: String
    let suggestedPlaylistId: String
    let suggestedDishIds: [String]
    let suggestedGameNumbers: [Int]

    // Localized display properties — evaluated at access time so the
    // language toggle updates template cards immediately.
    var name: String {
        switch id {
        case "dinner-party":  return Strings.templateClassicDinnerPartyTitle
        case "game-night":    return Strings.templateGameNightTitle
        case "date-night":    return Strings.templateDateNightTitle
        case "sunday-brunch": return Strings.templateSundayBrunchTitle
        default:              return id
        }
    }

    var subtitle: String {
        switch id {
        case "dinner-party":  return Strings.templateClassicDinnerPartySubtitle
        case "game-night":    return Strings.templateGameNightSubtitle
        case "date-night":    return Strings.templateDateNightSubtitle
        case "sunday-brunch": return Strings.templateSundayBrunchSubtitle
        default:              return ""
        }
    }
}

// MARK: - Template Data
//
// Computed var (not `let` constant) so that name/subtitle are re-evaluated
// from Strings on every access. id, vibe, icon, and playlist/dish/game
// references are all stable String/Int values — no identity issues.

var momentTemplates: [MomentTemplate] {[
    MomentTemplate(
        id: "dinner-party",
        vibe: "dinner-party",
        icon: "fork.knife",
        suggestedPlaylistId: "dinner-party-grooves",
        suggestedDishIds: ["burrata", "sea-bass", "panna-cotta", "negroni"],
        suggestedGameNumbers: [4, 1]
    ),
    MomentTemplate(
        id: "game-night",
        vibe: "game-night",
        icon: "dice",
        suggestedPlaylistId: "upbeat-evening",
        suggestedDishIds: [],
        suggestedGameNumbers: [2, 3, 6]
    ),
    MomentTemplate(
        id: "date-night",
        vibe: "date-night",
        icon: "heart",
        suggestedPlaylistId: "late-night-wind-down",
        suggestedDishIds: ["tuna-tartare", "lamb", "chocolate-fondant", "paloma"],
        suggestedGameNumbers: [5, 4]
    ),
    MomentTemplate(
        id: "sunday-brunch",
        vibe: "sunday-brunch",
        icon: "sun.max",
        suggestedPlaylistId: "easy-sunday",
        suggestedDishIds: [],
        suggestedGameNumbers: [1]
    ),
]}
