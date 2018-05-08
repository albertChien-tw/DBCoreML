//
//  VisionClientModel.swift
//  MLModule
//
//  Created by dabechen on 2018/3/11.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import Foundation
import Vision
import CoreML

protocol MLClientDelegate :class{
    
    func mlClient(_ mlClient:MLClient,didUpdateModel model:VNCoreMLModel,error:Error?)
    func mlClient(_ mlClient:MLClient,didUpdateiteration iteration :[GetIterations],error:Error?)
    func mlClient(_ mlClient:MLClient,didUpdateTags tags :GetTags,error:Error?)
 
    func mlClient(_ mlClient:MLClient,visionDidChangeState state :VisionStatus)
}


enum VisionStatus :String{
    case queryIteration
    case updateModel
    case exportModel
    case initVision
}

enum UserDefaultKey:String{
    case iterationId
    case directory
    case modelName
    case compiledUrl
}

enum IsTaged {
    case tagged,untagged
}

class MLClient{
    
    //MARK : - Property
    private let client:APIClient
    weak var  delegate : MLClientDelegate?
    var storeDirectory = FileManager.SearchPathDirectory.documentDirectory
    
    init(client:APIClient,delegate:MLClientDelegate) {
        self.client = client
        self.delegate = delegate
    }
    
    func queryIteration(completion:@escaping (String?)->()){

        if let client = client as? VisionClient{
            let endpoint = VisionEndpoint.queryIteration
            
            client.queryIteration(endpoint: endpoint, completion: { (result) in
                switch result{
                case .success(let value):
                    let completed = value.filter{($0.status == "Completed")}
                    let lastTime = completed.sorted(by: { (date1, date2) -> Bool in
                        return date1.trainedAt!.compare(date2.trainedAt!) == ComparisonResult.orderedDescending
                    })

                    self.delegate?.mlClient(self, didUpdateiteration: value, error: nil)
                    completion(lastTime.first!.id)
                case .failure(let error):
                    self.delegate?.mlClient(self, didUpdateiteration: [], error: error)
                    print(error.localizedDescription)
                    completion(nil)
                }
            })
        }
    }
    
    func setUpModel(directory:FileManager.SearchPathDirectory,modelName:String,localModel:MLModel){
        delegate?.mlClient(self, visionDidChangeState: .initVision)
        storeDirectory = directory
        
        UserDefaults.standard.set(modelName, forKey: UserDefaultKey.modelName.rawValue)
        
        queryIteration { (iteration) in
            guard let iteration = iteration else {
                
                self.updateModel(iterationId: nil, callBack: { (url,error) in

                    self.delegate?.mlClient(self, didUpdateModel: self.compileModel(url: url, compileUrl: nil, localModel: localModel), error: MLError.updateModelError)
                    
                })
                return
            }
            
            if iteration == UserDefaults.standard.string(forKey: UserDefaultKey.iterationId.rawValue){
                
                let compileUrl = UserDefaults.standard.string(forKey: UserDefaultKey.compiledUrl.rawValue)
                
                self.delegate?.mlClient(self, didUpdateModel: self.compileModel(url: nil, compileUrl: compileUrl, localModel: localModel), error: nil)
            }else{
                UserDefaults.standard.set(iteration, forKey: UserDefaultKey.iterationId.rawValue)
                
                self.updateModel(iterationId: iteration, callBack: { (url,error) in
                   
                    self.delegate?.mlClient(self, didUpdateModel: self.compileModel(url: url, compileUrl: nil, localModel: localModel), error: nil)
    
                })
            }
        }
        
    }
    
    func creatTag(tagName:String,completion:@escaping (Content?,Error?)->()){
        
        if let client = client as? VisionClient {
            let endpoint = VisionEndpoint.creatTag(tagName: tagName)
            client.creatTag(endpoint: endpoint, completion: { (result) in
                switch result{
                    
                case .success(let value):
                    completion(value,nil)
                case .failure(let error):
                    completion(nil,error)
                }
            })
        }

    }
    
    func getTags(completion:@escaping (GetTags?)->()){
        if let client = client as? VisionClient {
            let endpoint = VisionEndpoint.getTags
            client.getTags(endpoint: endpoint) { (result) in
                switch result{
                case .success(let value):
                    completion(value)
                case .failure(let error):
                    completion(nil)
                }
            }
            
        }
    }
    
