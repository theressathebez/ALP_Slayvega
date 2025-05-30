import SwiftUI


class QuotesViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var currentQuote: Quote?
    @Published var currentQuoteIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var dailyQuotesShown: [Quote] = []
    @Published var nextQuoteTime: Date?
    @Published var quotesLeftToday: Int = 0
    @Published var isAnimating: Bool = false
    
    private var timer: Timer?
    private var dailySchedule: [Date] = []
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSampleQuotes()
        setupDailySchedule()
        startQuoteTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func loadSampleQuotes() {
        quotes = [
            Quote(text: "The universe will provide for me", emoji1: "🫧", emoji2: "🌍"),
            Quote(text: "Everything happens for a reason", emoji1: "✨", emoji2: "🌟"),
            Quote(text: "Trust the process of life", emoji1: "🌱", emoji2: "🦋"),
            Quote(text: "I am exactly where I need to be", emoji1: "🧘‍♀️", emoji2: "🌸"),
            Quote(text: "Today is full of possibilities", emoji1: "🌅", emoji2: "🚀"),
            Quote(text: "Every moment is a fresh beginning", emoji1: "🌿", emoji2: "☀️"),
            Quote(text: "I attract positive energy", emoji1: "⭐", emoji2: "💫"),
            Quote(text: "My dreams are becoming reality", emoji1: "🌙", emoji2: "✨"),
            Quote(text: "I am grateful for this moment", emoji1: "🙏", emoji2: "💝"),
            Quote(text: "Life flows through me with ease", emoji1: "🌊", emoji2: "🐚"),
            Quote(text: "I choose peace over perfection", emoji1: "🕊️", emoji2: "🌺"),
            Quote(text: "Magic happens outside my comfort zone", emoji1: "🔮", emoji2: "🎭"),
            Quote(text: "I am becoming who I'm meant to be", emoji1: "🦋", emoji2: "🌟"),
            Quote(text: "Today I create my own sunshine", emoji1: "☀️", emoji2: "🌻"),
            Quote(text: "Every challenge is an opportunity", emoji1: "💎", emoji2: "🏔️")
        ]
        
        if currentQuote == nil && !quotes.isEmpty {
            currentQuote = quotes[0]
            currentQuoteIndex = 0
        }
    }
    
    private func setupDailySchedule() {
        let today = Date()
        let calendar = Calendar.current
        
        let lastScheduleDate = userDefaults.object(forKey: "lastScheduleDate") as? Date
        let isNewDay = lastScheduleDate == nil || !calendar.isDate(today, inSameDayAs: lastScheduleDate!)
        
        if isNewDay {
            dailySchedule = DailyQuoteSchedule.generateRandomSchedule(for: today)
            dailyQuotesShown = []
            
            userDefaults.set(today, forKey: "lastScheduleDate")
            if let encodedSchedule = try? JSONEncoder().encode(dailySchedule) {
                userDefaults.set(encodedSchedule, forKey: "dailySchedule")
            }
            userDefaults.set([], forKey: "dailyQuotesShown")
        } else {
            if let scheduleData = userDefaults.data(forKey: "dailySchedule"),
               let schedule = try? JSONDecoder().decode([Date].self, from: scheduleData) {
                dailySchedule = schedule
            }
            
            if let shownQuotesData = userDefaults.data(forKey: "dailyQuotesShown"),
               let shownQuotes = try? JSONDecoder().decode([Quote].self, from: shownQuotesData) {
                dailyQuotesShown = shownQuotes
            }
        }
        
        updateNextQuoteTime()
        updateQuotesLeftToday()
    }
    
    private func startQuoteTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkForScheduledQuote()
        }
    }
    
    private func checkForScheduledQuote() {
        let now = Date()
        
        for (index, scheduledTime) in dailySchedule.enumerated() {
            if now >= scheduledTime && !hasQuoteBeenShownAt(index) {
                showNewQuote()
                markQuoteAsShown(at: index)
                break
            }
        }
        
        updateNextQuoteTime()
        updateQuotesLeftToday()
    }
    
    private func hasQuoteBeenShownAt(_ index: Int) -> Bool {
        return dailyQuotesShown.count > index
    }
    
    private func markQuoteAsShown(at index: Int) {
        if let encodedQuotes = try? JSONEncoder().encode(dailyQuotesShown) {
            userDefaults.set(encodedQuotes, forKey: "dailyQuotesShown")
        }
    }
    
    private func showNewQuote() {
        let usedQuoteTexts = Set(dailyQuotesShown.map { $0.text })
        let availableQuotes = quotes.filter { !usedQuoteTexts.contains($0.text) }
        
        if let newQuote = availableQuotes.randomElement() {
            withAnimation(.easeInOut(duration: 0.5)) {
                currentQuote = newQuote
                if let index = quotes.firstIndex(where: { $0.text == newQuote.text }) {
                    currentQuoteIndex = index
                }
            }
            dailyQuotesShown.append(newQuote)
        }
    }
    
    private func updateNextQuoteTime() {
        let now = Date()
        nextQuoteTime = dailySchedule.first { $0 > now }
    }
    
    private func updateQuotesLeftToday() {
        quotesLeftToday = max(0, dailySchedule.count - dailyQuotesShown.count)
    }
    
    func getRandomQuote() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isAnimating = true
            currentQuote = quotes.randomElement()
            if let quote = currentQuote,
               let index = quotes.firstIndex(where: { $0.text == quote.text }) {
                currentQuoteIndex = index
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnimating = false
        }
    }
    
    func getNextQuote() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isAnimating = true
            currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
            currentQuote = quotes[currentQuoteIndex]
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnimating = false
        }
    }
    
    func getPreviousQuote() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isAnimating = true
            currentQuoteIndex = currentQuoteIndex == 0 ? quotes.count - 1 : currentQuoteIndex - 1
            currentQuote = quotes[currentQuoteIndex]
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnimating = false
        }
    }
    
    func getCurrentQuote() -> Quote? {
        return currentQuote ?? dailyQuotesShown.last
    }
    
    func getDailyProgress() -> (shown: Int, total: Int) {
        return (dailyQuotesShown.count, dailySchedule.count)
    }
    
    func getNextQuoteCountdown() -> String {
        guard let nextTime = nextQuoteTime else {
            return "No more quotes today"
        }
        
        let now = Date()
        let timeInterval = nextTime.timeIntervalSince(now)
        
        if timeInterval <= 0 {
            return "Quote coming soon..."
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "Next quote in \(hours)h \(minutes)m"
        } else {
            return "Next quote in \(minutes)m"
        }
    }
    
    func fetchQuotes() async {
        isLoading = true
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            loadSampleQuotes()
            setupDailySchedule()
            
            if currentQuote == nil {
                currentQuote = getCurrentQuote() ?? quotes.first
            }
            
            isLoading = false
        }
    }
}
