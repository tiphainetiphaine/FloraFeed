//
//  HomeView.swift
//  FloraFeed
//
//  Created by Tiphaine Brydniak on 23/09/2023.
//

import SwiftUI
import FirebaseAuth
import UserNotifications

struct Plant: Identifiable {
    let id = UUID()
    let name: String
    let photo: String
    var lighting: LIGHTING
    var moisture: MOISTURE
    var humidity: HUMIDTY
    var temperature: TEMPERATURE
}

struct PlantView: View {
    let plant: Plant
    let latestData: PlantData
    let averageLightIntensity: Int
    
    var body: some View {
        HStack {
            Image(plant.photo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .cornerRadius(5)
                .padding(.leading, 8)
            Text(plant.name)
                .font(.headline)
                .lineLimit(1)
            HealthView(plant: plant, latestData: latestData, averageLightIntensity: averageLightIntensity)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct HealthView: View {
    let plant: Plant
    let latestData: PlantData;
    let averageLightIntensity: Int
    
    var body: some View {
        HStack {
            getIconHealthStatus(data: latestData).foregroundStyle(getColorForHealth(data: latestData, averageLightIntensity: averageLightIntensity))
            getIconForBatteryStatus(data: latestData).foregroundStyle(getColorForBattery(data: latestData))
        }
    }
    
    func getIconForBatteryStatus(data:PlantData) -> Image {
        if (data.charging) {
            return Image(systemName: "battery.100.bolt")
        }
        
        if (data.battery > 77) {
            return Image(systemName: "battery.75")
        } else if (data.battery > 72) {
            return Image(systemName: "battery.50")
        } else {
            return Image(systemName: "battery.25")
        }
    }
    
    func getColorForBattery(data:PlantData) -> Color {
        if (data.battery <= 72 ) {
            return .red
        } else {
            return .primary
        }
    }
    
    func getIconHealthStatus(data:PlantData) -> Image {
        return Image(systemName: "leaf.circle")
    }
    
    func getColorForHealth(data:PlantData, averageLightIntensity: Int) -> Color {
        print("averegaeLightIntensity is "+averageLightIntensity.description)
        
        let allHealthStats = PlantDataTransformer().getAllPlantHealth(latestData: latestData, plant: plant, averageLightIntensity: averageLightIntensity)

        if (allHealthStats.humidity && allHealthStats.lighting && allHealthStats.moisture && allHealthStats.temperature) {
            return .green
        } else {
            return .orange
        }
    }
}

struct PlantTableView: View {
    @State private var plants = PlantList.plants
    @State private var averageLightIntensity = UserDefaults.standard.integer(forKey: "AverageLightIntensity")
    @State private var latestData: PlantData = PlantData(id: "", lightIntensity: 800, moisture: 30, humidity: 36, temperature: 20, battery: 80, charging: false, timestamp: Date())
    let user = Auth.auth().currentUser
    @State var notificationsAreAllowed: Bool = false;
    @State var userIsSignedOut = false
    
    var body: some View {
        NavigationView {
            VStack{
                List {
                    ForEach(plants) { plant in
                        NavigationLink(destination: PlantDetailView(plant: plant, latestData: latestData)) {
                            PlantView(plant: plant, latestData: latestData, averageLightIntensity: averageLightIntensity)
                        }
                    }
                    .onDelete { indexSet in
                        plants.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        plants.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .navigationTitle("My Plants")
                .navigationBarItems(trailing: EditButton())
                
                Spacer()
                
                NavigationLink(destination: LoginView(), isActive: $userIsSignedOut) {
                    Button(action: {
                        handleSignOut()
                    }) {
                        Text("Sign Out").font(.title3)
                    }
                }.isDetailLink(false).padding(.top)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            PlantDataRepository().getLimitedDataFromFirebase(limitBy: 1) { dataArray in
                latestData = dataArray[0]
            }
        }
    }
    
    func handleSignOut() {
        do {
            try Auth.auth().signOut()
            userIsSignedOut = true
            print("successfully signed out")
        } catch let error {
            print ("Error signing out: %@", error)
        }
    }
}
