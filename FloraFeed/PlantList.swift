//
//  PlantList.swift
//  FloraFeed
//
//  Created by Tiphaine Brydniak on 20/10/2023.
//

import Foundation

struct PlantList {
    static let plants = [
        Plant(name: "The Undying", photo: "IMG_5718", lighting: LIGHTING.SHADE, moisture: MOISTURE.DRY, humidity: HUMIDTY.NORMAL, temperature: TEMPERATURE.NORMAL),
        Plant(name: "Actually fake", photo: "IMG_5716", lighting: LIGHTING.SHADE, moisture: MOISTURE.BONE_DRY, humidity: HUMIDTY.DRY, temperature: TEMPERATURE.COLD),
        Plant(name: "On the edge", photo: "IMG_5721", lighting: LIGHTING.BRIGHT_LIGHT, moisture: MOISTURE.BONE_DRY, humidity: HUMIDTY.DRY, temperature: TEMPERATURE.HOT),
        Plant(name: "Just Thrivin'", photo: "IMG_5720", lighting: LIGHTING.SHADE, moisture: MOISTURE.DRY, humidity: HUMIDTY.NORMAL, temperature: TEMPERATURE.NORMAL)
    ]
}
