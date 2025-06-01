//
//  GameConfiguration.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import Foundation

struct GameConfiguration {
    static let gameDuration: TimeInterval = 180  // 3 minutes
    static let pressureSpawnInterval: TimeInterval = 5.0
    static let breathingRadiusExpanded: CGFloat = 120
    static let breathingRadiusNormal: CGFloat = 80

    static let pressureTexts = [
        "Aku cukup dan berharga apa adanya.",
        "Aku berhak memilih jalanku sendiri.",
        "Aku percaya pada diriku sendiri.",
        "Aku tidak harus menyenangkan semua orang.",
        "Aku kuat, tangguh, dan mampu mengatasi ini.",
        "Pilihan hidupku valid meski berbeda dari yang lain.",
        "Aku tumbuh dan belajar setiap hari.",
        "Aku tidak perlu membandingkan diriku dengan orang lain.",
        "Aku boleh istirahat tanpa merasa bersalah.",
        "Aku layak mendapatkan cinta dan rasa hormat.",
        "Kesalahanku tidak mendefinisikan siapa aku.",
        "Aku punya hak untuk berkata tidak.",
        "Aku mendengarkan dan menghargai diriku sendiri.",
        "Setiap langkah kecil tetap sebuah kemajuan.",
        "Aku memilih hidup dengan caraku sendiri.",
        "Aku pantas merayakan pencapaianku sekecil apa pun.",
        "Aku tidak sendiri dalam perjalanan ini.",
        "Aku bebas dari tekanan yang tidak membangun.",
        "Aku menciptakan ruang untuk damai dan bahagia.",
        "Aku mengizinkan diriku untuk merasa dan sembuh.",
    ]

    static let reflectionMessages = [
        "You are exactly where you need to be.",
        "Your journey is unique and valuable.",
        "Progress isn't always visible, but it's happening.",
        "You don't need to prove anything to anyone.",
        "Your worth isn't measured by others' expectations.",
        "Every small step counts.",
        "You are enough, just as you are.",
    ]

    static let positiveSymbols = ["🌸", "⭐", "☁️", "🦋", "✨", "🌿"]
}
