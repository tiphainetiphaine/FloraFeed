//
//  HomeView.swift
//  FloraFeed
//
//  Created by Tiphaine Brydniak on 23/09/2023.
//

import SwiftUI

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
                Spacer()
            }
            .padding(.vertical, 8)
    }
}

struct PlantTableView: View {
    @State private var plants = [
        Plant(name: "The Undying", photo: "IMG_5718", idealLighting: LIGHTING.SHADE, moisture: MOISTURE.DRY, humidity: HUMIDTY.NORMAL, temperature: TEMPERATURE.NORMAL),
        Plant(name: "Actually fake", photo: "IMG_5716", idealLighting: LIGHTING.SHADE, moisture: MOISTURE.BONE_DRY, humidity: HUMIDTY.DRY, temperature: TEMPERATURE.COLD),
        Plant(name: "On the edge", photo: "IMG_5721", idealLighting: LIGHTING.BRIGHT_LIGHT, moisture: MOISTURE.BONE_DRY, humidity: HUMIDTY.DRY, temperature: TEMPERATURE.HOT),
        Plant(name: "Just Thrivin'", photo: "IMG_5720", idealLighting: LIGHTING.SHADE, moisture: MOISTURE.DRY, humidity: HUMIDTY.NORMAL, temperature: TEMPERATURE.NORMAL)
    ]
    
    var body: some View {
        NavigationView {
            VStack{
                List {
                    ForEach(plants) { plant in
                        NavigationLink(destination: PlantDetailView(plant: plant)) {
                            PlantView(plant: plant)
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
                
                //todo actually handle logout
                NavigationLink {
                    LoginView()
                } label: {
                    Text("Log out").bold().font(.title3)
                }
            }
        }.navigationBarBackButtonHidden()
    }
}
