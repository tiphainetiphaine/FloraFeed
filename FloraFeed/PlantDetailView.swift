//
//  PlantDetailView.swift
//  FloraFeed
//
//  Created by Tiphaine Brydniak on 23/09/2023.
//

import SwiftUI

struct PlantDetailView: View {
    @State var plant: Plant;
    @State var latestData: PlantData;
    @State private var selectedLighting: LIGHTING = LIGHTING.SHADE;
    @State private var selectedMoisture: MOISTURE = MOISTURE.DRY;
    @State private var selectedHumidity: HUMIDTY = HUMIDTY.NORMAL;
    @State private var selectedTemperature: TEMPERATURE = TEMPERATURE.NORMAL;
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                ZStack {
                    VStack {
                        Image(plant.photo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: proxy.size.width)
                            .cornerRadius(10)
                            .padding()
                        Text("Ideal settings for this plant:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Form {
                            Section {
                                Picker("Ideal Lighting", selection: $selectedLighting.onChange(lightingChange)) {
                                    ForEach(LIGHTING.allCases) { option in
                                        Text(String(describing: option.rawValue))
                                    }
                                }
                                Picker("Ideal Moisture", selection: $selectedMoisture.onChange(moistureChange)) {
                                    ForEach(MOISTURE.allCases) { option in
                                        Text(String(describing: option.rawValue))
                                    }
                                }
                                Picker("Ideal Humidity", selection: $selectedHumidity.onChange(humidityChange)) {
                                    ForEach(HUMIDTY.allCases) { option in
                                        Text(String(describing: option.rawValue))
                                    }
                                }
                                Picker("Ideal Temperature", selection: $selectedTemperature.onChange(temperatureChange)) {
                                    ForEach(TEMPERATURE.allCases) { option in
                                        Text(String(describing: option.rawValue))
                                    }
                                }
                            }
                        }.frame(height: 250).scrollDisabled(true)
                        
                        
                        NavigationLink {
                            ContentView(plant: plant, latestData: latestData)
                        } label: {
                            Text("Check Vitals").bold().font(.title3)
                        }
                        .padding(20)
                    }
                }
                .navigationTitle(plant.name)
                .edgesIgnoringSafeArea(.bottom)
            }
        }.onAppear(perform: {
            selectedLighting = plant.idealLighting;
            selectedMoisture = plant.moisture;
            selectedHumidity = plant.humidity;
            selectedTemperature = plant.temperature;
        })
    }
    
    func lightingChange(lighting: LIGHTING) {
        plant.idealLighting = lighting;
    }
    
    func moistureChange(moisture: MOISTURE) {
        plant.moisture = moisture;
    }
    
    func humidityChange(humidity: HUMIDTY) {
        plant.humidity = humidity;
    }
    
    func temperatureChange(temperature: TEMPERATURE) {
        plant.temperature = temperature;
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
            })
    }
}
