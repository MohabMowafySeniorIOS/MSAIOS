//
//  NewsModel.swift
//  MSA
//
//  Created by Mohab Mowafy on 12/06/2026.
//

import Foundation
struct NewsModel : Codable {
    let data : [NewsData]?
    let links : Links?
    let meta : Meta?

    enum CodingKeys: String, CodingKey {

        case data = "data"
        case links = "links"
        case meta = "meta"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([NewsData].self, forKey: .data)
        links = try values.decodeIfPresent(Links.self, forKey: .links)
        meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
    }

}
struct NewsData : Codable {
    let id : Int?
    let title : Title?
    let description : Description?
    let media_url : String?
    let thumb_url : String?
    let media_type : String?
    let status : Status?
    let starts_at : String?
    let ends_at : String?
    let order : Int?
    let created_at : String?
    let updated_at : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case title = "title"
        case description = "description"
        case media_url = "media_url"
        case thumb_url = "thumb_url"
        case media_type = "media_type"
        case status = "status"
        case starts_at = "starts_at"
        case ends_at = "ends_at"
        case order = "order"
        case created_at = "created_at"
        case updated_at = "updated_at"
    }

    func map()-> NewsItem{
        if L102Language.currentAppleLanguage() == "ar" {
            return NewsItem(title: self.title?.ar ?? "", description: self.description?.ar, url: self.thumb_url ?? "", urlToImage: self.thumb_url ?? "", publishedAt: self.created_at ?? "", source: nil)
        }else {
            return NewsItem(title: self.title?.en ?? "", description: self.description?.en, url: self.thumb_url ?? "", urlToImage: self.thumb_url ?? "", publishedAt: self.created_at ?? "", source: nil)
        }
        
    }

}
struct Links : Codable {
    let url : String?
    let label : String?
    let page : Int?
    let active : Bool?

    enum CodingKeys: String, CodingKey {

        case url = "url"
        case label = "label"
        case page = "page"
        case active = "active"
    }

   

}
struct Meta : Codable {
    let current_page : Int?
    let from : Int?
    let last_page : Int?
    let links : [Links]?
    let path : String?
    let per_page : Int?
    let to : Int?
    let total : Int?

    enum CodingKeys: String, CodingKey {

        case current_page = "current_page"
        case from = "from"
        case last_page = "last_page"
        case links = "links"
        case path = "path"
        case per_page = "per_page"
        case to = "to"
        case total = "total"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        current_page = try values.decodeIfPresent(Int.self, forKey: .current_page)
        from = try values.decodeIfPresent(Int.self, forKey: .from)
        last_page = try values.decodeIfPresent(Int.self, forKey: .last_page)
        links = try values.decodeIfPresent([Links].self, forKey: .links)
        path = try values.decodeIfPresent(String.self, forKey: .path)
        per_page = try values.decodeIfPresent(Int.self, forKey: .per_page)
        to = try values.decodeIfPresent(Int.self, forKey: .to)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
    }

}
struct Label : Codable {
    let ar : String?
    let en : String?

    enum CodingKeys: String, CodingKey {

        case ar = "ar"
        case en = "en"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ar = try values.decodeIfPresent(String.self, forKey: .ar)
        en = try values.decodeIfPresent(String.self, forKey: .en)
    }

}
import Foundation
struct Description : Codable {
    let ar : String?
    let en : String?

    enum CodingKeys: String, CodingKey {

        case ar = "ar"
        case en = "en"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ar = try values.decodeIfPresent(String.self, forKey: .ar)
        en = try values.decodeIfPresent(String.self, forKey: .en)
    }

}
struct Status : Codable {
    let value : String?
    let label : Label?

    enum CodingKeys: String, CodingKey {

        case value = "value"
        case label = "label"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        value = try values.decodeIfPresent(String.self, forKey: .value)
        label = try values.decodeIfPresent(Label.self, forKey: .label)
    }

}
struct Title : Codable {
    let ar : String?
    let en : String?

    enum CodingKeys: String, CodingKey {

        case ar = "ar"
        case en = "en"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ar = try values.decodeIfPresent(String.self, forKey: .ar)
        en = try values.decodeIfPresent(String.self, forKey: .en)
    }

}
