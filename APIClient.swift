
//
//  APIClient.swift
//  MLModule
//
//  Created by dabechen on 2018/3/11.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import Foundation

enum Result<T>{
    case success(T)
    case failure(Error)
}
enum MLError:Error{
    case unknown, badResponse, jsonDecoder ,updateModelError
}
protocol APIClient {
    var session :URLSession { get }
    func get<T:Codable>(request:URLRequest,completion:@escaping (Result<T>)->())
    func post<T:Codable>(request:URLRequest,completion:@escaping (Result<T>)->())
    func download(url:URL,completion:@escaping (Result<URL>)->())
}

extension APIClient{
    
    var session:URLSession{
        return URLSession.shared
    }
    
    func get<T:Codable>(request:URLRequest,completion:@escaping (Result<T>)->()){

        let task = session.dataTask(with: request) { (data, response, error) in
            guard  error == nil else{
                completion(.failure(error!))
                return
            }

            guard let response = response as? HTTPURLResponse,200..<300 ~= response.statusCode else{
                completion(.failure(MLError.badResponse))
                return
            }
        
            guard let value = try? JSONDecoder().decode(T.self, from: data!) else{
                completion(.failure(MLError.jsonDecoder))
                return
            }
           print(String.init(data: data!, encoding: String.Encoding.utf8)!)
            DispatchQueue.main.async {
                completion(.success(value))
            }
        }
        task.resume()
    }
    
    func delete(request:URLRequest){
        
        var request = request
        request.httpMethod = "DELETE"
        
        let task = session.dataTask(with: request) { (data, response, error) in
    
        }
        task.resume()
    }
    
    func post<T:Codable>(request:URLRequest,completion:@escaping (Result<T>)->()){
        var request = request
        request.httpMethod = "POST"

        let task = session.dataTask(with: request) { (data, response, error) in
            guard  error == nil else{
                completion(.failure(error!))
                return
            }
//            guard let response = response as? HTTPURLResponse,200..<300 ~= response.statusCode else{
//                completion(.failure(APIError.badResponse))
//                return
//            }
            guard let value = try? JSONDecoder().decode(T.self, from: data!) else{
                completion(.failure(MLError.jsonDecoder))
                return
            }
            print(String.init(data: data!, encoding: String.Encoding.utf8)!)
            DispatchQueue.main.async {
                completion(.success(value))
            }
        }
        task.resume()
    }
    
    func download(url:URL,completion:@escaping (Result<URL>)->()){
        
        let request = URLRequest(url: url)
        let task = session.downloadTask(with: request) { (url, response, error) in
            guard  error == nil,let url = url else{
                completion(.failure(error!))
                return
            }
            guard let response = response as? HTTPURLResponse,200..<300 ~= response.statusCode else{
               completion(.failure(MLError.badResponse))
                return
            }
            let fileManager = FileManager.default
            
            let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let modelName = UserDefaults.standard.string(forKey: UserDefaultKey.modelName.rawValue)!
            let documents = paths.first!.appendingPathComponent(modelName)
            do {
                
                if fileManager.fileExists(atPath: documents.path) {
                    _ = try fileManager.replaceItemAt(documents, withItemAt: paths.first!)
                    
                } else {
                    print(url,url.path)
                    try fileManager.moveItem(atPath: url.path, toPath: documents.path)
                }
            } catch {
                print("Error during copy: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                completion(.success(documents))
            }
        }
        task.resume()
    }
}
