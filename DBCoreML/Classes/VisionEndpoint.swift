//
//  VisionEndpoint.swift
//  MLModule
//
//  Created by dabechen on 2018/3/11.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import UIKit

protocol Endpoint {
    var baseURL:String { get }
    var path: String { get }
    var urlParemeters: [URLQueryItem]? { get }
    var bodyData:Data? { get }
   
}

extension Endpoint {
    
    var urlComponent: URLComponents {
        var urlComponent = URLComponents(string: baseURL)
        urlComponent?.path = path
        urlComponent?.queryItems = urlParemeters
      
        return urlComponent!
    }
    
    
    var request :URLRequest {
        var request = URLRequest.init(url: urlComponent.url!)
        request.addValue(VisionClient.share.configure.trainingKey, forHTTPHeaderField: "Training-key")
        return request
    }
    
    func createBody(parameters: [String: String],
                                 boundary: String,
                                 data: Data,
                                 mimeType: String,
                                 filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
    
    
}

 enum VisionEndpoint:Endpoint {

    case queryIteration
    case creatTag(tagName:String)
    case getTags
    case createImages(images:[UIImage],tagIds:[String],boundary:String)
    case export(iterationId:String)
    case checkCanExport(iterationId:String)
    case getTaggedImage(take:Int)
    case getUnTaggedImage(take:Int)
    case deleteImages(imageIds:[PhotoContent])
    case trainProject
    
    public var baseURL:String{
        return VisionClient.baseUrl
    }
    
     var path: String{
        switch self {
        case .queryIteration:
            return "/customvision/v1.2/Training/projects/\(VisionClient.share.configure.projectId)/iterations"
        case .creatTag:
            return "/customvision/v1.2/Training/projects/\(VisionClient.share.configure.projectId)/tags"
        case .getTags:
            return "/customvision/v1.2/Training/projects/\(VisionClient.share.configure.projectId)/tags"
        case .createImages:
            return "/customvision/v1.2/Training/projects/\(VisionClient.share.configure.projectId)/images"
        case .export(let iterationId):
            return "/customvision/v1.2/Training/projects/\(VisionClient.share.configure.projectId)/iterations/\(iterationId)/export"
        case .checkCanExport(let iterationId):
            return "/customvision/v1.2/Training/projects/\(VisionClient.share.configure.projectId)/iterations/\(iterationId)/export"
        case .getTaggedImage(_):
            return "/customvision/v1.2/Training/projects/\(VisionClient.share.configure.projectId)/images/tagged"
        case .getUnTaggedImage(_):
            return "/customvision/v1.2/Training/projects/\(VisionClient.share.configure.projectId)/images/entagged"
        case .deleteImages(_):
            return "/customvision/v1.2/Training/projects/\(VisionClient.share.configure.projectId)/images"
        case .trainProject:
            return "/customvision/v1.2/Training/projects/\(VisionClient.share.configure.projectId)/train"
            
        }
    }

     var urlParemeters: [URLQueryItem]?{
        switch self {
        case .queryIteration:
            return nil
        case .getTags:
            return nil
        case .creatTag(let tagName):
            return [URLQueryItem.init(name: "name", value: tagName)]
        case .createImages(_,let tagIds,_):
            var queryItems: [URLQueryItem] = []
            tagIds.forEach { (tag) in
                queryItems.append(URLQueryItem.init(name: "tagIds", value: tag))
            }
            return queryItems
        case .export:
            return nil
        case .checkCanExport:
            return [URLQueryItem.init(name: "platform", value: "CoreML")]
        case .getTaggedImage(let take):
            return [URLQueryItem.init(name: "take", value: "\(take)")]
        case .getUnTaggedImage(let take):
            return [URLQueryItem.init(name: "take", value: "\(take)")]
        case .deleteImages(let images):
            var item:[URLQueryItem] = []
            images.forEach { (image) in
                item.append(URLQueryItem.init(name: "imageIds", value: image.id))
            }
            return item
        case .trainProject:
            return []
        }
        

    }
     var bodyData: Data?{
        switch self {
        case .queryIteration:
            return nil
        case .getTags:
            return nil
        case .creatTag:
            return nil
        case .createImages(let images,_,let boundary):
            //let boundary = "Boundary-\(UUID().uuidString)"
            var parameter = ["Content-Type":"multipart/form-data; boundary=\(boundary)"]
                parameter.updateValue("\(VisionClient.share.configure.trainingKey)", forKey: "Training-key")
            var bodyData = Data()

            for (index,item) in images.enumerated(){
               
                bodyData.append(createBody(parameters: parameter,
                                                boundary: boundary,
                                                data: UIImageJPEGRepresentation(item, 0.7)!,
                                                mimeType: "image/jpg",
                                                filename: "hello\(index).jpg"))
            }
            
            return bodyData
        case .export:
            return nil
        case .checkCanExport:
            return nil
        case .getTaggedImage(_):
            return nil
        case .getUnTaggedImage(_):
            return nil
        case .deleteImages(_):
            return nil
        case .trainProject:
            return nil
        }
        
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

