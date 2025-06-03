//
//  PositiveElement.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import Foundation

struct PositiveElement: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let offset: CGSize
    var opacity: Double = 0.0
    var scale: CGFloat = 1.0
    
    static func == (lhs: PositiveElement, rhs: PositiveElement) -> Bool {
        lhs.id == rhs.id
    }
}
