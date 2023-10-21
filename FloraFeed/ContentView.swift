//
//  ContentView.swift
//  FloraFeed
//
//  Created by Tiphaine Brydniak on 20/09/2023.
//

import SwiftUI
import Charts

enum DATA_RANGE: String, CaseIterable, Identifiable {
    case HOURS = "Last 6 hours"
    case DAY = "Last 24 hours"
    case WEEK = "Last week"
    case ALL_TIME = "All time"
    var id: Self { self }
}

struct ContentView: View {
    let plant: Plant
    @State var latestData: PlantData;
    @State private var arrayOfAllData: [PlantData] = [];
    @State private var orderedDataLimited: [PlantData] = [];
    @State private var averageLightIntensity: Int = 0;
    @State private var isLightingIdeal: Bool = false;
    @State private var isMoistureIdeal: Bool = false;
    @State private var isHumidityIdeal: Bool = false;
    @State private var isTemperatureIdeal: Bool = false;
    @State private var selectedData: DATA_RANGE = DATA_RANGE.HOURS;
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Section {
                    Picker("See data for:", selection: $selectedData.onChange(dataRangeChange)) {
                        ForEach(DATA_RANGE.allCases) { option in
                            Text(String(describing: option.rawValue))
                        }
                    }
                }
                VStack {
                    Text("Light intensity (%)").bold()
                    Chart {
                        ForEach(orderedDataLimited) { data in
                            LineMark(
                                x: .value("Date / Time", data.timestamp),
                                y: .value("Light Intensity", PlantDataTransformer().getAdjustedLightIntensity(data: data))
                            )
                        }
                    }
                    .chartYScale(domain: [0, 100])
                }
                .padding()
                Text(getLightingString(plant: plant)).padding()
                VStack {
                    Text("Moisture (%)").bold()
                    Chart {
                        ForEach(orderedDataLimited) { data in
                            LineMark(
                                x: .value("Date / Time", data.timestamp),
                                y: .value("Moisture", PlantDataTransformer().getAdjustedMoisture(data: data))
                            )
                        }
                    }
                    .chartYScale(domain: [0, 100])
                }
                .padding()
                Text(getWateringString(plant:plant)).padding()
                VStack {
                    Text("Humidity (%)").bold()
                    Chart {
                        ForEach(orderedDataLimited) { data in
                            LineMark(
                                x: .value("Date / Time", data.timestamp),
                                y: .value("Humidity", data.humidity)
                            )
                        }
                    }
                    .chartYScale(domain: [0, 100])
                }
                .padding()
                Text(getHumidityString(plant: plant)).padding()
                VStack {
                    Text("Temperature (Degrees C)").bold()
                    Chart {
                        ForEach(orderedDataLimited) { data in
                            LineMark(
                                x: .value("Date / Time", data.timestamp),
                                y: .value("Temperature", data.temperature)
                            )
                        }
                    }
                }
                .padding()
                Text(getTemperatureString(plant: plant)).padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            PlantDataRepository().getAllDataFromFirebase(
                completionHandler: { array in
                    arrayOfAllData = array
                    
                    latestData = arrayOfAllData[0];
                    
                    orderedDataLimited = PlantDataRepository().getOrderedDataLimitedBy(limit: 6, allPlantdata: array);
                    
                    averageLightIntensity = PlantDataTransformer().calculateAverageLightIntensityForThePeriod(timeLimitedData: arrayOfAllData)
                    
                    UserDefaults.standard.set(averageLightIntensity, forKey: "AverageLightIntensity")
                    
                    self.isLightingIdeal = PlantDataTransformer().isLightingIdeal(averageLightLevel: averageLightIntensity, idealLighting: plant.lighting)
                    
                    self.isMoistureIdeal = PlantDataTransformer().isMoistureIdeal(latestData: latestData, idealMoistureLevel: plant.moisture)
                    
                    self.isHumidityIdeal = PlantDataTransformer().isHumidityIdeal(latestData: latestData, idealHumidity: plant.humidity)
                    
                    self.isTemperatureIdeal = PlantDataTransformer().isTemperatureIdeal(latestData: latestData, idealTemperature: plant.temperature)
                });
        })
    }
    
    func dataRangeChange(dataRange: DATA_RANGE) {
        switch dataRange {
        case .DAY:
            return orderedDataLimited = PlantDataRepository().getOrderedDataLimitedBy(limit: 24, allPlantdata: arrayOfAllData);
        case .WEEK:
            return orderedDataLimited = PlantDataRepository().getOrderedDataLimitedBy(limit: 168, allPlantdata: arrayOfAllData);
        case .ALL_TIME:
            return orderedDataLimited = arrayOfAllData.reversed();
        default:
            return orderedDataLimited = PlantDataRepository().getOrderedDataLimitedBy(limit: 6, allPlantdata: arrayOfAllData);
        }
    }
    
    func getWateringString(plant: Plant) -> String {
        return plant.name+(isMoistureIdeal == true ? Constants.ContentView.NO_WATERING :  Constants.ContentView.WATERING)
    }
    
    func getHumidityString(plant: Plant) -> String {
        if (isHumidityIdeal) {
            return Constants.ContentView.IDEAL_HUMIDITY+plant.name+"."
        } else {
            switch plant.humidity {
            case .DRY:
                return Constants.ContentView.TOO_HUMID+plant.name+"."
            case .NORMAL:
                if latestData.humidity > plant.humidity.level {
                    return Constants.ContentView.TOO_HUMID+plant.name+"."
                } else {
                    return Constants.ContentView.TOO_DRY+plant.name+"."
                }
            case .HUMID:
                return Constants.ContentView.TOO_DRY+plant.name+"."
            }
        }
    }
    
    func getLightingString(plant: Plant) -> String {
        if (isLightingIdeal) {
            return Constants.ContentView.IDEAL_LIGHTING+plant.name+".";
        } else if (!isLightingIdeal && averageLightIntensity < plant.lighting.level) {
            return Constants.ContentView.TOO_DARK+plant.name+"."
        } else {
            return Constants.ContentView.TOO_BRIGHT+plant.name+"."
        }
    }
    
    func getTemperatureString(plant: Plant) -> String {
        if (isTemperatureIdeal) {
            return  Constants.ContentView.IDEAL_TEMPERATURE+plant.name+"."
        } else {
            switch plant.temperature {
            case .COLD:
                return Constants.ContentView.TOO_HOT+plant.name+"."
            case .NORMAL:
                if latestData.temperature > plant.temperature.level {
                    return Constants.ContentView.TOO_HOT+plant.name+"."
                } else {
                    return Constants.ContentView.TOO_COLD+plant.name+"."
                }
            case .HOT:
                return Constants.ContentView.TOO_COLD+plant.name+"."
            }
        }
    }
}
