import Foundation

struct Game: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let name: String
    let description: String
    let tag: String
    let rules: [String]
    let promptCount: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }

    static func == (lhs: Game, rhs: Game) -> Bool {
        lhs.number == rhs.number
    }
}

struct GamePrompt: Identifiable {
    let id = UUID()
    let text: String
    let optionA: String?
    let optionB: String?

    init(text: String, optionA: String? = nil, optionB: String? = nil) {
        self.text = text
        self.optionA = optionA
        self.optionB = optionB
    }
}

struct GamePlayDestination: Hashable {
    let gameNumber: Int
}

// MARK: - Game Data

let lightGames: [Game] = [
    Game(
        number: 1,
        name: "Would You Rather",
        description: "Classic dilemmas that spark debate",
        tag: "Icebreaker",
        rules: [
            "One person reads the two options aloud.",
            "Everyone picks a side — no skipping!",
            "Debate your choices before moving on."
        ],
        promptCount: 15
    ),
    Game(
        number: 2,
        name: "Heads Up",
        description: "Guess the word on your forehead",
        tag: "Party",
        rules: [
            "Hold the phone on your forehead so others can see the word.",
            "Your friends describe it without saying the word.",
            "Guess correctly and tap next!"
        ],
        promptCount: 15
    ),
    Game(
        number: 3,
        name: "Charades",
        description: "Act it out, no words allowed",
        tag: "Classic",
        rules: [
            "One person acts out the prompt silently.",
            "No talking, no mouthing words, no pointing at objects.",
            "The group tries to guess what it is."
        ],
        promptCount: 15
    ),
]

let deepGames: [Game] = [
    Game(
        number: 4,
        name: "Late Night Conversations",
        description: "Questions that go deeper",
        tag: "Intimate",
        rules: [
            "Read the question aloud to the group.",
            "Everyone takes a turn answering honestly.",
            "No judgement — just listen and share."
        ],
        promptCount: 12
    ),
    Game(
        number: 5,
        name: "Flirty & Fun",
        description: "Playful prompts for bold moments",
        tag: "Bold",
        rules: [
            "Read the prompt aloud.",
            "Answer honestly or complete the dare.",
            "Keep it playful — the bolder the better."
        ],
        promptCount: 12
    ),
    Game(
        number: 6,
        name: "High Stakes",
        description: "Dares and challenges with consequences",
        tag: "Daring",
        rules: [
            "Read the dare aloud.",
            "You must complete it or face a group-chosen penalty.",
            "No backing down — that's the whole point."
        ],
        promptCount: 12
    ),
]

// MARK: - Prompt Data

