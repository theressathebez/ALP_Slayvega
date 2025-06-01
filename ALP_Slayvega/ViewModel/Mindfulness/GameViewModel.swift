//
//  GameViewModel.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import Combine
import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var gameState = GameState()

    @Published var currentBreathingPhase: BreathingPhase = .pause
    @Published var phaseProgress: Double = 0.0
    @Published var cycleCount: Int = 0
    @Published var isBreathingSessionActive = false
    @Published var breathingModeEnabled = false

    private var breathingTimer: Timer?
    private var phaseTimer: Timer?
    private var gameTimer: Timer?
    private var pressureTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentPhase: Breathing = .inhale
    @Published var timeRemaining: Int = 4
    @Published var currentSet: Int = 1
    @Published var totalSets: Int = 3
    @Published var isActive: Bool = false
    @Published var isCompleted: Bool = false
    @Published var breathingProgress: Double = 0.0
    @Published var pressureMessages: [PressureMessage] = []
    @Published var affirmationText: String = ""
    @Published var showAffirmation: Bool = false
    @Published var cloudOpacity: Double = 0.8


    private var timer: Timer?

    // MARK: - Game Control Methods

    func startGame() {
        resetTimers()
        gameState.gameStartTime = Date()
        gameState.backgroundColors = getInitialColors()
        startGameTimer()
        startPressureTimer()
        updateBackgroundToCalm()
        addInitialPressure()

        // Start with 4-7-8 breathing by default
        cycleCount = 0
        startBreathingSession()
    }

    func resetGame() {
        resetTimers()
        gameState = GameState()
        currentBreathingPhase = .pause
        phaseProgress = 0.0
        cycleCount = 0
        startGame()
    }

    func endGame() {
        resetTimers()
        gameState.currentReflection = getRandomReflection()
        gameState.showReflection = true
        gameState.backgroundColors = getFinalColors()
    }
    
    // MARK: - 4-7-8 Breathing Methods

    func toggleBreathingMode() {
        breathingModeEnabled.toggle()

        if breathingModeEnabled {
            startBreathingSession()
        } else {
            stopBreathingSession()
        }
    }

    func startBreathingSession() {
        isBreathingSessionActive = true
        currentBreathingPhase = .inhale
        phaseProgress = 0.0
        cycleCount = 0
        startBreathingCycle()
    }

    func stopBreathingSession() {
        isBreathingSessionActive = false
        breathingTimer?.invalidate()
        phaseTimer?.invalidate()
        currentBreathingPhase = .pause
        phaseProgress = 0.0
        gameState.isBreathing = false
        gameState.breathingRadius = GameConfiguration.breathingRadiusNormal
    }

    private func startBreathingCycle() {
        guard isBreathingSessionActive else { return }

        startPhase(currentBreathingPhase)
    }

    private func startPhase(_ phase: BreathingPhase) {
        currentBreathingPhase = phase
        phaseProgress = 0.0

        // Update visual state based on phase
        updateVisualStateForPhase(phase)

        // Start phase timer
        let phaseDuration = phase.duration
        let updateInterval = 0.1
        let totalSteps = phaseDuration / updateInterval
        var currentStep = 0.0

        phaseTimer?.invalidate()
        phaseTimer = Timer.scheduledTimer(
            withTimeInterval: updateInterval, repeats: true
        ) { [weak self] timer in
            guard let self = self else { return }

            currentStep += 1
            self.phaseProgress = currentStep / totalSteps

            if self.phaseProgress >= 1.0 {
                timer.invalidate()
                self.moveToNextPhase()
            }
        }
    }

    private func updateVisualStateForPhase(_ phase: BreathingPhase) {
        switch phase {
        case .inhale:
            gameState.isBreathing = true
            gameState.breathingRadius =
                GameConfiguration.breathingRadiusExpanded
            removePressureOnBreathing()

        case .hold:
            gameState.isBreathing = true
            gameState.breathingRadius =
                GameConfiguration.breathingRadiusExpanded

        case .exhale:
            gameState.isBreathing = false
            gameState.breathingRadius = GameConfiguration.breathingRadiusNormal

        case .pause:
            gameState.isBreathing = false
            gameState.breathingRadius = GameConfiguration.breathingRadiusNormal
        }
    }

    private func moveToNextPhase() {
        guard isBreathingSessionActive else { return }

        switch currentBreathingPhase {
        case .inhale:
            startPhase(.hold)
        case .hold:
            startPhase(.exhale)
        case .exhale:
            cycleCount += 1
            startPhase(.pause)
        case .pause:
            // Check if we should continue or complete the session
            if cycleCount < 4 {  // Complete 4 cycles
                startPhase(.inhale)
            } else {
                completeBreathingSession()
            }
        }
    }

    private func completeBreathingSession() {
        stopBreathingSession()
        // Add positive elements for completing the session
        addPositiveElement()
        addPositiveElement()
    }

    // MARK: - Legacy Breathing Actions (for compatibility)

    func stopBreathing() {
        if !breathingModeEnabled {
            gameState.isBreathing = false
            gameState.breathingRadius = GameConfiguration.breathingRadiusNormal
        }
    }

    // MARK: - Reflection Actions

    func startReflectionAnimation() {
        gameState.reflectionScale = 1.2
    }

    // MARK: - Timer Management

    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] _ in
            self?.updateGameProgress()
        }
    }

    private func startPressureTimer() {
        pressureTimer = Timer.scheduledTimer(
            withTimeInterval: GameConfiguration.pressureSpawnInterval,
            repeats: true
        ) { [weak self] _ in
            self?.addRandomPressure()
        }
    }

    private func resetTimers() {
        gameTimer?.invalidate()
        pressureTimer?.invalidate()
        breathingTimer?.invalidate()
        phaseTimer?.invalidate()
        gameTimer = nil
        pressureTimer = nil
        breathingTimer = nil
        phaseTimer = nil
    }

    // MARK: - Game Progress Logic

    private func updateGameProgress() {
        guard let startTime = gameState.gameStartTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)

        // Enhanced progress calculation including breathing cycles
        let baseProgress = elapsed / GameConfiguration.gameDuration
        let breathingBonus = Double(cycleCount) * 0.1  // 10% bonus per completed cycle

        gameState.progress = min(baseProgress + breathingBonus, 1.0)

        updateBackgroundColorsBasedOnProgress()

        if gameState.progress >= 1.0 {
            endGame()
        }
    }

    // MARK: - Pressure Management

    private func addInitialPressure() {
        addRandomPressure()
    }

    private func addRandomPressure() {
        let text = getRandomPressureText()
        let pressure = createPressure(with: text)
        gameState.activePressures.append(pressure)
        cleanupOldPressures()
    }

    private func createPressure(with text: String) -> PeerPressure {
        PeerPressure(
            text: text,
            offset: CGSize(
                width: CGFloat.random(in: -120...120),
                height: CGFloat.random(in: -60...60)
            )
        )
    }

    private func cleanupOldPressures() {
        gameState.activePressures.removeAll { $0.shouldRemove }
    }

    private func removePressureOnBreathing() {
        guard !gameState.activePressures.isEmpty else { return }

        // Remove multiple pressures during breathing session
        let removalCount =
            breathingModeEnabled ? min(2, gameState.activePressures.count) : 1

        for _ in 0..<removalCount {
            if !gameState.activePressures.isEmpty {
                let randomIndex = Int.random(
                    in: 0..<gameState.activePressures.count)
                gameState.activePressures[randomIndex].startDisappearing()
            }
        }

        addPositiveElement()
    }

    // MARK: - Positive Elements Management

    private func addPositiveElement() {
        let symbol = getRandomPositiveSymbol()
        let element = createPositiveElement(with: symbol)
        gameState.positiveElements.append(element)

        animatePositiveElementIn(element)
        schedulePositiveElementRemoval(element)
    }

    private func createPositiveElement(with symbol: String) -> PositiveElement {
        PositiveElement(
            symbol: symbol,
            offset: CGSize(
                width: CGFloat.random(in: -100...100),
                height: CGFloat.random(in: -50...50)
            )
        )
    }

    private func animatePositiveElementIn(_ element: PositiveElement) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let index = self.gameState.positiveElements.firstIndex(where: {
                $0.id == element.id
            }) {
                self.gameState.positiveElements[index].opacity = 1.0
                self.gameState.positiveElements[index].scale = 1.2
            }
        }
    }

    private func schedulePositiveElementRemoval(_ element: PositiveElement) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.gameState.positiveElements.removeAll { $0.id == element.id }
        }
    }

    // MARK: - Color Management

    private func getInitialColors() -> [Color] {
        [Color.gray.opacity(0.8), Color.gray.opacity(0.6)]
    }

    private func getFinalColors() -> [Color] {
        [Color.green.opacity(0.4), Color.blue.opacity(0.3)]
    }

    private func updateBackgroundColorsBasedOnProgress() {
        let calmness = gameState.progress
        gameState.backgroundColors = [
            interpolateColor(
                from: Color.gray.opacity(0.8),
                to: Color.blue.opacity(0.6),
                progress: calmness
            ),
            interpolateColor(
                from: Color.gray.opacity(0.6),
                to: Color.purple.opacity(0.4),
                progress: calmness
            ),
        ]
    }

    private func interpolateColor(
        from startColor: Color, to endColor: Color, progress: Double
    ) -> Color {
        let clampedProgress = min(max(progress, 0.0), 1.0)
        return Color(
            red: (1 - clampedProgress) * 0.5 + clampedProgress
                * (endColor == Color.blue.opacity(0.6) ? 0.0 : 0.5),
            green: (1 - clampedProgress) * 0.5 + clampedProgress
                * (endColor == Color.blue.opacity(0.6) ? 0.0 : 0.2),
            blue: (1 - clampedProgress) * 0.5 + clampedProgress
                * (endColor == Color.blue.opacity(0.6) ? 0.6 : 0.4),
            opacity: (1 - clampedProgress) * 0.7 + clampedProgress * 0.5
        )
    }

    private func updateBackgroundToCalm() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.gameState.backgroundColors = [
                Color.blue.opacity(0.6),
                Color.purple.opacity(0.4),
            ]
        }
    }
    
    

    private let pressureTexts = [
        "Cepat sukses", "Harus selalu produktif", "Temanmu sudah lebih dulu",
        "Waktu terus berjalan", "Semua orang menunggu", "Jangan tertinggal",
        "Harus sempurna", "Tidak boleh gagal",
    ]

    init() {
        setupPressureMessages()
    }

    private func setupPressureMessages() {
        pressureMessages = pressureTexts.enumerated().map { index, text in
            PressureMessage(
                text: text,
                offset: CGSize(
                    width: CGFloat.random(in: -100...100),
                    height: CGFloat.random(in: -150...150)
                ),
                opacity: Double.random(in: 0.3...0.7)
            )
        }
    }

    func startBreathing() {
        guard !isActive else { return }

        isActive = true
        isCompleted = false
        currentSet = 1
        currentPhase = .inhale
        timeRemaining = Int(currentPhase.duration)
        breathingProgress = 0.0
        showAffirmation = false
        cloudOpacity = 0.8

        startTimer()
        startBreathingAnimation()
    }

    func pauseBreathing() {
        isActive = false
        timer?.invalidate()
        breathingTimer?.invalidate()
    }

    func resetBreathing() {
        isActive = false
        isCompleted = false
        currentSet = 1
        currentPhase = .inhale
        timeRemaining = Int(currentPhase.duration)
        breathingProgress = 0.0
        showAffirmation = false
        cloudOpacity = 0.8

        timer?.invalidate()
        breathingTimer?.invalidate()

        setupPressureMessages()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            DispatchQueue.main.async {
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.nextPhase()
                }
            }
        }
    }

    private func startBreathingAnimation() {
        breathingTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1, repeats: true
        ) { _ in
            DispatchQueue.main.async {
                let totalDuration = self.currentPhase.duration
                let elapsed = totalDuration - Double(self.timeRemaining)
                self.breathingProgress = elapsed / totalDuration

                // Update cloud opacity based on current set
                let setProgress =
                    Double(self.currentSet - 1) / Double(self.totalSets - 1)
                self.cloudOpacity = 0.8 - (setProgress * 0.6)
            }
        }
    }

    private func nextPhase() {
        switch currentPhase {
        case .inhale:
            currentPhase = .hold
        case .hold:
            currentPhase = .exhale
        case .exhale:
            // Complete one set
            if currentSet < totalSets {
                currentSet += 1
                currentPhase = .inhale
            } else {
                // All sets completed
                completeBreathing()
                return
            }
        @unknown default:
            break
        }

        timeRemaining = Int(currentPhase.duration)
        breathingProgress = 0.0
    }

    private func completeBreathing() {
        isActive = false
        isCompleted = true
        timer?.invalidate()
        breathingTimer?.invalidate()

        // Show affirmation
        affirmationText =
            Affirmation.messages.randomElement() ?? "You did great!"
        showAffirmation = true
        cloudOpacity = 0.0
    }
    

    // MARK: - Data Helpers

    private func getRandomPressureText() -> String {
        GameConfiguration.pressureTexts.randomElement() ?? "You're doing great!"
    }

    private func getRandomPositiveSymbol() -> String {
        GameConfiguration.positiveSymbols.randomElement() ?? "🌸"
    }

    private func getRandomReflection() -> String {
        GameConfiguration.reflectionMessages.randomElement()
            ?? "You are enough."
    }
}
