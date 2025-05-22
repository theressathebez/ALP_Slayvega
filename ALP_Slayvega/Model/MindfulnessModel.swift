//
//  MindfulnessModel.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import Foundation

struct MindfulnessModel: Identifiable {
    var id = UUID().uuidString
    var iconName: String
    var title: String = ""
    var description: String = ""
}