    func queryImage(istaged:IsTaged,completion:@escaping ([Photo],Error?)->()){
        var photos :[Photo] = []
        getImages(istaged: istaged) { (result,content, error) in
            guard error == nil,let content = content,let result = result else {return}
            
            content.forEach({ (imageContent) in
                imageContent.tags?.forEach({ (tag) in
                    guard let tagId = tag.tagId,let url = imageContent.imageUri else {return}
                    
                    var tempPhoto:Photo? = nil
                    
                    if let photo = photos.filter({($0.title == tagId)}).first{
             
                        let index = photos.index(where: {($0.title == tagId)})
                        photos.remove(at: index!)
                        tempPhoto = photo
                        tempPhoto?.photoContent.append(PhotoContent(id:imageContent.id! , photoURL: url, isSelected: false))
                        //tempPhoto?.photoURL.append(url)
                        photos.append(tempPhoto!)
                    }else{
                        let photo = Photo.init(title: tagId, photoContent: [PhotoContent(id: imageContent.id!, photoURL: url, isSelected: false)])
                        photos.append(photo)
                    }
                    
                })
            })
            
            photos.forEach({ (photo) in
                var tempPhoto = photo
                let index = photos.index(where: {($0.title == tempPhoto.title)})
                photos.remove(at: index!)
                tempPhoto.title.idToTitle(result: result)
                photos.append(tempPhoto)
            })
            completion(photos,error)
        }
    }
    func deleteImages(images:[PhotoContent]){
        if let client = self.client as? VisionClient {
            
            let endpoint = VisionEndpoint.deleteImages(imageIds: images)
            client.deleteImages(endpoint: endpoint)
        }
    }
    private func getImages(istaged:IsTaged,completion:@escaping (GetTags?,[ImageContent]?,Error?)->()){
        
        var take:Int = 50
        
        getTags { (tags) in
            
            guard let tags = tags else{return}
            self.delegate?.mlClient(self, didUpdateTags: tags, error: nil)
            
            switch istaged{
                case .tagged:
                    take = tags.totalTaggedImages!
                case .untagged:
                    take = tags.totalUntaggedImages!
            }
           
            if let client = self.client as? VisionClient {
                
                let endpoint = VisionEndpoint.getTaggedImage(take: take)
                client.getTaggedImages(endpoint: endpoint) { (result) in
                    switch result{
                    case .success(let value):
                        completion(tags,value,nil)
                    case .failure(let error):
                        completion(nil,nil,error)
                    }
                }
            }
            
        }
    }
    
    func updateModel(iterationId:String?,callBack:@escaping (URL?,Error?)->()){
        delegate?.mlClient(self, visionDidChangeState: .updateModel)
        
        let paths = FileManager.default.urls(for: self.storeDirectory, in: .userDomainMask)
        let modeName = UserDefaults.standard.string(forKey: UserDefaultKey.modelName.rawValue)
        let modelURL = paths.first!.appendingPathComponent(modeName!)
        
        guard let iterationId = iterationId else{
            callBack(modelURL,nil)
            return
        }
        
        exportModel(iterationId: iterationId) { (url,error) in
            if let url = url{
                if let client = self.client as? VisionClient{
                    client.downloadModel(url: url, completion: { (result) in
                        switch result{
                        case .success(let downloadUrl):
                            callBack(downloadUrl,nil)
                        case .failure(let error):
                            callBack(nil,error)
                        }
                    })
                }
                
            }else{
                callBack(modelURL,error)
            }
            
        }
    }
    
    private func exportModel(iterationId:String,callBack:@escaping (String?,Error?)->()){
        delegate?.mlClient(self, visionDidChangeState: .exportModel)
        
        self.checkCanExport(iterationId: iterationId, completion: {(error) in
            
            guard error == nil else{callBack(nil,error);return}
            
            if let client = self.client as? VisionClient{
                let endpoint = VisionEndpoint.export(iterationId: iterationId)
                client.export(endpoint: endpoint, completion: { (result) in
                    switch result{
                    case .success(let value):
                        guard let downloadUrl = value.first?.downloadUri else{
                            
                            callBack(nil,error)
                            return
                        }
                        callBack(downloadUrl,nil)
                    case .failure(let error):
                        callBack(nil,error)
                    }
                })
               
            }
        })
    }
    
    private func checkCanExport(iterationId:String,completion:((Error?)->())?){
      
        if let client = client as? VisionClient{
            let endpoint = VisionEndpoint.checkCanExport(iterationId: iterationId)
            client.checkExport(endpoint: endpoint, completion: { (result) in
                switch result{
                case .success(let value):
                    completion?(nil)
                case .failure(let error):
                    completion?(error)
                     print(error.localizedDescription)
                }
            })
        }
       
    }
    
    private func compileModel(url:URL?,compileUrl:String?,localModel:MLModel)->VNCoreMLModel{
        
        let localModel = try! VNCoreMLModel.init(for: localModel)
        
        let newModel:VNCoreMLModel!
        let fileManager = FileManager.default
        
        guard url == nil else {
            do{
                //removeold
                if let compileUrl = UserDefaults.standard.string(forKey: UserDefaultKey.compiledUrl.rawValue) {
                    do {
                        
                        if fileManager.fileExists(atPath: compileUrl) {
                            _ = try fileManager.removeItem(atPath: compileUrl)
                        }
                    } catch {
                        print("Error during copy: \(error.localizedDescription)")
                    }
                }
                
                let compiledUrl = try MLModel.compileModel(at: url!)
                UserDefaults.standard.set(compiledUrl, forKey: UserDefaultKey.compiledUrl.rawValue)
                
                let  model = try MLModel.init(contentsOf: compiledUrl)
                
                newModel = try VNCoreMLModel.init(for: model)
            }catch{
                print(error.localizedDescription)
                return localModel
            }
            
            return newModel
        }
        
        do{
            let oldCompiledUrl = UserDefaults.standard.string(forKey: UserDefaultKey.compiledUrl.rawValue)
            guard let url = oldCompiledUrl,let modelUrl = URL.init(string: url)  else {return localModel}
            let  model = try MLModel.init(contentsOf: modelUrl)
            
            newModel = try VNCoreMLModel.init(for: model)
            
        }catch{
            print(error.localizedDescription)
            return localModel
        }
        
        return newModel
    }
}

extension String{
    
    mutating func idToTitle(result:GetTags){
        self = (result.tags?.filter({($0.id == self)}).first?.name)!
    }
    func titleToId(){
        return 
    }
}
