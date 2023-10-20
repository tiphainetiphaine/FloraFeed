//
//  UserRepository.swift
//  FloraFeed
//
//  Created by Tiphaine Brydniak on 19/10/2023.
//

import SwiftUI
import UserNotifications

//if we actually had users we'd have a user model
//we'd have a uid that would be assigned to the plants etc
//so wouldn't be able to read other people's data
//since it's just me going to use this for the methods re-using for user auth

struct UserRepository {
    func geUsertNotificationSettings() -> Bool {
        var notificationsAreAllowed: Bool = false;
//        UNUserNotificationCenter.current().getNotificationSettings( completionHandler: { settings in
//            if (settings.alertSetting == .enabled || settings.badgeSetting == .enabled) {
//                notificationsAreAllowed = true
//            }
//            if (settings.authorizationStatus == .authorized) {
//                notificationsAreAllowed = true
//            }
//        })
        let isNotificationEnabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
        if (isNotificationEnabled == true) {
            notificationsAreAllowed = true
        }
        return notificationsAreAllowed
    }
}
