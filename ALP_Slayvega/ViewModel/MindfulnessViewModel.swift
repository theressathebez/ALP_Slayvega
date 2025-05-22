//
//  MindfulnessViewModel.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import Foundation

class MindfulnessViewModel: ObservableObject {
    @Published var items: [MindfulnessModel] = [
        MindfulnessModel(
            iconName: "scope",
            title: "Calibrate",
            description: "Prepare yourself and get into position."
        ),
        MindfulnessModel(
            iconName: "wind",
            title: "Inhale",
            description: "Breathe in slowly and deeply."
        ),
        MindfulnessModel(
            iconName: "lungs.fill",
            title: "Exhale",
            description: "Breathe out gently and relax."
        ),
    ]

    func filteredItems(by searchText: String) -> [MindfulnessModel] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter {
                $0.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
}
