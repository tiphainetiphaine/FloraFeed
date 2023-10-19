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
    var idealLighting: LIGHTING
    var moisture: MOISTURE
    var humidity: HUMIDTY
    var temperature: TEMPERATURE
}

struct PlantView: View {
    let plant: Plant
    let latestData: PlantData
    
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
            BatteryView(latestData: latestData)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct BatteryView: View {
    let latestData: PlantData;
    
    var body: some View {
        HStack {
            getBatteryIcon(data: latestData)
        }
    }
    
    func getBatteryIcon(data:PlantData) -> Image {
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
}

struct PlantTableView: View {
    @State private var plants = [
        Plant(name: "The Undying", photo: "IMG_5718", idealLighting: LIGHTING.SHADE, moisture: MOISTURE.DRY, humidity: HUMIDTY.NORMAL, temperature: TEMPERATURE.NORMAL),
        Plant(name: "Actually fake", photo: "IMG_5716", idealLighting: LIGHTING.SHADE, moisture: MOISTURE.BONE_DRY, humidity: HUMIDTY.DRY, temperature: TEMPERATURE.COLD),
        Plant(name: "On the edge", photo: "IMG_5721", idealLighting: LIGHTING.BRIGHT_LIGHT, moisture: MOISTURE.BONE_DRY, humidity: HUMIDTY.DRY, temperature: TEMPERATURE.HOT),
        Plant(name: "Just Thrivin'", photo: "IMG_5720", idealLighting: LIGHTING.SHADE, moisture: MOISTURE.DRY, humidity: HUMIDTY.NORMAL, temperature: TEMPERATURE.NORMAL)
    ]
    @State private var latestData: PlantData = PlantData(id: "", lightIntensity: 800, moisture: 30, humidity: 36, temperature: 20, battery: 80, charging: false, timestamp: Date())
    let user = Auth.auth().currentUser
    @State var notificationsAreAllowed: Bool = false;
    @State var isSignedOut = false
    
    var body: some View {
        NavigationView {
            VStack{
                List {
                    ForEach(plants) { plant in
                        NavigationLink(destination: PlantDetailView(plant: plant, latestData: latestData)) {
                            PlantView(plant: plant, latestData: latestData)
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
                
                NavigationLink(destination: LoginView(), isActive: $isSignedOut) {
                    Button(action: {
                        handleSignOut()
                    }) {
                        Text("Sign Out").font(.title3)
                    }
                }.padding(.top)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            PlantDataRepository().getLimitedDataFromFirebase(limitBy: 1) { dataArray in
                latestData = dataArray[0]
                
                handleNotifications()
            }
        }
    }
    
    func handleSignOut() {
        print("entered handleSignOut")
        do {
            try Auth.auth().signOut()
            isSignedOut = true
            print("successfully signed out")
        } catch let error {
            print ("Error signing out: %@", error)
        }
    }
    
    func handleNotifications() {
        notificationsAreAllowed = UserRepository().geUsertNotificationSettings()
        if (notificationsAreAllowed) {
            print("so far so good!")
        } else {
            print("didn't remember settings")
        }
    }
}
