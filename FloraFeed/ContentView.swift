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
                Text(getLightingString()).padding()
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
                Text(isMoistureIdeal == true ? Constants.ContentView.NO_WATERING :  Constants.ContentView.WATERING).padding()
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
                Text(getHumidityString()).padding()
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
                Text(getTemperatureString()).padding()
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
    
    func getHumidityString() -> String {
        if (isHumidityIdeal) {
            return  Constants.ContentView.IDEAL_HUMIDITY
        } else {
            switch plant.humidity {
            case .DRY:
                return Constants.ContentView.TOO_HUMID
            case .NORMAL:
                if latestData.humidity > plant.humidity.level {
                    return Constants.ContentView.TOO_HUMID
                } else {
                    return Constants.ContentView.TOO_DRY
                }
            case .HUMID:
                return Constants.ContentView.TOO_DRY
            }
        }
    }
    
    func getLightingString() -> String {
        if (isLightingIdeal) {
            return Constants.ContentView.IDEAL_LIGHTING;
        } else if (!isLightingIdeal && averageLightIntensity < plant.lighting.level) {
            return Constants.ContentView.TOO_DARK
        } else {
            return Constants.ContentView.TOO_BRIGHT
        }
    }
    
    func getTemperatureString() -> String {
        if (isTemperatureIdeal) {
            return  Constants.ContentView.IDEAL_TEMPERATURE
        } else {
            switch plant.temperature {
            case .COLD:
                return Constants.ContentView.TOO_HOT
            case .NORMAL:
                if latestData.temperature > plant.temperature.level {
                    return Constants.ContentView.TOO_HOT
                } else {
                    return Constants.ContentView.TOO_COLD
                }
            case .HOT:
                return Constants.ContentView.TOO_COLD
            }
        }
    }
}
