//
//  APIModel.swift
//  MLModule
//
//  Created by dabechen on 2018/3/11.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import UIKit

public class GetIterations: Codable {
    
    public var id: String
    public var name:String
    public var status:String
    public var created:String
    public var lastModified:String
    public var trainedAt:String?
    public var isDefault:Bool
    
    public enum CodingKeys : String, CodingKey {
        case id = "Id"
        case name = "Name"
        case status = "Status"
        case created = "Created"
        case lastModified = "LastModified"
        case trainedAt = "TrainedAt"
        case isDefault = "IsDefault"
    }
    
}

public class Export: Codable {
    public let platform:String?
    public let status:String?
    public let downloadUri:String?
    public let code: String?
    public let message:String?
    
    public enum CodingKeys : String, CodingKey {
        case platform = "Platform"
        case status = "Status"
        case downloadUri = "DownloadUri"
        case code = "Code"
        case message = "Message"
        
    }
}

public class Content:Codable {
    public  let id:String
    public  let name:String
    public  let description:String?
    public  let imageCount:Int
    
    public  enum CodingKeys : String, CodingKey {
        case id = "Id"
        case name = "Name"
        case description = "Description"
        case imageCount = "ImageCount"
        
        
    }
}

public class GetTags:Codable{
    
    public let tags:[Content]?
    public let totalTaggedImages: Int?
    public let totalUntaggedImages: Int?
    
    public enum CodingKeys : String, CodingKey {
        case tags = "Tags"
        case totalTaggedImages = "TotalTaggedImages"
        case totalUntaggedImages = "TotalUntaggedImages"
        
        
    }
}

public struct Tag:Codable {
    public let tagId:String?
    public let created:String?
    
    public enum CodingKeys : String, CodingKey {
        case tagId = "TagId"
        case created = "Created"
    }
}

public struct Prediction:Codable {
    public  let tagId: String?
    public  let tag: String?
    public  let probability:Double?
    public  enum CodingKeys : String, CodingKey {
        case tagId = "TagId"
        case tag = "Tag"
        case probability = "Probability"
    }
}

public struct ImageContent:Codable {
    public let id:String?
    public let created:String?
    public let width:Int?
    public let hight:Int?
    public let imageUri:String?
    public let thumbnailUri:String?
    public let tags:[Tag]?
    public  let predictions:[Prediction]?
    
    public enum CodingKeys : String, CodingKey {
        
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

public class CreatImage:Codable{
    
    public struct Image :Codable{
        public let sourceUrl:String?
       // public let image:ImageContent?
        public let status:String?
    }
    
    public let isBatchSuccessful:Bool?
    public let images:[Image]?
    
    public enum CodingKeys : String, CodingKey {
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
    
    public enum ImageKeys : String, CodingKey {
        case sourceUrl = "SourceUrl"
        case image = "Image"
        case status = "Status"
    }
    
}

public class ErrorCode:Codable{
    public  let statusCode:Int? = nil
    public let message:String? = nil
    public let Code:String? = nil
    public let Message:String? = nil
    
}


public struct CustomVisionPrediction:Codable {
    public let tagId: String
    public let tag: String
    public let probability: Float
    
    public enum ImageKeys : String, CodingKey {
        case tagId = "TagId"
        case tag = "Tag"
        case probability = "Probability"
    }
}

public struct CustomVisionResult:Codable {
    public let id: String
    public let project: String
    public let iteration: String
    public let created: String
    public let predictions: [CustomVisionPrediction]
    
    public enum ImageKeys : String, CodingKey {
        case id = "Id"
        case project = "Project"
        case iteration = "Iteration"
        case created = "Created"
        case predictions = "Predictions"
        
    }
}

