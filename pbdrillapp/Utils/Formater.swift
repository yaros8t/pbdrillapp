import Foundation


final class Formater {
    
    static func secondsToHoursMinutesSeconds(interval: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(interval))!
    }
}
