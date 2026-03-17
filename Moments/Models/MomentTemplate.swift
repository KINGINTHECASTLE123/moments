import Foundation

struct MomentTemplate: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let vibe: String
    let icon: String
    let suggestedPlaylistId: String
    let suggestedDishIds: [String]
    let suggestedGameNumbers: [Int]
}

let momentTemplates: [MomentTemplate] = [
    MomentTemplate(
        id: "dinner-party",
        name: "The Classic Dinner Party",
        subtitle: "Burrata, negronis, and conversations that matter",
        vibe: "dinner-party",
        icon: "fork.knife",
        suggestedPlaylistId: "dinner-party-grooves",
        suggestedDishIds: ["burrata", "sea-bass", "panna-cotta", "negroni"],
        suggestedGameNumbers: [4, 1]
    ),
    MomentTemplate(
        id: "game-night",
        name: "Game Night",
        subtitle: "Energy, laughter, and a little chaos",
        vibe: "game-night",
        icon: "dice",
        suggestedPlaylistId: "upbeat-evening",
        suggestedDishIds: [],
        suggestedGameNumbers: [2, 3, 6]
    ),
    MomentTemplate(
        id: "date-night",
        name: "Date Night In",
        subtitle: "Set the mood for two",
        vibe: "date-night",
        icon: "heart",
        suggestedPlaylistId: "late-night-wind-down",
        suggestedDishIds: ["tuna-tartare", "lamb", "chocolate-fondant", "paloma"],
        suggestedGameNumbers: [5, 4]
    ),
    MomentTemplate(
        id: "sunday-brunch",
        name: "Sunday Brunch",
        subtitle: "Slow morning, good company",
        vibe: "sunday-brunch",
        icon: "sun.max",
        suggestedPlaylistId: "easy-sunday",
        suggestedDishIds: [],
        suggestedGameNumbers: [1]
    ),
]
