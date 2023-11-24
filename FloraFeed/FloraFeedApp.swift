//
//  FloraFeedApp.swift
//  FloraFeed
//
//  Created by Tiphaine Brydniak on 20/09/2023.
//

import SwiftUI
import UserNotifications
import BackgroundTasks
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

@main
struct FloraFeedApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    @Environment(\.scenePhase) private var phase
    @State private var averageLightIntensity = UserDefaults.standard.integer(forKey: "AverageLightIntensity")
    
    var body: some Scene {
        WindowGroup {
            if Auth.auth().currentUser != nil {
                PlantTableView()
            } else {
                LoginView()
            }
        }
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .background: scheduleAppRefresh()
            default: break
            }
        }
        .backgroundTask(.appRefresh("myAppRefresh")) {
            print("background task entered")
            
            if Auth.auth().currentUser != nil {
                print("confirmed user is logged in")
                let latestData = await getLatestData()
                
                if (latestData != nil) {
                    print("latest data is not nil")
                    
                    await getDataForEachPlant(data: latestData!)
                }
            }
            
            print("background work completed")
        }
    }
    
    func getDataForEachPlant(data: PlantData) async {
        let plants: [Plant] = PlantList.plants
        let batteryHealthy = data.battery > 72;
        
        for plant in plants {
            let allHealth = PlantDataTransformer().getAllPlantHealth(latestData: data, plant: plant, averageLightIntensity: averageLightIntensity)
            if !(allHealth.humidity && allHealth.lighting && allHealth.moisture && allHealth.temperature && batteryHealthy) {
                let notificationRequest = scheduleRequest(plant: plant, allHealth: (humidity: allHealth.humidity, temperature: allHealth.temperature, lighting: allHealth.lighting, moisture: allHealth.moisture, battery: batteryHealthy))
                do {
                    try await UNUserNotificationCenter.current().add(notificationRequest)
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "myAppRefresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 0)
        do {
              try BGTaskScheduler.shared.submit(request)
              print("bg task scheduled")
           } catch {
              print("Could not schedule app refresh: \(error)")
           }
    }
    
    func getLatestData() async -> PlantData? {
        return await PlantDataRepository().getLimitedDataFromFirebaseAsync(limitBy: 1)?[0]
    }
    
    func scheduleRequest(plant: Plant, allHealth: (humidity: Bool, temperature: Bool, lighting: Bool, moisture: Bool, battery: Bool)) -> UNNotificationRequest {
        print("schedule notification entered")
        
        let content = UNMutableNotificationContent()
        content.title = plant.name+" needs help!"
        content.body = getHelpString(name: plant.name, allHealth: allHealth)
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        return UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    }
    
    func getHelpString(name:String, allHealth: (humidity: Bool, temperature: Bool, lighting: Bool, moisture: Bool, battery: Bool)) -> String {
        var helpStringArray: [String] = []
        if (!allHealth.moisture) {
            helpStringArray.append(name+" needs watering!")
        }
        if (!allHealth.humidity) {
            helpStringArray.append("Check the humidity.")
        }
        if (!allHealth.temperature) {
            helpStringArray.append("Check the temperature.")
        }
        if (!allHealth.lighting) {
            helpStringArray.append("Check the lighting conditions.")
        }
        if (!allHealth.battery) {
            helpStringArray.append("The battery needs charging!")
        }
        let helpString = helpStringArray.joined(separator: "\n");
        return helpString
    }
}
