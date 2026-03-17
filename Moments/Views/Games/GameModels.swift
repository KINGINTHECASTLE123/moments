import Foundation

struct Game: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let name: String
    let description: String
    let tag: String
    let rules: [String]
    let promptCount: Int
    let icon: String
    let emoji: String

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
        promptCount: 40,
        icon: "arrow.left.arrow.right",
        emoji: "🤔"
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
        promptCount: 40,
        icon: "hand.raised",
        emoji: "🙆"
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
        promptCount: 40,
        icon: "theatermasks",
        emoji: "🎭"
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
        promptCount: 40,
        icon: "moon.stars",
        emoji: "🌙"
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
        promptCount: 40,
        icon: "heart",
        emoji: "💋"
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
        promptCount: 40,
        icon: "flame",
        emoji: "🔥"
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
        GamePrompt(text: "Would you rather...", optionA: "Know every language fluently", optionB: "Be a master of every musical instrument"),
        GamePrompt(text: "Would you rather...", optionA: "Never feel physical pain again", optionB: "Never feel heartbreak again"),
        GamePrompt(text: "Would you rather...", optionA: "Always be overdressed", optionB: "Always be underdressed"),
        GamePrompt(text: "Would you rather...", optionA: "Have your dream job but live far from friends", optionB: "Have an average job surrounded by everyone you love"),
        GamePrompt(text: "Would you rather...", optionA: "Forget who you are every morning", optionB: "Forget who everyone else is every morning"),
        GamePrompt(text: "Would you rather...", optionA: "Live in a world with no lies", optionB: "Live in a world with no secrets"),
        GamePrompt(text: "Would you rather...", optionA: "Be stuck in traffic for 3 hours every day", optionB: "Have no internet access at home"),
        GamePrompt(text: "Would you rather...", optionA: "Always have to sing instead of speak", optionB: "Always have to dance instead of walk"),
        GamePrompt(text: "Would you rather...", optionA: "Have your life narrated by Morgan Freeman", optionB: "Have your life soundtracked by Hans Zimmer"),
        GamePrompt(text: "Would you rather...", optionA: "Spend a year in the past", optionB: "Spend a year in the future"),
        GamePrompt(text: "Would you rather...", optionA: "Only drink wine for the rest of your life", optionB: "Only drink cocktails for the rest of your life"),
        GamePrompt(text: "Would you rather...", optionA: "Never be able to cook again", optionB: "Never be able to eat out again"),
        GamePrompt(text: "Would you rather...", optionA: "Be feared by everyone", optionB: "Be trusted by everyone"),
        GamePrompt(text: "Would you rather...", optionA: "Wake up every day at 5 AM with perfect energy", optionB: "Stay up as late as you want and never feel tired"),
        GamePrompt(text: "Would you rather...", optionA: "Have one deep friendship", optionB: "Have twenty good friendships"),
        GamePrompt(text: "Would you rather...", optionA: "Lose all your old memories", optionB: "Never be able to make new ones"),
        GamePrompt(text: "Would you rather...", optionA: "Know exactly what people think of you", optionB: "Never know what anyone thinks of you"),
        GamePrompt(text: "Would you rather...", optionA: "Only be able to whisper", optionB: "Only be able to shout"),
        GamePrompt(text: "Would you rather...", optionA: "Live in a penthouse in a city you hate", optionB: "Live in a tiny flat in your favourite city"),
        GamePrompt(text: "Would you rather...", optionA: "Give up coffee forever", optionB: "Give up alcohol forever"),
        GamePrompt(text: "Would you rather...", optionA: "Have a rewind button for your life", optionB: "Have a pause button for your life"),
        GamePrompt(text: "Would you rather...", optionA: "Always have to tell the truth", optionB: "Always have to lie"),
        GamePrompt(text: "Would you rather...", optionA: "Be the best player on a losing team", optionB: "Be the worst player on a winning team"),
        GamePrompt(text: "Would you rather...", optionA: "Live in a mansion with no one", optionB: "Live in a studio flat with your favourite people"),
        GamePrompt(text: "Would you rather...", optionA: "Experience everything twice", optionB: "Experience nothing the same way ever again"),
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
        GamePrompt(text: "Oprah Winfrey"),
        GamePrompt(text: "A croissant"),
        GamePrompt(text: "Scuba diving"),
        GamePrompt(text: "The Great Wall of China"),
        GamePrompt(text: "Drake"),
        GamePrompt(text: "A margarita"),
        GamePrompt(text: "Bungee jumping"),
        GamePrompt(text: "Rihanna"),
        GamePrompt(text: "Tiramisu"),
        GamePrompt(text: "The Titanic"),
        GamePrompt(text: "A first date"),
        GamePrompt(text: "David Beckham"),
        GamePrompt(text: "Meditation"),
        GamePrompt(text: "A food truck"),
        GamePrompt(text: "Adele"),
        GamePrompt(text: "A road trip"),
        GamePrompt(text: "Champagne"),
        GamePrompt(text: "The Colosseum"),
        GamePrompt(text: "Keanu Reeves"),
        GamePrompt(text: "A spa day"),
        GamePrompt(text: "Avocado toast"),
        GamePrompt(text: "The Northern Lights"),
        GamePrompt(text: "Zendaya"),
        GamePrompt(text: "A wine tasting"),
        GamePrompt(text: "Poker night"),
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
        GamePrompt(text: "Trying to hail a taxi"),
        GamePrompt(text: "Putting on skinny jeans"),
        GamePrompt(text: "A chef tasting their own cooking"),
        GamePrompt(text: "Sneaking out of the house"),
        GamePrompt(text: "Changing a baby's nappy"),
        GamePrompt(text: "Doing a tequila shot"),
        GamePrompt(text: "Walking in high heels for the first time"),
        GamePrompt(text: "Catching a fly with chopsticks"),
        GamePrompt(text: "Assembling IKEA furniture"),
        GamePrompt(text: "A DJ at a nightclub"),
        GamePrompt(text: "Waking up late for work"),
        GamePrompt(text: "Trying to parallel park"),
        GamePrompt(text: "Doing a dramatic soap opera scene"),
        GamePrompt(text: "A dog seeing its owner come home"),
        GamePrompt(text: "Blowing out birthday candles"),
        GamePrompt(text: "Being stuck in a lift"),
        GamePrompt(text: "A model on a catwalk"),
        GamePrompt(text: "Trying to stay awake during a meeting"),
        GamePrompt(text: "Fighting with an umbrella in the wind"),
        GamePrompt(text: "A tourist taking photos of everything"),
        GamePrompt(text: "Doing the limbo"),
        GamePrompt(text: "Opening a bottle of champagne"),
        GamePrompt(text: "Someone getting a massage"),
        GamePrompt(text: "Running on a treadmill that's too fast"),
        GamePrompt(text: "A waiter carrying too many plates"),
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
        GamePrompt(text: "What's something you pretend to care less about than you actually do?"),
        GamePrompt(text: "When did you first feel like an adult?"),
        GamePrompt(text: "What's a promise you made to yourself that you've kept?"),
        GamePrompt(text: "What would your younger self think of who you are now?"),
        GamePrompt(text: "What's the kindest thing a stranger has ever done for you?"),
        GamePrompt(text: "What part of your personality did you have to learn, rather than inherit?"),
        GamePrompt(text: "What's a question you wish someone would ask you?"),
        GamePrompt(text: "What do you think you'll regret not doing?"),
        GamePrompt(text: "When was the last time you changed your mind about something important?"),
        GamePrompt(text: "What's a relationship you wish you'd fought harder for?"),
        GamePrompt(text: "What's the loneliest you've ever felt, and what brought you back?"),
        GamePrompt(text: "What do you need more of in your life right now?"),
        GamePrompt(text: "What memory do you keep going back to?"),
        GamePrompt(text: "What's something you've forgiven yourself for?"),
        GamePrompt(text: "What would you want people to say about you at your funeral?"),
        GamePrompt(text: "What's the hardest goodbye you've ever had to say?"),
        GamePrompt(text: "What did your parents get right? What did they get wrong?"),
        GamePrompt(text: "What's a version of yourself you had to let go of to grow?"),
        GamePrompt(text: "What are you still trying to figure out?"),
        GamePrompt(text: "What do you wish you'd learned earlier about love?"),
        GamePrompt(text: "What's a fear that quietly controls more of your decisions than you'd like?"),
        GamePrompt(text: "What's the most honest thing you could say to this group right now?"),
        GamePrompt(text: "What makes you feel truly seen by another person?"),
        GamePrompt(text: "What have you outgrown but haven't fully let go of?"),
        GamePrompt(text: "What's something you're grateful for that you never expected?"),
        GamePrompt(text: "What's a conversation that changed the way you see the world?"),
        GamePrompt(text: "What do you think your life is really about?"),
        GamePrompt(text: "What's the difference between who you are and who you show people?"),
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
        GamePrompt(text: "What's the most flirtatious thing you've ever said to someone?"),
        GamePrompt(text: "If you could plan a dream date with no budget, what would it look like?"),
        GamePrompt(text: "What's a guilty pleasure song you secretly find romantic?"),
        GamePrompt(text: "Describe the best kiss you've ever had — without naming names."),
        GamePrompt(text: "What's the biggest green flag on a first date?"),
        GamePrompt(text: "Make eye contact with someone at this table for 10 seconds without laughing."),
        GamePrompt(text: "What's a compliment you've received that you still think about?"),
        GamePrompt(text: "What movie scene made you believe in love?"),
        GamePrompt(text: "Who at this table would you most want to be stuck on a desert island with?"),
        GamePrompt(text: "What's the most romantic city in the world?"),
        GamePrompt(text: "What's your signature move when you're flirting?"),
        GamePrompt(text: "Hold hands with the person across from you for the next two rounds."),
        GamePrompt(text: "What scent on another person drives you crazy?"),
        GamePrompt(text: "What's the most underrated thing about being in a relationship?"),
        GamePrompt(text: "What's the most spontaneous thing you've done for a crush?"),
        GamePrompt(text: "If someone wrote a love letter to you, what would you want it to say?"),
        GamePrompt(text: "What's a song you'd want playing during a slow dance?"),
        GamePrompt(text: "Give a toast to the most attractive person at the table."),
        GamePrompt(text: "What dating trend do you absolutely hate?"),
        GamePrompt(text: "What's the best opening line someone has ever used on you?"),
        GamePrompt(text: "Whisper something nice into the ear of the person next to you."),
        GamePrompt(text: "What's your idea of a perfect morning with someone you love?"),
        GamePrompt(text: "What physical feature do you find attractive that most people overlook?"),
        GamePrompt(text: "What's the most romantic thing you've done that nobody knows about?"),
        GamePrompt(text: "If this table were a dating show, who would get the final rose?"),
        GamePrompt(text: "What's a date you went on that started badly but ended perfectly?"),
        GamePrompt(text: "Text someone in your phone a genuine compliment right now."),
        GamePrompt(text: "What's the sexiest accent in the world?"),
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
        GamePrompt(text: "Show the group your most-played song on Spotify."),
        GamePrompt(text: "Let the group pick someone in your contacts and you have to call them."),
        GamePrompt(text: "Read aloud the last note you wrote in your Notes app."),
        GamePrompt(text: "Show your most embarrassing saved photo."),
        GamePrompt(text: "Send a voice note to your best friend saying 'I love you' dramatically."),
        GamePrompt(text: "Let someone type and send a story reply on your behalf."),
        GamePrompt(text: "Unlock your phone and hand it to the person on your right for 30 seconds."),
        GamePrompt(text: "Reveal the last thing you googled."),
        GamePrompt(text: "Post a selfie right now with no filter and no retakes."),
        GamePrompt(text: "Let the group read your last five DMs on Instagram."),
        GamePrompt(text: "Do a dramatic reading of your most recent email."),
        GamePrompt(text: "Show the group your average daily screen time."),
        GamePrompt(text: "Text your ex a single emoji chosen by the group."),
        GamePrompt(text: "Swap phones with someone for the next two rounds."),
        GamePrompt(text: "Reveal the last person whose profile you stalked on social media."),
        GamePrompt(text: "Let the group compose and send a tweet or post from your account."),
        GamePrompt(text: "Show the group the last video in your camera roll."),
        GamePrompt(text: "Call a friend and put them on speaker — ask them your best quality and worst habit."),
        GamePrompt(text: "Share the last lie you told and who you told it to."),
        GamePrompt(text: "Give the person across from you your phone and let them send one text."),
        GamePrompt(text: "Reveal the most expensive thing you've bought that you regret."),
        GamePrompt(text: "Show the group your most-used emoji — then explain yourself."),
        GamePrompt(text: "Let the group set your lock screen for the next 24 hours."),
        GamePrompt(text: "Reveal the last thing you added to your online shopping cart."),
        GamePrompt(text: "Record a 15-second video confessing something and post it to your Close Friends."),
        GamePrompt(text: "Show the group your Spotify Wrapped top artist."),
        GamePrompt(text: "Let someone go through your 'Following' list and ask about anyone they choose."),
        GamePrompt(text: "Call the last person you texted and sing them Happy Birthday."),
    ],
]
