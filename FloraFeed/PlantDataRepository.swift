//
//  PlantDataTest.swift
//  FloraFeed
//
//  Created by Tiphaine Brydniak on 20/09/2023.
//

import FirebaseFirestore

let db = Firestore.firestore()

struct PlantData: Identifiable {
    var id: String
    let lightIntensity: Int
    let moisture: Int
    let humidity: Int
    let temperature: Int
    let battery: Int
    let charging: Bool
    let timestamp: Date
}

extension PlantData {
    init(id: String, firebasePlantData: [String : Any]) {
        self.init(
            id: id,
            
            lightIntensity: firebasePlantData["lightIntensity"] as? Int ?? 0,
            moisture: firebasePlantData["moisture"] as? Int ?? 0,
            humidity: firebasePlantData["humidity"] as? Int ?? 0,
            temperature: firebasePlantData["temperature"] as? Int ?? 0,
            battery: firebasePlantData["battery"] as? Int ?? 0,
            charging: firebasePlantData["charging"] as? Bool ?? false,
            timestamp: (firebasePlantData["timestamp"] as! Timestamp).dateValue()
        )
    }
}

struct PlantDataRepository {
    func getAllDataFromFirebase(completionHandler: @escaping ([PlantData]) -> Void) {
        
        db.collection("plantData")
            .order(by: "timestamp", descending: true)
            .getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                print("Successfully retrieved all plant data")
                var PlantDataArray: [PlantData] = []
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let id = document.documentID;
                    let plant = PlantData(id: id, firebasePlantData: data)
                    PlantDataArray.append(plant)
                }
                completionHandler(PlantDataArray)
            }
        }
    }
    
    func getLimitedDataFromFirebase(limitBy: Int, completionHandler: @escaping ([PlantData]) -> Void) {
        
        db.collection("plantData")
            .order(by: "timestamp", descending: true).limit(to: limitBy)
            .getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                print("Successfully retrieved all plant data")
                var PlantDataArray: [PlantData] = []
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let id = document.documentID;
                    let plant = PlantData(id: id, firebasePlantData: data)
                    PlantDataArray.append(plant)
                }
                completionHandler(PlantDataArray)
            }
        }
    }
    
    func getLimitedDataFromFirebaseAsync(limitBy: Int) async -> [PlantData]? {
        do {
            let querySnapshot = try await db.collection("plantData")
                .order(by: "timestamp", descending: true).limit(to: limitBy)
                .getDocuments()
                    print("Successfully retrieved all plant data")
                    var PlantDataArray: [PlantData] = []
                    for document in querySnapshot.documents {
                        print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        let id = document.documentID;
                        let plant = PlantData(id: id, firebasePlantData: data)
                        PlantDataArray.append(plant)
                    }
            return PlantDataArray
        } catch let error {
            print ("Error getting data from Firebase: %@", error)
            return nil
        }
    }
    
    func getLatestData(allPlantdata: [PlantData]) -> PlantData {
        return allPlantdata[0];
    }
    
    func getOrderedDataLimitedBy(limit: Int, allPlantdata: [PlantData]) -> [PlantData] {
        let newArray: [PlantData] = Array(allPlantdata.prefix(limit))
        return newArray.reversed();
    }
}
