import Foundation

// MARK: - GameStrings
//
// Translated metadata and prompts for all six games.
// Usage:
//   GameStrings.name(for: game.number)           // translated name
//   GameStrings.description(for: game.number)    // translated description
//   GameStrings.tag(for: game.number)             // translated tag
//   GameStrings.rules(for: game.number)           // translated rules [String]
//   GameStrings.prompts(for: game.number)         // shuffleable [GamePrompt]
//   GameStrings.instruction(for: game.number)     // one-liner used during play
//
// Playlist/dish/game names in MomentTemplates are translated via Strings.*

enum GameStrings {

    private static var lang: Language { AppLanguage.shared.current }

    // MARK: - Game 1: Would You Rather

    static var game1Name: String { lang == .english ? "Would You Rather" : "Ville du hellere" }
    static var game1Description: String { lang == .english ? "Classic dilemmas that spark debate" : "Klassiske dilemmaer der sætter gang i debatten" }
    static var game1Tag: String { lang == .english ? "Icebreaker" : "Isbryder" }
    static var game1Rules: [String] {
        lang == .english
        ? [
            "One person reads the two options aloud.",
            "Everyone picks a side — no skipping!",
            "Debate your choices before moving on."
          ]
        : [
            "Én person læser de to muligheder højt.",
            "Alle vælger side — ingen må springe over!",
            "Diskuter jeres valg, inden I går videre."
          ]
    }
    static var game1Instruction: String {
        lang == .english
            ? "Read both options aloud. Everyone picks a side."
            : "Læs begge muligheder højt. Alle vælger side."
    }

    // MARK: - Game 2: Heads Up

    static var game2Name: String { lang == .english ? "Heads Up" : "Gæt ordet" }
    static var game2Description: String { lang == .english ? "Guess the word on your forehead" : "Gæt ordet på din pande" }
    static var game2Tag: String { lang == .english ? "Party" : "Fest" }
    static var game2Rules: [String] {
        lang == .english
        ? [
            "Hold the phone on your forehead so others can see the word.",
            "Your friends describe it without saying the word.",
            "Guess correctly and tap next!"
          ]
        : [
            "Hold telefonen mod din pande, så de andre kan se ordet.",
            "Dine venner beskriver det uden at sige selve ordet.",
            "Gæt rigtigt og tryk næste!"
          ]
    }
    static var game2Instruction: String {
        lang == .english
            ? "Hold phone to your forehead. Friends describe the word."
            : "Hold telefonen mod panden. Venner beskriver ordet."
    }

    // MARK: - Game 3: Charades

    static var game3Name: String { lang == .english ? "Charades" : "Gæt & grimasser" }
    static var game3Description: String { lang == .english ? "Act it out, no words allowed" : "Vis det med kroppen, ingen ord tilladt" }
    static var game3Tag: String { lang == .english ? "Classic" : "Klassisk" }
    static var game3Rules: [String] {
        lang == .english
        ? [
            "One person acts out the prompt silently.",
            "No talking, no mouthing words, no pointing at objects.",
            "The group tries to guess what it is."
          ]
        : [
            "Én person mimer kortet i tavshed.",
            "Ingen tale, ingen mundlyd, ingen pegeri.",
            "Gruppen forsøger at gætte, hvad det er."
          ]
    }
    static var game3Instruction: String {
        lang == .english
            ? "Act it out. No talking, no pointing."
            : "Vis det. Ingen tale, ingen pegeri."
    }

    // MARK: - Game 4: Late Night Conversations

    static var game4Name: String { lang == .english ? "Late Night Conversations" : "Dybe samtaler" }
    static var game4Description: String { lang == .english ? "Questions that go deeper" : "Spørgsmål der går i dybden" }
    static var game4Tag: String { lang == .english ? "Intimate" : "Intimt" }
    static var game4Rules: [String] {
        lang == .english
        ? [
            "Read the question aloud to the group.",
            "Everyone takes a turn answering honestly.",
            "No judgement — just listen and share."
          ]
        : [
            "Læs spørgsmålet højt for gruppen.",
            "Alle svarer på skift og ærligt.",
            "Ingen domme — bare lyt og del."
          ]
    }
    static var game4Instruction: String {
        lang == .english
            ? "Read aloud. Everyone takes a turn answering."
            : "Læs højt. Alle svarer på skift."
    }

    // MARK: - Game 5: Flirty & Fun

