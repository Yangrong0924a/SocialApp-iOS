import Foundation

struct CheckinRecordResponse: Codable {
    let checkinDates: [String]
    let checkinStreak: Int
    let totalThisMonth: Int
    let year: Int
    let month: Int
    let totalAll: Int?

    enum CodingKeys: String, CodingKey {
        case checkinDates = "checkin_dates"
        case checkinStreak = "checkin_streak"
        case totalThisMonth = "total_this_month"
        case year, month
        case totalAll = "total_all"
    }
}

struct CheckinResponse: Codable {
    let ok: Bool
    let msg: String
    let checkinStreak: Int

    enum CodingKeys: String, CodingKey {
        case ok, msg
        case checkinStreak = "checkin_streak"
    }
}