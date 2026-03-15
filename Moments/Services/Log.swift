import os

enum Log {
    static let general = Logger(subsystem: "com.kinginthecastle.Moments", category: "General")
    static let auth = Logger(subsystem: "com.kinginthecastle.Moments", category: "Auth")
    static let spotify = Logger(subsystem: "com.kinginthecastle.Moments", category: "Spotify")
    static let network = Logger(subsystem: "com.kinginthecastle.Moments", category: "Network")
    static let notifications = Logger(subsystem: "com.kinginthecastle.Moments", category: "Notifications")
}