    static var game5Name: String { lang == .english ? "Flirty & Fun" : "Flirt & Sjov" }
    static var game5Description: String { lang == .english ? "Playful prompts for bold moments" : "Legende spørgsmål til modige øjeblikke" }
    static var game5Tag: String { lang == .english ? "Bold" : "Modig" }
    static var game5Rules: [String] {
        lang == .english
        ? [
            "Read the prompt aloud.",
            "Answer honestly or complete the dare.",
            "Keep it playful — the bolder the better."
          ]
        : [
            "Læs kortet højt.",
            "Svar ærligt eller gennemfør udfordringen.",
            "Hold det legende — jo modigere, jo bedre."
          ]
    }
    static var game5Instruction: String {
        lang == .english
            ? "Read the prompt. Be bold."
            : "Læs kortet. Vær modig."
    }

    // MARK: - Game 6: High Stakes

    static var game6Name: String { lang == .english ? "High Stakes" : "Udfordringer" }
    static var game6Description: String { lang == .english ? "Dares and challenges with consequences" : "Udfordringer og dristige opgaver med konsekvenser" }
    static var game6Tag: String { lang == .english ? "Daring" : "Dristig" }
    static var game6Rules: [String] {
        lang == .english
        ? [
            "Read the dare aloud.",
            "You must complete it or face a group-chosen penalty.",
            "No backing down — that's the whole point."
          ]
        : [
            "Læs udfordringen højt.",
            "Du skal gennemføre den eller acceptere en straf valgt af gruppen.",
            "Ingen bagtanker — det er hele pointen."
          ]
    }
    static var game6Instruction: String {
        lang == .english
            ? "Complete the dare — or face the penalty."
            : "Udfør udfordringen — eller tag konsekvensen."
    }

    // MARK: - Lookup Helpers

    static func name(for number: Int) -> String {
        switch number {
        case 1: game1Name
        case 2: game2Name
        case 3: game3Name
        case 4: game4Name
        case 5: game5Name
        case 6: game6Name
        default: ""
        }
    }

    static func description(for number: Int) -> String {
        switch number {
        case 1: game1Description
        case 2: game2Description
        case 3: game3Description
        case 4: game4Description
        case 5: game5Description
        case 6: game6Description
        default: ""
        }
    }

    static func tag(for number: Int) -> String {
        switch number {
        case 1: game1Tag
        case 2: game2Tag
        case 3: game3Tag
        case 4: game4Tag
        case 5: game5Tag
        case 6: game6Tag
        default: ""
        }
    }

    static func rules(for number: Int) -> [String] {
        switch number {
        case 1: game1Rules
        case 2: game2Rules
        case 3: game3Rules
        case 4: game4Rules
        case 5: game5Rules
        case 6: game6Rules
        default: []
        }
    }

    static func instruction(for number: Int) -> String {
        switch number {
        case 1: game1Instruction
        case 2: game2Instruction
        case 3: game3Instruction
        case 4: game4Instruction
        case 5: game5Instruction
        case 6: game6Instruction
        default: ""
        }
    }

    // MARK: - Prompts
    //
    // Returns English or Danish prompts depending on the current language.
    // English source lives in gamePrompts (GameModels.swift).
    // Danish source lives in danishGamePrompts below.

    static func prompts(for number: Int) -> [GamePrompt] {
        if lang == .danish {
            return danishGamePrompts[number] ?? []
        }
        return gamePrompts[number] ?? []
    }

    // MARK: - Danish Prompts

