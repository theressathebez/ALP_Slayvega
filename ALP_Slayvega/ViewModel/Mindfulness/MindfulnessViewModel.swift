//
//  MindfulnessViewModel.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import FirebaseAuth
import FirebaseDatabase
import Foundation

class MindfulnessViewModel: ObservableObject {
    private let dbRef = Database.database().reference()

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var items: [MindfulnessModel] = [
        MindfulnessModel(
            iconName: "scope",
            title: "How Stressed Are You?",
            description: "Prepare yourself and get into position."
        ),
        MindfulnessModel(
            iconName: "wind",
            title: "Breathe Out",
            description: "Breathe in slowly and deeply."
        ),
        MindfulnessModel(
            iconName: "lungs.fill",
            title: "Social Chameleon",
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

    func saveStressResult(stressLevel: Int, userId: String) {
        isLoading = true
        errorMessage = nil

        let stressId = UUID().uuidString
        let timestamp = Int(Date().timeIntervalSince1970)

        let stressData: [String: Any] = [
            "StressId": stressId,
            "StressLevel": stressLevel,
            "userId": userId,
            "timestamp": timestamp,
        ]

        dbRef.child("stress_results").child(stressId).setValue(stressData) {
            [weak self] error, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage =
                        "Failed to save stress result: \(error.localizedDescription)"
                    print("Error saving stress result: \(error)")
                } else {
                    print("Stress result saved successfully")
                }
            }
        }
    }

    func getUserStressHistory(
        userId: String,
        completion: @escaping ([StressModel]) -> Void
    ) {
        dbRef.child("stress_results").observeSingleEvent(of: .value) {
            snapshot in
            var stressResults: [StressModel] = []

            // Loop melalui seluruh data anak
            for case let child as DataSnapshot in snapshot.children {
                if let data = child.value as? [String: Any],
                    let uid = data["userId"] as? String,
                    uid == userId
                {

                    var stress = StressModel()
                    stress.StressId = data["StressId"] as? String ?? ""
                    stress.StressLevel = data["StressLevel"] as? Int ?? 0
                    stress.userId = uid
                    stress.timestamp = data["timestamp"] as? Int
                    stressResults.append(stress)
                }
            }

            stressResults.sort { ($0.timestamp ?? 0) > ($1.timestamp ?? 0) }

            DispatchQueue.main.async {
                completion(stressResults)
            }
        } withCancel: { error in
            print(
                "Error fetching stress history: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion([])
            }
        }
    }

}
