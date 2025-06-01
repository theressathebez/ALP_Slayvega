//
//  PeerPressure.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import Foundation

class PeerPressure: Identifiable, Equatable {
    let id = UUID()
    let text: String
    var offset: CGSize
    var opacity: Double = 1.0
    var isDisappearing = false
    var shouldRemove = false

    init(text: String, offset: CGSize = .zero) {
        self.text = text
        self.offset = offset
    }

    static func == (lhs: PeerPressure, rhs: PeerPressure) -> Bool {
        lhs.id == rhs.id
    }

    func startDisappearing() {
        isDisappearing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.shouldRemove = true
        }
    }
}
