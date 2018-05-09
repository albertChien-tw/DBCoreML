//
//  VisionClient.swift
//  MLModule
//
//  Created by dabechen on 2018/3/11.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import UIKit

public class VisionConfigure {
    var projectId:String
    var trainingKey:String
    public init(projectId:String,trainingKey:String) {
        self.projectId = projectId
        self.trainingKey = trainingKey
    }
}

public class VisionClient :APIClient{
   public static let `share` = VisionClient()

   public static let baseUrl = "https://southcentralus.api.cognitive.microsoft.com"

   public var configure:VisionConfigure = VisionConfigure.init(projectId: "", trainingKey: "")

    func queryIteration(endpoint: VisionEndpoint, completion: @escaping (Result<[GetIterations]>) -> Void) {
        let request = endpoint.request
       
        get(request: request, completion: completion)
    }
    
    func creatTag(endpoint:VisionEndpoint,completion:@escaping (Result<Content>)->()){
        let request = endpoint.request

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
    
    func trainProject(endpoint:VisionEndpoint,completion:@escaping (Result<GetIterations>)->()){
        
        post(request: endpoint.request, completion: completion)
    }
}

