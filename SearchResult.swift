//
//  SearchResult.swift
//  StoreSearch
//
//  Created by NAHØM on 03/12/2022.
//


class ResultArray: Codable{
    var resultCount = 0
    var results: [SearchResult] = []
}

class SearchResult: Codable, CustomStringConvertible{
    var description: String{
        return "\nResult - Kind: \(kind ?? "None"), Name: \(name), Artist Name: \(artist)"
    }
    
    var artistName: String?
    var trackName: String?
    var trackViewUrl: String?
    var collectionName: String?
    var collectionViewUrl: String?
    var kind: String?
    
    var name: String{
        return trackName ?? collectionName ?? ""
    }
    var artist: String{
        return artistName ?? ""
    }
    var type: String{
        let kind = kind ?? "audiobook"
        
        switch kind{
            case "album": return "Album"
            case "audiobook": return "Audio Book"
            case "book": return "Book"
            case "ebook": return "E-Book"
            case "feature-movie": return "Movie"
            case "music-video": return "Music Video"
            case "podcast": return "Podcast"
            case "software": return "App"
            case "song": return "Song"
            case "tv-episode": return "TV Episode"
            default: return "Unknown"
        }
//        return "Unknown"
    }
    
    var trackPrice: Double? = 0.0
    var currency = ""
    var imageSmall = ""
    var imageLarge = ""
    var itemPrice: Double?
    var collectionPrice: Double?
    var itemGenre: String?
    var bookGenre: [String]?
    
    var storeURL: String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }
    var price: Double {
        return trackPrice ?? collectionPrice ?? 0
    }
    
    var genre: String {
        if let genre = itemGenre {
            return genre
        }
        else if let genre = bookGenre {
            return genre.joined(separator: ", ")
        }
        return ""
    }

    enum CodingKeys: String, CodingKey {
      case imageSmall = "artworkUrl60"
      case imageLarge = "artworkUrl100"
      case itemGenre = "primaryGenreName"
      case bookGenre = "genres"
      case itemPrice = "price"
      case kind, artistName, currency
      case trackName, trackPrice, trackViewUrl
      case collectionName, collectionViewUrl, collectionPrice
    }

    
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool{
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}

func > (lhs: SearchResult, rhs: SearchResult) -> Bool{
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedDescending
}


var searchResults: [SearchResult] = []



