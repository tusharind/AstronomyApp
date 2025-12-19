import Foundation

struct APOD: Decodable {
    let title: String
    let explanation: String
    let date: String
    let url: String
    let mediaType: String
    let copyright: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case explanation
        case date
        case url
        case mediaType = "media_type"
        case copyright
    }
}

