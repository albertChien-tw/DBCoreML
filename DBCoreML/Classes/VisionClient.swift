//
//  VisionClient.swift
//  MLModule
//
//  Created by dabechen on 2018/3/11.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import UIKit

struct VisionConfigure {
    var projectId:String
    var trainingKey:String
}

open class VisionClient :APIClient{
    open static let `share` = VisionClient()

    static let baseUrl = "https://southcentralus.api.cognitive.microsoft.com"

    var configure:VisionConfigure = VisionConfigure.init(projectId: "51219413-433b-497c-b19c-6462545ca9cc", trainingKey: "53b9b55c56a14528937ea3848eab1e8c")

    func queryIteration(endpoint: VisionEndpoint, completion: @escaping (Result<[GetIterations]>) -> Void) {
        let request = endpoint.request
       
        get(request: request, completion: completion)
    }
    
    func creatTag(endpoint:VisionEndpoint,completion:@escaping (Result<Content>)->()){
        let request = endpoint.request
       URLSession.shared
        post(request: request, completion: completion)
    }
    
    func downloadModel(url:String,completion:@escaping (Result<URL>)->()){
       
        download(url:URL.init(string: url)!, completion: completion)
       
    }
    
    func createImagesFromData(endpoint:VisionEndpoint,completion:@escaping (Result<CreatImage>)->()){
       
        post(request: endpoint.request, completion: completion)
    }
    
    func getTags(endpoint:VisionEndpoint,completion:@escaping (Result<GetTags>)->()){
        
        get(request: endpoint.request, completion: completion)
    }
    
    func export(endpoint:VisionEndpoint,completion:@escaping (Result<[Export]>)->()){
        get(request:endpoint.request,completion:completion)
       
    }
    func checkExport(endpoint:VisionEndpoint,completion:@escaping (Result<Export>)->()){
      
      post(request: endpoint.request, completion: completion)
    }
    
    func deleteImages(endpoint:VisionEndpoint){
        delete(request: endpoint.request)
    }
    
    func getTaggedImages(endpoint:VisionEndpoint,completion:@escaping (Result<[ImageContent]>)->()){
        
        get(request: endpoint.request, completion: completion)
    }
}