let gamePrompts: [Int: [GamePrompt]] = [
    // Would You Rather
    1: [
        GamePrompt(text: "Would you rather...", optionA: "Always say everything on your mind", optionB: "Never speak again"),
        GamePrompt(text: "Would you rather...", optionA: "Have dinner with your future self", optionB: "Have dinner with your 10-year-old self"),
        GamePrompt(text: "Would you rather...", optionA: "Be able to fly", optionB: "Be able to read minds"),
        GamePrompt(text: "Would you rather...", optionA: "Live in the mountains", optionB: "Live by the ocean"),
        GamePrompt(text: "Would you rather...", optionA: "Know how you die", optionB: "Know when you die"),
        GamePrompt(text: "Would you rather...", optionA: "Only eat sweet food forever", optionB: "Only eat savoury food forever"),
        GamePrompt(text: "Would you rather...", optionA: "Relive the same day forever", optionB: "Fast-forward 10 years"),
        GamePrompt(text: "Would you rather...", optionA: "Always be slightly cold", optionB: "Always be slightly warm"),
        GamePrompt(text: "Would you rather...", optionA: "Give up your phone for a year", optionB: "Give up travel for a year"),
        GamePrompt(text: "Would you rather...", optionA: "Have unlimited money", optionB: "Have unlimited time"),
        GamePrompt(text: "Would you rather...", optionA: "Be famous and lonely", optionB: "Be unknown and loved"),
        GamePrompt(text: "Would you rather...", optionA: "Always know the truth", optionB: "Always believe the best in people"),
        GamePrompt(text: "Would you rather...", optionA: "Never use social media again", optionB: "Never watch a movie again"),
        GamePrompt(text: "Would you rather...", optionA: "Be the funniest person in the room", optionB: "Be the smartest person in the room"),
        GamePrompt(text: "Would you rather...", optionA: "Live without music", optionB: "Live without colour"),
    ],

    // Heads Up
    2: [
        GamePrompt(text: "Taylor Swift"),
        GamePrompt(text: "The Eiffel Tower"),
        GamePrompt(text: "Yoga"),
        GamePrompt(text: "Spaghetti Carbonara"),
        GamePrompt(text: "Leonardo DiCaprio"),
        GamePrompt(text: "Surfing"),
        GamePrompt(text: "A wedding"),
        GamePrompt(text: "Instagram"),
        GamePrompt(text: "Beyoncé"),
        GamePrompt(text: "Sushi"),
        GamePrompt(text: "The Mona Lisa"),
        GamePrompt(text: "Skydiving"),
        GamePrompt(text: "Harry Potter"),
        GamePrompt(text: "A sunset"),
        GamePrompt(text: "Karaoke"),
    ],

    // Charades
    3: [
        GamePrompt(text: "Walking a tightrope"),
        GamePrompt(text: "Making a pizza"),
        GamePrompt(text: "A cat stuck in a tree"),
        GamePrompt(text: "Taking a selfie"),
        GamePrompt(text: "Riding a rollercoaster"),
        GamePrompt(text: "Opening a present"),
        GamePrompt(text: "Getting caught in the rain"),
        GamePrompt(text: "Brushing your teeth"),
        GamePrompt(text: "Winning the lottery"),
        GamePrompt(text: "Playing the drums"),
        GamePrompt(text: "Swimming with sharks"),
        GamePrompt(text: "Eating something spicy"),
        GamePrompt(text: "Being a robot"),
        GamePrompt(text: "Walking on the moon"),
        GamePrompt(text: "Proposing to someone"),
    ],

    // Late Night Conversations
    4: [
        GamePrompt(text: "What's a belief you held strongly five years ago that you've since changed?"),
        GamePrompt(text: "What would you do differently if nobody was watching?"),
        GamePrompt(text: "When was the last time you felt truly at peace?"),
        GamePrompt(text: "What's something you've never told anyone at this table?"),
        GamePrompt(text: "What's the most important lesson a past relationship taught you?"),
        GamePrompt(text: "If you could have a conversation with anyone, living or dead, who would it be?"),
        GamePrompt(text: "What are you most afraid of losing?"),
        GamePrompt(text: "What does love mean to you right now, compared to five years ago?"),
        GamePrompt(text: "What's a small moment that changed the course of your life?"),
        GamePrompt(text: "What do you think people misunderstand most about you?"),
        GamePrompt(text: "What's the bravest thing you've ever done?"),
        GamePrompt(text: "If you had one year left, how would you spend it?"),
    ],

    // Flirty & Fun
    5: [
        GamePrompt(text: "What's the most attractive quality in a person?"),
        GamePrompt(text: "Describe your ideal date night in three words."),
        GamePrompt(text: "What's your love language?"),
        GamePrompt(text: "What song makes you think of romance?"),
        GamePrompt(text: "What's the most romantic thing someone has done for you?"),
        GamePrompt(text: "Give your best compliment to the person on your left."),
        GamePrompt(text: "What's a deal-breaker for you in dating?"),
        GamePrompt(text: "What's the boldest thing you've done to impress someone?"),
        GamePrompt(text: "Describe your celebrity crush and why."),
        GamePrompt(text: "What's the cheesiest pick-up line you know? Deliver it."),
        GamePrompt(text: "What outfit makes you feel the most confident?"),
        GamePrompt(text: "What's the first thing you notice about someone?"),
    ],

    // High Stakes
    6: [
        GamePrompt(text: "Let the group go through your last 5 photos."),
        GamePrompt(text: "Text the third person in your contacts 'I miss you'."),
        GamePrompt(text: "Do your best impression of someone in the room."),
        GamePrompt(text: "Show the group your screen time report."),
        GamePrompt(text: "Let someone post a story on your Instagram."),
        GamePrompt(text: "Call your mum and tell her you're getting married."),
        GamePrompt(text: "Read aloud your last sent text message."),
        GamePrompt(text: "Let the group compose a message to your crush."),
        GamePrompt(text: "Do 20 push-ups right now or finish your drink."),
        GamePrompt(text: "Share your most embarrassing moment."),
        GamePrompt(text: "Let someone go through your search history for 30 seconds."),
        GamePrompt(text: "Speak in an accent for the next 3 rounds."),
    ],
]
