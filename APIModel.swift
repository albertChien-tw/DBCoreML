//
//  APIModel.swift
//  MLModule
//
//  Created by dabechen on 2018/3/11.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import UIKit

class GetIterations: Codable {
    
    var id: String
    var name:String
    var status:String
    var created:String
    var lastModified:String
    var trainedAt:String?
    var isDefault:Bool
    
    enum CodingKeys : String, CodingKey {
        case id = "Id"
        case name = "Name"
        case status = "Status"
        case created = "Created"
        case lastModified = "LastModified"
        case trainedAt = "TrainedAt"
        case isDefault = "IsDefault"
    }
    
}

class Export: Codable {
    let platform:String?
    let status:String?
    let downloadUri:String?
    let code: String?
    let message:String?
    
    enum CodingKeys : String, CodingKey {
        case platform = "Platform"
        case status = "Status"
        case downloadUri = "DownloadUri"
        case code = "Code"
        case message = "Message"
       
    }
}

class Content:Codable {
    let id:String
    let name:String
    let description:String?
    let imageCount:Int
    
    enum CodingKeys : String, CodingKey {
        case id = "Id"
        case name = "Name"
        case description = "Description"
        case imageCount = "ImageCount"
       
        
    }
}

class GetTags:Codable{
    
    let tags:[Content]?
    let totalTaggedImages: Int?
    let totalUntaggedImages: Int?
    
    enum CodingKeys : String, CodingKey {
        case tags = "Tags"
        case totalTaggedImages = "TotalTaggedImages"
        case totalUntaggedImages = "TotalUntaggedImages"
        
        
    }
}

struct Tag:Codable {
    let tagId:String?
    let created:String?
    
    enum CodingKeys : String, CodingKey {
        case tagId = "TagId"
        case created = "Created"
    }
}

struct Prediction:Codable {
    let tagId: String?
    let tag: String?
    let probability:Double?
    enum CodingKeys : String, CodingKey {
        case tagId = "TagId"
        case tag = "Tag"
        case probability = "Probability"
    }
}

struct ImageContent:Codable {
    let id:String?
    let created:String?
    let width:Int?
    let hight:Int?
    let imageUri:String?
    let thumbnailUri:String?
    let tags:[Tag]?
    let predictions:[Prediction]?
    
    enum CodingKeys : String, CodingKey {
        
        case id = "Id"
        case created = "Created"
        case width = "Width"
        case hight = "Hight"
        case imageUri = "ImageUri"
        case thumbnailUri = "ThumbnailUri"
        case tags = "Tags"
        case predictions = "Predictions"
    }
}

class CreatImage:Codable{
    struct Image :Codable{
        
        let sourceUrl:String?
        let image:ImageContent?
        let status:String?
    }
    
    let isBatchSuccessful:Bool
    let images:[Image]
    
    enum CodingKeys : String, CodingKey {
        case isBatchSuccessful = "IsBatchSuccessful"
        case images = "Images"
    }
//    enum TagKeys : String, CodingKey {
//        case tagId = "TagId"
//        case created = "Created"
//    }
    
//    enum PredictionKeys : String, CodingKey {
//        case tagId = "TagId"
//        case tag = "Tag"
//        case probability = "Probability"
//    }
    
    
//    enum ImageContentKeys : String, CodingKey {
//      
//        case id = "Id"
//        case created = "Created"
//        case width = "Width"
//        case hight = "Hight"
//        case imageUri = "ImageUri"
//        case thumbnailUri = "ThumbnailUri"
//        case tags = "Tags"
//        case predictions = "Predictions"
//    }
//    
    
    enum ImageKeys : String, CodingKey {
        case sourceUrl = "SourceUrl"
        case image = "Image"
        case status = "Status"
    }
    
}

class ErrorCode:Codable{
    let statusCode:Int? = nil
    let message:String? = nil
    let Code:String? = nil
    let Message:String? = nil
    
}


struct CustomVisionPrediction:Codable {
    let tagId: String
    let tag: String
    let probability: Float
    
    enum ImageKeys : String, CodingKey {
        case tagId = "TagId"
        case tag = "Tag"
        case probability = "Probability"
    }
}

struct CustomVisionResult:Codable {
    let id: String
    let project: String
    let iteration: String
    let created: String
    let predictions: [CustomVisionPrediction]
    
    enum ImageKeys : String, CodingKey {
        case id = "Id"
        case project = "Project"
        case iteration = "Iteration"
        case created = "Created"
        case predictions = "Predictions"
        
    }
}