    // swiftlint:disable line_length
    private static let danishGamePrompts: [Int: [GamePrompt]] = [

        // Ville du hellere (Would You Rather)
        1: [
            GamePrompt(text: "Ville du hellere...", optionA: "Altid sige alt, hvad du tænker", optionB: "Aldrig tale igen"),
            GamePrompt(text: "Ville du hellere...", optionA: "Have middag med dit fremtidige jeg", optionB: "Have middag med dit 10-årige jeg"),
            GamePrompt(text: "Ville du hellere...", optionA: "Kunne flyve", optionB: "Kunne læse tanker"),
            GamePrompt(text: "Ville du hellere...", optionA: "Bo i bjergene", optionB: "Bo ved havet"),
            GamePrompt(text: "Ville du hellere...", optionA: "Vide, hvordan du dør", optionB: "Vide, hvornår du dør"),
            GamePrompt(text: "Ville du hellere...", optionA: "Kun spise søde ting for evigt", optionB: "Kun spise salte ting for evigt"),
            GamePrompt(text: "Ville du hellere...", optionA: "Gentage den samme dag for evigt", optionB: "Spole 10 år frem"),
            GamePrompt(text: "Ville du hellere...", optionA: "Altid fryse lidt", optionB: "Altid svede lidt"),
            GamePrompt(text: "Ville du hellere...", optionA: "Undvære din telefon i et år", optionB: "Undvære at rejse i et år"),
            GamePrompt(text: "Ville du hellere...", optionA: "Have ubegrænsede penge", optionB: "Have ubegrænset tid"),
            GamePrompt(text: "Ville du hellere...", optionA: "Være berømt og ensom", optionB: "Være ukendt og elsket"),
            GamePrompt(text: "Ville du hellere...", optionA: "Altid kende sandheden", optionB: "Altid tro det bedste om folk"),
            GamePrompt(text: "Ville du hellere...", optionA: "Aldrig bruge sociale medier igen", optionB: "Aldrig se en film igen"),
            GamePrompt(text: "Ville du hellere...", optionA: "Være den sjoveste i rummet", optionB: "Være den klogeste i rummet"),
            GamePrompt(text: "Ville du hellere...", optionA: "Leve uden musik", optionB: "Leve uden farver"),
            GamePrompt(text: "Ville du hellere...", optionA: "Tale alle sprog flydende", optionB: "Beherske alle musikinstrumenter"),
            GamePrompt(text: "Ville du hellere...", optionA: "Aldrig føle fysisk smerte igen", optionB: "Aldrig føle hjertesorg igen"),
            GamePrompt(text: "Ville du hellere...", optionA: "Altid være overdresset", optionB: "Altid være underdresset"),
            GamePrompt(text: "Ville du hellere...", optionA: "Have drømmejobbet men bo langt fra venner", optionB: "Have et gennemsnitsjob omgivet af dem, du elsker"),
            GamePrompt(text: "Ville du hellere...", optionA: "Glemme hvem du er hver morgen", optionB: "Glemme hvem alle andre er hver morgen"),
            GamePrompt(text: "Ville du hellere...", optionA: "Leve i en verden uden løgne", optionB: "Leve i en verden uden hemmeligheder"),
            GamePrompt(text: "Ville du hellere...", optionA: "Sidde i trafikprop i 3 timer hver dag", optionB: "Ingen internetadgang derhjemme"),
            GamePrompt(text: "Ville du hellere...", optionA: "Altid synge i stedet for at tale", optionB: "Altid danse i stedet for at gå"),
            GamePrompt(text: "Ville du hellere...", optionA: "Have Morgan Freeman som fortæller af dit liv", optionB: "Have Hans Zimmer som soundtrack til dit liv"),
            GamePrompt(text: "Ville du hellere...", optionA: "Tilbringe et år i fortiden", optionB: "Tilbringe et år i fremtiden"),
            GamePrompt(text: "Ville du hellere...", optionA: "Kun drikke vin resten af livet", optionB: "Kun drikke cocktails resten af livet"),
            GamePrompt(text: "Ville du hellere...", optionA: "Aldrig kunne lave mad igen", optionB: "Aldrig kunne spise ude igen"),
            GamePrompt(text: "Ville du hellere...", optionA: "Blive frygtet af alle", optionB: "Blive stolet på af alle"),
            GamePrompt(text: "Ville du hellere...", optionA: "Vågne kl. 5 med perfekt energi hver dag", optionB: "Sove så længe du vil og aldrig føle dig træt"),
            GamePrompt(text: "Ville du hellere...", optionA: "Have ét dybt venskab", optionB: "Have tyve gode venskaber"),
            GamePrompt(text: "Ville du hellere...", optionA: "Miste alle dine gamle minder", optionB: "Aldrig kunne danne nye minder"),
            GamePrompt(text: "Ville du hellere...", optionA: "Vide præcis, hvad folk tænker om dig", optionB: "Aldrig vide, hvad nogen tænker om dig"),
            GamePrompt(text: "Ville du hellere...", optionA: "Kun kunne hviske", optionB: "Kun kunne råbe"),
            GamePrompt(text: "Ville du hellere...", optionA: "Bo i en penthouse i en by, du hader", optionB: "Bo i en lille lejlighed i din yndlingsby"),
            GamePrompt(text: "Ville du hellere...", optionA: "Opgive kaffe for evigt", optionB: "Opgive alkohol for evigt"),
            GamePrompt(text: "Ville du hellere...", optionA: "Have en tilbageknap til dit liv", optionB: "Have en pauseknap til dit liv"),
            GamePrompt(text: "Ville du hellere...", optionA: "Altid skulle sige sandheden", optionB: "Altid skulle lyve"),
            GamePrompt(text: "Ville du hellere...", optionA: "Være den bedste spiller på et tabende hold", optionB: "Være den dårligste spiller på et vindende hold"),
            GamePrompt(text: "Ville du hellere...", optionA: "Bo i en stor villa alene", optionB: "Bo i en lille lejlighed med dine yndlingsmennesker"),
            GamePrompt(text: "Ville du hellere...", optionA: "Opleve alt to gange", optionB: "Aldrig opleve noget på samme måde igen"),
        ],

        // Gæt ordet (Heads Up)
        2: [
            GamePrompt(text: "Taylor Swift"),
            GamePrompt(text: "Eiffeltårnet"),
            GamePrompt(text: "Yoga"),
            GamePrompt(text: "Spaghetti Carbonara"),
            GamePrompt(text: "Leonardo DiCaprio"),
            GamePrompt(text: "Surfing"),
            GamePrompt(text: "Et bryllup"),
            GamePrompt(text: "Instagram"),
            GamePrompt(text: "Beyoncé"),
            GamePrompt(text: "Sushi"),
            GamePrompt(text: "Mona Lisa"),
            GamePrompt(text: "Faldskærmsudspring"),
            GamePrompt(text: "Harry Potter"),
            GamePrompt(text: "En solnedgang"),
            GamePrompt(text: "Karaoke"),
            GamePrompt(text: "Oprah Winfrey"),
            GamePrompt(text: "En croissant"),
            GamePrompt(text: "Dykning"),
            GamePrompt(text: "Den Kinesiske Mur"),
            GamePrompt(text: "Drake"),
            GamePrompt(text: "En margarita"),
            GamePrompt(text: "Bungeejump"),
            GamePrompt(text: "Rihanna"),
            GamePrompt(text: "Tiramisu"),
            GamePrompt(text: "Titanic"),
            GamePrompt(text: "En første date"),
            GamePrompt(text: "David Beckham"),
            GamePrompt(text: "Meditation"),
            GamePrompt(text: "En foodtruck"),
            GamePrompt(text: "Adele"),
            GamePrompt(text: "En roadtrip"),
            GamePrompt(text: "Champagne"),
            GamePrompt(text: "Colosseum"),
            GamePrompt(text: "Keanu Reeves"),
            GamePrompt(text: "En spa-dag"),
            GamePrompt(text: "Avocadomad"),
            GamePrompt(text: "Nordlyset"),
            GamePrompt(text: "Zendaya"),
            GamePrompt(text: "En vinsmagning"),
            GamePrompt(text: "Pokeraften"),
        ],

        // Gæt & grimasser (Charades)
        3: [
            GamePrompt(text: "Gå på line"),
            GamePrompt(text: "Lave en pizza"),
            GamePrompt(text: "En kat sidder fast i et træ"),
            GamePrompt(text: "Tage en selfie"),
            GamePrompt(text: "Køre på en rutsjebane"),
            GamePrompt(text: "Åbne en gave"),
            GamePrompt(text: "Blive fanget i regnen"),
            GamePrompt(text: "Børste tænder"),
            GamePrompt(text: "Vinde i lotto"),
            GamePrompt(text: "Spille trommer"),
            GamePrompt(text: "Svømme med hajer"),
            GamePrompt(text: "Spise noget stærkt"),
            GamePrompt(text: "Være en robot"),
            GamePrompt(text: "Gå på månen"),
            GamePrompt(text: "Fri til nogen"),
            GamePrompt(text: "Forsøge at stoppe en taxa"),
            GamePrompt(text: "Tage tætsiddende jeans på"),
            GamePrompt(text: "En kok smager sin egen mad"),
            GamePrompt(text: "Snige sig ud af huset"),
            GamePrompt(text: "Skifte en babys ble"),
            GamePrompt(text: "Tage et tequila-shot"),
            GamePrompt(text: "Gå i høje hæle for første gang"),
            GamePrompt(text: "Fange en flue med pinde"),
            GamePrompt(text: "Samle IKEA-møbel"),
            GamePrompt(text: "En DJ på et diskotek"),
            GamePrompt(text: "Vågne for sent til arbejde"),
            GamePrompt(text: "Forsøge at parallelparke"),
            GamePrompt(text: "Spille en dramatisk sæbeopera-scene"),
            GamePrompt(text: "En hund ser sin ejer komme hjem"),
            GamePrompt(text: "Blæse lys ud på en fødselsdagskage"),
            GamePrompt(text: "Sidde fast i en elevator"),
            GamePrompt(text: "En model på catwalken"),
            GamePrompt(text: "Forsøge at holde sig vågen til et møde"),
            GamePrompt(text: "Kæmpe med en paraply i vinden"),
            GamePrompt(text: "En turist der fotograferer alt"),
            GamePrompt(text: "Spille limbo"),
            GamePrompt(text: "Åbne en champagneflaske"),
            GamePrompt(text: "En person der får massage"),
            GamePrompt(text: "Løbe på et løbebånd der går for hurtigt"),
            GamePrompt(text: "En tjener der bærer for mange tallerkener"),
        ],

        // Dybe samtaler (Late Night Conversations)
        4: [
            GamePrompt(text: "Hvad er en overbevisning, du holdt stærkt for fem år siden, som du siden har ændret?"),
            GamePrompt(text: "Hvad ville du gøre anderledes, hvis ingen kiggede?"),
            GamePrompt(text: "Hvornår var du sidst virkelig i fred med dig selv?"),
            GamePrompt(text: "Hvad er noget, du aldrig har fortalt nogen ved dette bord?"),
            GamePrompt(text: "Hvad er den vigtigste lektie, et tidligere forhold har lært dig?"),
            GamePrompt(text: "Hvis du kunne tale med én person, levende eller død, hvem ville det så være?"),
            GamePrompt(text: "Hvad er du mest bange for at miste?"),
            GamePrompt(text: "Hvad betyder kærlighed for dig nu, sammenlignet med for fem år siden?"),
            GamePrompt(text: "Hvad er et lille øjeblik, der ændrede din livsbane?"),
            GamePrompt(text: "Hvad tror du, folk misforstår mest ved dig?"),
            GamePrompt(text: "Hvad er det modigste, du nogensinde har gjort?"),
            GamePrompt(text: "Hvis du havde ét år tilbage, hvordan ville du bruge det?"),
            GamePrompt(text: "Hvad er noget, du later som om du er ligeglad med, men som du faktisk bekymrer dig om?"),
            GamePrompt(text: "Hvornår følte du dig første gang som voksen?"),
            GamePrompt(text: "Hvad er et løfte, du gav dig selv, som du har holdt?"),
            GamePrompt(text: "Hvad ville dit yngre jeg tænke om, hvem du er nu?"),
            GamePrompt(text: "Hvad er det venligste, en fremmed nogensinde har gjort for dig?"),
            GamePrompt(text: "Hvilken del af din personlighed måtte du lære frem for at arve?"),
            GamePrompt(text: "Hvad er et spørgsmål, du ønsker, nogen ville stille dig?"),
            GamePrompt(text: "Hvad tror du, du kommer til at fortryde, at du ikke gjorde?"),
            GamePrompt(text: "Hvornår ændrede du sidst mening om noget vigtigt?"),
            GamePrompt(text: "Hvad er et forhold, du ønsker, du havde kæmpet hårdere for?"),
            GamePrompt(text: "Hvornår har du følt dig mest ensom, og hvad bragte dig tilbage?"),
            GamePrompt(text: "Hvad har du brug for mere af i dit liv lige nu?"),
            GamePrompt(text: "Hvilken erindring vender du hele tiden tilbage til?"),
            GamePrompt(text: "Hvad er noget, du har tilgivet dig selv for?"),
            GamePrompt(text: "Hvad ville du gerne have folk til at sige om dig til din begravelse?"),
            GamePrompt(text: "Hvad er det sværeste farvel, du nogensinde har sagt?"),
            GamePrompt(text: "Hvad fik dine forældre rigtigt? Hvad fik de forkert?"),
            GamePrompt(text: "Hvad er en version af dig selv, du måtte give slip på for at vokse?"),
            GamePrompt(text: "Hvad forsøger du stadig at finde ud af?"),
            GamePrompt(text: "Hvad ønsker du, du havde lært tidligere om kærlighed?"),
            GamePrompt(text: "Hvad er en frygt, der stille kontrollerer flere af dine beslutninger, end du bryder dig om?"),
            GamePrompt(text: "Hvad er det mest ærlige, du kunne sige til denne gruppe lige nu?"),
            GamePrompt(text: "Hvad får dig til at føle dig virkelig set af et andet menneske?"),
            GamePrompt(text: "Hvad er du vokset fra, men endnu ikke fuldt ud sluppet?"),
            GamePrompt(text: "Hvad er noget, du er taknemmelig for, som du aldrig havde forventet?"),
            GamePrompt(text: "Hvad er en samtale, der ændrede den måde, du ser verden på?"),
            GamePrompt(text: "Hvad tror du, dit liv egentlig handler om?"),
            GamePrompt(text: "Hvad er forskellen på, hvem du er, og hvem du viser folk?"),
        ],

        // Flirt & Sjov (Flirty & Fun)
        5: [
            GamePrompt(text: "Hvad er den mest tiltrækkende egenskab hos et menneske?"),
            GamePrompt(text: "Beskriv din ideelle date-aften med tre ord."),
            GamePrompt(text: "Hvad er dit kærlighedssprog?"),
            GamePrompt(text: "Hvilken sang minder dig om romantik?"),
            GamePrompt(text: "Hvad er det mest romantiske, nogen har gjort for dig?"),
            GamePrompt(text: "Giv din bedste kompliment til personen til venstre for dig."),
            GamePrompt(text: "Hvad er en dealbreaker for dig i dating?"),
            GamePrompt(text: "Hvad er det modigste, du har gjort for at imponere nogen?"),
            GamePrompt(text: "Beskriv din celebrity-crush og hvorfor."),
            GamePrompt(text: "Hvad er den mest cheesy åbningslinje, du kender? Brug den nu."),
            GamePrompt(text: "Hvilket tøj får dig til at føle dig mest selvsikker?"),
            GamePrompt(text: "Hvad er det første, du lægger mærke til ved en person?"),
            GamePrompt(text: "Hvad er det mest flirtende, du nogensinde har sagt til nogen?"),
            GamePrompt(text: "Hvis du kunne planlægge en drømmdate uden budget, hvordan ville den se ud?"),
            GamePrompt(text: "Hvad er en guilty pleasure-sang, du hemmeligt finder romantisk?"),
            GamePrompt(text: "Beskriv det bedste kys, du nogensinde har haft — uden at nævne navne."),
            GamePrompt(text: "Hvad er det største grønne flag på en første date?"),
            GamePrompt(text: "Hold øjenkontakt med en ved bordet i 10 sekunder uden at grine."),
            GamePrompt(text: "Hvad er et kompliment, du har modtaget, som du stadig tænker på?"),
            GamePrompt(text: "Hvilken filmscene fik dig til at tro på kærlighed?"),
            GamePrompt(text: "Hvem ved dette bord vil du helst sidde fast på en øde ø med?"),
            GamePrompt(text: "Hvad er den mest romantiske by i verden?"),
            GamePrompt(text: "Hvad er dit signaturmove, når du flirter?"),
            GamePrompt(text: "Hold handen på personen over for dig de næste to runder."),
            GamePrompt(text: "Hvilken duft på en anden person gør dig svimmel?"),
            GamePrompt(text: "Hvad er det mest undervurderede ved at være i et forhold?"),
            GamePrompt(text: "Hvad er det mest spontane, du har gjort for en crush?"),
            GamePrompt(text: "Hvis nogen skrev et kærlighedsbrev til dig, hvad ville du gerne have, det sagde?"),
            GamePrompt(text: "Hvilken sang ville du have spillet under en langsom dans?"),
            GamePrompt(text: "Udbring en skål for den mest attraktive person ved bordet."),
            GamePrompt(text: "Hvilken dating-trend hader du absolut?"),
            GamePrompt(text: "Hvad er den bedste åbningslinje, nogen nogensinde har brugt på dig?"),
            GamePrompt(text: "Hvisk noget rart i øret på personen ved siden af dig."),
            GamePrompt(text: "Hvad er din idé om en perfekt morgen med én, du elsker?"),
            GamePrompt(text: "Hvad er et fysisk træk, du finder attraktivt, som de fleste overser?"),
            GamePrompt(text: "Hvad er det mest romantiske, du har gjort, som ingen ved?"),
            GamePrompt(text: "Hvis dette bord var et datingshow, hvem ville så få den sidste rose?"),
            GamePrompt(text: "Hvad er en date, du var på, der startede dårligt men sluttede perfekt?"),
            GamePrompt(text: "Send en ægte kompliment til én i din telefonbog lige nu."),
            GamePrompt(text: "Hvad er den mest sexy accent i verden?"),
        ],

        // Udfordringer (High Stakes)
        6: [
            GamePrompt(text: "Lad gruppen gennemgå dine sidste 5 fotos."),
            GamePrompt(text: "Send 'Jeg savner dig' til den tredje person i dine kontakter."),
            GamePrompt(text: "Gør dit bedste indtryk af én i rummet."),
            GamePrompt(text: "Vis gruppen din skærmtidsrapport."),
            GamePrompt(text: "Lad nogen poste en story på din Instagram."),
            GamePrompt(text: "Ring til din mor og fortæl hende, at du skal giftes."),
            GamePrompt(text: "Læs din seneste afsendte besked højt."),
            GamePrompt(text: "Lad gruppen skrive en besked til din crush."),
            GamePrompt(text: "Lav 20 armstrækninger nu eller drik din drink ud."),
            GamePrompt(text: "Del dit mest pinlige øjeblik."),
            GamePrompt(text: "Lad nogen gennemgå din søgehistorik i 30 sekunder."),
            GamePrompt(text: "Tal med accent de næste 3 runder."),
            GamePrompt(text: "Vis gruppen din mest-afspillede sang på Spotify."),
            GamePrompt(text: "Lad gruppen vælge én i dine kontakter, og du skal ringe til dem."),
            GamePrompt(text: "Læs det seneste, du skrev i din Notes-app, højt."),
            GamePrompt(text: "Vis dit mest pinlige gemte foto."),
            GamePrompt(text: "Send en voicebesked til din bedste ven med 'Jeg elsker dig' dramatisk."),
            GamePrompt(text: "Lad nogen skrive og sende et story-svar på dine vegne."),
            GamePrompt(text: "Lås din telefon op og ræk den til personen til højre for dig i 30 sekunder."),
            GamePrompt(text: "Afslør det sidste, du googlede."),
            GamePrompt(text: "Post en selfie lige nu uden filter og uden at tage om."),
            GamePrompt(text: "Lad gruppen læse dine seneste fem DM'er på Instagram."),
            GamePrompt(text: "Lav en dramatisk oplæsning af din seneste email."),
            GamePrompt(text: "Vis gruppen dit gennemsnitlige daglige skærmforbrug."),
            GamePrompt(text: "Send en enkelt emoji til din eks, valgt af gruppen."),
            GamePrompt(text: "Byt telefon med nogen de næste to runder."),
            GamePrompt(text: "Afslør den seneste person, hvis profil du har stalket på sociale medier."),
            GamePrompt(text: "Lad gruppen skrive og sende et opslag fra din konto."),
            GamePrompt(text: "Vis gruppen den seneste video i dit kamerarulle."),
            GamePrompt(text: "Ring til en ven og sæt dem på højtaler — spørg dem om din bedste egenskab og dårligste vane."),
            GamePrompt(text: "Del den seneste løgn, du fortalte, og hvem du fortalte den til."),
            GamePrompt(text: "Giv personen over for dig din telefon og lad dem sende én besked."),
            GamePrompt(text: "Afslør det dyreste, du har købt, som du fortryder."),
            GamePrompt(text: "Vis gruppen din mest-brugte emoji — og forklar dig."),
            GamePrompt(text: "Lad gruppen ændre din låseskærm de næste 24 timer."),
            GamePrompt(text: "Afslør det seneste, du lagde i din online indkøbskurv."),
            GamePrompt(text: "Optag en 15-sekunders video med en tilståelse og post den til dine tætte venner."),
            GamePrompt(text: "Vis gruppen din Spotify Wrapped-topkunstner."),
            GamePrompt(text: "Lad nogen gennemgå din 'Følger'-liste og spørge om hvem som helst."),
            GamePrompt(text: "Ring til den seneste, du sendte en besked til, og syng lykkelig fødselsdag."),
        ],
    ]
    // swiftlint:enable line_length
}
