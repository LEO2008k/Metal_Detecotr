import Foundation
import SwiftUI

/// Centralized localization manager supporting Ukrainian and English.
/// Supports both auto-detection from device and manual override from Settings.
@Observable
final class Localizer: @unchecked Sendable {
    
    /// Shared singleton instance
    static let shared = Localizer()
    
    /// Available languages
    enum Language: String, CaseIterable, Identifiable {
        case auto = "auto"
        case ukrainian = "uk"
        case english = "en"
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .auto: return "🌐 Auto"
            case .ukrainian: return "🇺🇦 Українська"
            case .english: return "🇬🇧 English"
            }
        }
    }
    
    /// Currently selected language (persisted in UserDefaults)
    var selectedLanguage: Language {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "app_language")
        }
    }
    
    private init() {
        let saved = UserDefaults.standard.string(forKey: "app_language") ?? "auto"
        self.selectedLanguage = Language(rawValue: saved) ?? .auto
    }
    
    /// Whether we should use Ukrainian strings
    var isUkrainian: Bool {
        switch selectedLanguage {
        case .auto:
            guard let langCode = Locale.current.language.languageCode?.identifier else { return false }
            return langCode == "uk"
        case .ukrainian:
            return true
        case .english:
            return false
        }
    }
}

// MARK: - Localized Strings

struct L10n {
    
    private static var loc: Localizer { Localizer.shared }
    private static var isUkrainian: Bool { loc.isUkrainian }
    
    // MARK: - Main Screen
    
    static var appTitle: String { "MetalDetector" }
    static var subtitle: String { isUkrainian ? "Магнітометр" : "Magnetometer" }
    static var readyToSearch: String { isUkrainian ? "Готовий до пошуку" : "Ready to search" }
    static var calibrating: String { isUkrainian ? "Калібрування..." : "Calibrating..." }
    static var scanning: String { isUkrainian ? "Скануємо..." : "Scanning..." }
    static var stopped: String { isUkrainian ? "Зупинено" : "Stopped" }
    
    // MARK: - Detection Levels
    
    static var noSignal: String { isUkrainian ? "Немає сигналу" : "No signal" }
    static var weakSignal: String { isUkrainian ? "Слабкий сигнал" : "Weak signal" }
    static var moderateSignal: String { isUkrainian ? "Помірний сигнал" : "Moderate signal" }
    static var strongSignal: String { isUkrainian ? "Сильний сигнал!" : "Strong signal!" }
    static var veryStrongSignal: String { isUkrainian ? "Дуже сильний! 🎯" : "Very strong! 🎯" }
    
    // MARK: - Stats
    
    static var time: String { isUkrainian ? "Час" : "Time" }
    static var baseline: String { isUkrainian ? "Базова" : "Baseline" }
    static var peak: String { isUkrainian ? "Пік" : "Peak" }
    
    // MARK: - Controls
    
    static var calibrate: String { isUkrainian ? "Калібрувати" : "Calibrate" }
    static var sound: String { isUkrainian ? "Звук" : "Sound" }
    static var muted: String { isUkrainian ? "Тиша" : "Muted" }
    
    // MARK: - Waveform
    
    static var waveform: String { isUkrainian ? "Хвильова форма" : "Waveform" }
    static var collectingData: String { isUkrainian ? "Збираємо дані..." : "Collecting data..." }
    
    // MARK: - Settings
    
    static var settings: String { isUkrainian ? "Налаштування" : "Settings" }
    static var done: String { isUkrainian ? "Готово" : "Done" }
    static var feedback: String { isUkrainian ? "Зворотній зв'язок" : "Feedback" }
    static var audioSignal: String { isUkrainian ? "Звуковий сигнал" : "Audio signal" }
    static var audioDescription: String { isUkrainian ? "VCO-стиль тональний зворотній зв'язок" : "VCO-style tonal feedback" }
    static var hapticFeedback: String { isUkrainian ? "Тактильний відгук" : "Haptic feedback" }
    static var hapticDescription: String { isUkrainian ? "Вібрація при виявленні металу" : "Vibration on metal detection" }
    static var language: String { isUkrainian ? "Мова" : "Language" }
    static var aboutApp: String { isUkrainian ? "Про додаток" : "About" }
    static var sensor: String { isUkrainian ? "Сенсор" : "Sensor" }
    static var magnetometer: String { isUkrainian ? "Магнітометр" : "Magnetometer" }
    static var filter: String { isUkrainian ? "Фільтр" : "Filter" }
    static var frequency: String { isUkrainian ? "Частота" : "Frequency" }
    static var limitations: String { "⚠️ " + (isUkrainian ? "Обмеження" : "Limitations") }
    static var limitationText1: String {
        isUkrainian
        ? "Магнітометр може виявляти лише **феромагнітні** метали (залізо, сталь, нікель)."
        : "Magnetometer can only detect **ferromagnetic** metals (iron, steel, nickel)."
    }
    static var limitationText2: String {
        isUkrainian
        ? "Немагнітні метали (золото, срібло, мідь, алюміній) **не можуть бути виявлені** цим методом."
        : "Non-magnetic metals (gold, silver, copper, aluminum) **cannot be detected** by this method."
    }
    static var versionInfo: String {
        isUkrainian
        ? "MetalDetector v\(AppVersion.version) • Магнітометр iPhone"
        : "MetalDetector v\(AppVersion.version) • iPhone Magnetometer"
    }
    
    // MARK: - Bubble Level
    
    static var metalDetector: String { isUkrainian ? "Металошукач" : "Metal Detector" }
    static var bubbleLevel: String { isUkrainian ? "Рівень" : "Spirit Level" }
    static var bubbleLevelSubtitle: String { isUkrainian ? "Будівельний рівень" : "Bubble Level" }
    static var leftRight: String { isUkrainian ? "Ліво-Право" : "Left-Right" }
    static var frontBack: String { isUkrainian ? "Перед-Зад" : "Front-Back" }
    static var levelPerfect: String { isUkrainian ? "Ідеально рівно! ✅" : "Perfectly level! ✅" }
    static var levelSlightTilt: String { isUkrainian ? "Невеликий нахил" : "Slight tilt" }
    static var levelTilted: String { isUkrainian ? "Нахилено ⚠️" : "Tilted ⚠️" }
    
    // MARK: - Vertical Indicator
    
    static var above: String { isUkrainian ? "ВГОРІ" : "ABOVE" }
    static var below: String { isUkrainian ? "ВНИЗУ" : "BELOW" }
}
