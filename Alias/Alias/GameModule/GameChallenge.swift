import Foundation

public enum GameChallenge: String, CaseIterable, Codable, Identifiable, Hashable {
    case whisper
    case robotVoice
    case commentator
    case scaryStory
    case slowly
    case noGestures
    case noFillerWords
    case shortSentences
    case firstPerson
    case imagineOpening

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .whisper: return "Шёпотом"
        case .robotVoice: return "Голос робота"
        case .commentator: return "Комментатор"
        case .scaryStory: return "Страшная история"
        case .slowly: return "Очень медленно"
        case .noGestures: return "Без жестов"
        case .noFillerWords: return "Без слов-подсказок"
        case .shortSentences: return "Короткие предложения"
        case .firstPerson: return "От первого лица"
        case .imagineOpening: return "Начни с «Представь»"
        }
    }

    public var instruction: String {
        switch self {
        case .whisper:
            return "Объясняй слово только шёпотом."
        case .robotVoice:
            return "Говори монотонным голосом робота."
        case .commentator:
            return "Объясняй как спортивный комментатор в прямом эфире."
        case .scaryStory:
            return "Объясняй так, будто рассказываешь страшную историю."
        case .slowly:
            return "Произноси каждое слово очень медленно."
        case .noGestures:
            return "Не используй руки, мимику и другие жесты."
        case .noFillerWords:
            return "Не произноси слова «это», «такой» и «штука»."
        case .shortSentences:
            return "Используй не больше трёх слов в одном предложении."
        case .firstPerson:
            return "Говори от первого лица, будто ты и есть загаданное слово."
        case .imagineOpening:
            return "Каждое новое объяснение начинай со слова «Представь»."
        }
    }

    public var symbolName: String {
        switch self {
        case .whisper: return PartyIcon.whisper.systemName
        case .robotVoice: return PartyIcon.robotVoice.systemName
        case .commentator: return PartyIcon.commentator.systemName
        case .scaryStory: return PartyIcon.scaryStory.systemName
        case .slowly: return PartyIcon.slowly.systemName
        case .noGestures: return PartyIcon.noGestures.systemName
        case .noFillerWords: return PartyIcon.noFillerWords.systemName
        case .shortSentences: return PartyIcon.shortSentences.systemName
        case .firstPerson: return PartyIcon.firstPerson.systemName
        case .imagineOpening: return PartyIcon.imagineOpening.systemName
        }
    }

    static func fromLegacyValue(_ value: String) -> GameChallenge? {
        allCases.first { $0.rawValue == value || $0.title == value }
    }
}
