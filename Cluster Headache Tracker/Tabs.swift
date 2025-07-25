import Foundation
import UIKit
import HotwireNative

extension HotwireTab {
    static let all: [HotwireTab] = [
        .logs,
        .charts,
        .new,
        .account,
        .feedback
    ]
    
    static let logs = HotwireTab(
        title: "Logs",
        image: UIImage(systemName: "calendar")!,
        url: AppConfig.current.appendingPathComponent("headache_logs")
    )
    
    static let charts = HotwireTab(
        title: "Charts",
        image: UIImage(systemName: "chart.bar")!,
        url: AppConfig.current.appendingPathComponent("charts")
    )
    
    static let new = HotwireTab(
        title: "New",
        image: UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))!,
        url: AppConfig.current.appendingPathComponent("headache_logs")
    )
    
    static let account = HotwireTab(
        title: "Account",
        image: UIImage(systemName: "person")!,
        url: AppConfig.current.appendingPathComponent("settings")
    )
    
    static let feedback = HotwireTab(
        title: "Feedback",
        image: UIImage(systemName: "bubble.left")!,
        url: AppConfig.current.appendingPathComponent("feedback")
    )
}