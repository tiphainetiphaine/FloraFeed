//
//  PlantDataTransformer.swift
//  FloraFeed
//
//  Created by Tiphaine Brydniak on 23/09/2023.
//

import Foundation

enum LIGHTING: String, CaseIterable, Identifiable {
    case BRIGHT_LIGHT = "Bright Light"
    case SHADE = "Shade"
    var id: Self { self }
    
    var level: Int {
        switch self {
        default:
            return 800
        }
    }
}

enum MOISTURE: String, CaseIterable, Identifiable {
    case DRY = "Dry"
    case BONE_DRY = "Bone Dry"
    var id: Self { self }
    
    var level: Int {
        switch self {
        case .DRY:
            return 35
        case .BONE_DRY:
            return 25
        }
    }
}

enum HUMIDTY: String, CaseIterable, Identifiable {
    case DRY = "Dry"
    case NORMAL = "Normal"
    case HUMID = "Humid"
    var id: Self { self }
    
    var level: Int {
        switch self {
        case .DRY:
            return 30
        case .NORMAL, .HUMID:
            return 50
        }
    }
}

enum TEMPERATURE: String, CaseIterable, Identifiable {
    case COLD = "Cold"
    case NORMAL = "Normal"
    case HOT = "Hot"
    var id: Self { self }
    
    var level: Int {
        switch self {
        case .COLD:
            return 15
        case .NORMAL, .HOT:
            return 25
        }
    }
}

struct PlantDataTransformer {
    func calculateAverageLightIntensityForThePeriod(timeLimitedData: [PlantData]) -> Int {
        var sum = 0;
        var count = 0;
        var average = 0;
        timeLimitedData.forEach { data in
            let time = data.timestamp.formatted(date: Date.FormatStyle.DateStyle.omitted, time: Date.FormatStyle.TimeStyle.shortened)
            if (time > "09:00:00" && time < "18:00:00") {
                sum += data.lightIntensity
                count += 1
            }
        }
        if (count > 0) {
            average = sum/count
            return average
        }
        return average
    }
    
    func isLightingIdeal(averageLightLevel: Int, idealLighting: LIGHTING) -> Bool {
        switch idealLighting {
        case .BRIGHT_LIGHT:
            return averageLightLevel > idealLighting.level
        case .SHADE:
            return averageLightLevel <= idealLighting.level
        }
    }
    
    func isMoistureLow(latestData: PlantData, idealMoistureLevel: MOISTURE) -> Bool {
        switch idealMoistureLevel {
        case .BONE_DRY:
            return latestData.moisture < idealMoistureLevel.level
        case .DRY:
            return latestData.moisture < idealMoistureLevel.level
        }
    }
    
    func isHumidityIdeal(latestData: PlantData, idealHumidity: HUMIDTY) -> Bool {
        switch idealHumidity {
        case .DRY:
            return latestData.humidity <= idealHumidity.level
        case .NORMAL:
            return latestData.humidity <= idealHumidity.level && latestData.humidity > HUMIDTY.DRY.level
        case .HUMID:
            return latestData.humidity > idealHumidity.level
        }
    }
    
    func isTemperatureIdeal(latestData: PlantData, idealTemperature: TEMPERATURE) -> Bool {
        switch idealTemperature {
        case .COLD:
            return latestData.temperature <= idealTemperature.level
        case .NORMAL:
            return latestData.temperature <= idealTemperature.level && latestData.temperature > TEMPERATURE.COLD.level
        case .HOT:
            return latestData.temperature > idealTemperature.level
        }
    }
}
