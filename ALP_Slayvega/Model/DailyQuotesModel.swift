import Foundation

struct DailyQuoteSchedule {
    let date: Date
    let showTimes: [Date]

    static func generateRandomSchedule(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        let numberOfQuotes = Int.random(in: 4...5)
        var randomTimes: [Date] = []

        let timeWindows = [
            (7, 10),   // Morning
            (11, 14),  // Midday
            (15, 18),  // Afternoon
            (19, 22)   // Evening
        ]

        let selectedWindows = timeWindows.shuffled().prefix(numberOfQuotes)

        for (startHour, endHour) in selectedWindows {
            let hour = Int.random(in: startHour...endHour)
            let minute = Int.random(in: 0...59)

            var components = calendar.dateComponents([.year, .month, .day], from: startOfDay)
            components.hour = hour
            components.minute = minute

            if let finalDate = calendar.date(from: components) {
                randomTimes.append(finalDate)
            }
        }

        return randomTimes.sorted()
    }
}
