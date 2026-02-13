import Foundation

/// Centralized localization manager supporting Ukrainian and English.
/// Automatically detects device language.
struct L10n {
    
    /// Whether the current device language is Ukrainian
    static var isUkrainian: Bool {
        guard let langCode = Locale.current.language.languageCode?.identifier else { return false }
        return langCode == "uk"
    }
    
    // MARK: - Main Screen
    
    static var appTitle: String { isUkrainian ? "MetalDetector" : "MetalDetector" }
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
        ? "MetalDetector v1.0 • Магнітометр iPhone"
        : "MetalDetector v1.0 • iPhone Magnetometer"
    }
}
