//
//  AppDelegate.swift
//  FaithConnect
//
//  Created by hansol on 2026/02/27.
//

import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    var deepLinkManager: DeepLinkManager?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Firebase 초기화
        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        requestNotificationPermission(application)

        // 앱 실행 시 뱃지 초기화
        application.applicationIconBadgeNumber = 0
        UserDefaults.standard.set(0, forKey: "badgeCount")

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // APNs 토큰을 Firebase에 전달 → Firebase가 FCM 토큰 발급
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("APNs 등록 실패: \(error.localizedDescription)")
    }

    // 백그라운드 푸시 수신 시 뱃지 누적
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        incrementBadgeCount()
        completionHandler(.newData)
    }

    private func requestNotificationPermission(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if let error = error {
                print("알림 권한 요청 에러: \(error.localizedDescription)")
                return
            }

            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
                print("알림 권한 허용")
            } else {
                print("알림 권한 거부")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // 포그라운드 알림 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // 알림 탭 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("알림 탭: \(userInfo)")

        Task { @MainActor in
            deepLinkManager?.handleNotification(userInfo: userInfo)
        }

        completionHandler()
    }

    // 클라이언트 뱃지 카운트 누적
    private func incrementBadgeCount() {
        var count = UserDefaults.standard.integer(forKey: "badgeCount")
        count += 1
        UserDefaults.standard.set(count, forKey: "badgeCount")
        UIApplication.shared.applicationIconBadgeNumber = count
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    // FCM 토큰 수신 및 갱신
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("FCM 토큰: \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
    }
}
