//
//  ViewController.swift
//  MLModule
//
//  Created by dabechen on 2018/3/11.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import UIKit
import Vision
import CoreML
import DBCoreML

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    
    //MARK:- Properties
    lazy var mlClient :MLClient = {
        var client = VisionClient.share
        
        client.configure = VisionConfigure.init(projectId: "075ca9c2-0a8d-4b82-8051-0a395eaa9837", trainingKey: "53b9b55c56a14528937ea3848eab1e8c")
        let model = MLClient(client: client, delegate: self)
        
        return model
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    struct Storyboard {
        static let sectionHeaderView = "SectionViewHeaderCell"
        static let photoCell = "Cell"
        static let cameraSegue = "gotoCamera"
    }
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    var photos:[Photo]? = []{
        didSet{
            self.collectionView.reloadData()
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mlClient.queryImage(istaged: .tagged) { (photos, error) in
            guard error == nil else{return}
            self.photos = photos
        }
    
    }
    
    
    @IBAction func btnAction(_ sender: Any) {
        
        let cameraAction = UIAlertAction.init(title: "相機辨識", style: .default) { (_) in
            
            self.mlClient.setUpModel(directory: self.mlClient.storeDirectory, modelName: "Landmark", localModel: Landmark().model)
        }

        let uploadAction = UIAlertAction.init(title: "上傳照片", style: .default) { (_) in
            
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        
        showaAlert(nil, nil, style: .actionSheet, actions: [cameraAction,uploadAction,cancelAction])
        
       
    }
    
    func showaAlert(_ title:String?,_ message:String? ,style:UIAlertControllerStyle,actions:[UIAlertAction]){
       
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: style)
        actions.forEach { (action) in
            alertVC.addAction(action)
        }
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func editAction(_ sender: Any) {
        var changePhotos:[Photo] = []
        
        photos?.forEach({ (photo) in
            var photos:[PhotoContent] = []
           
            guard  photo.photoContent.filter({($0.isSelected)}).count > 0 else {return}
            
             photo.photoContent.filter({($0.isSelected)}).forEach({ (content) in
                 photos.append(content)
            })
           
            var tempPhoto = photo
            tempPhoto.photoContent = photos
            changePhotos.append(tempPhoto)
        })
        
        guard changePhotos.count > 0 else {
            let cancelAction = UIAlertAction.init(title: "確定", style: .default, handler: nil)
            self.showaAlert("尚未選取照片", nil, style: .alert, actions: [cancelAction])
            return
        }
        
        let deleteAction = UIAlertAction.init(title: "Delete", style: .destructive) { (_) in
        
            changePhotos.forEach { (photo) in
               self.mlClient.deleteImages(images: photo.photoContent)
            }
            
            self.mlClient.queryImage(istaged: .tagged, completion: { (photos, error) in
                guard error == nil else{return}
                self.photos = photos
            })
        }
        
        
        showaAlert("確定刪除", nil, style: .alert, actions: [deleteAction])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard  let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
            return
        }
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.photoCell, for: indexPath) as? CollectionViewCell else {return}
        
//        if cell.isSelected{
            photos?[indexPath.section].photoContent[indexPath.row].isSelected = !(photos?[indexPath.section].photoContent[indexPath.row].isSelected)!
//        }
  
       collectionView.reloadItems(at: [indexPath])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.photoCell, for: indexPath) as? CollectionViewCell,let index = photos?[indexPath.section].photoContent[indexPath.row] else {
            return UICollectionViewCell()
        }
        
        cell.layer.borderColor = index.isSelected ? #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.layer.borderWidth = index.isSelected ? 5 : 0
      
        cell.image.loadImageUsingUrlString(index.photoURL)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?[section].photoContent.count ?? 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: self.view.frame.width
            , height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: (self.view.frame.width - 2)/3, height: (self.view.frame.width - 2)/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Storyboard.sectionHeaderView, for: indexPath) as? SectionheaderView else{
            return UICollectionReusableView()
        }
        sectionHeaderView.titleLabel.text = photos?[indexPath.section].title ?? "Hello"
        
        return sectionHeaderView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photos?.count ?? 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let cameraVC = segue.destination as? CameraVC,let model = sender as? VNCoreMLModel else {
            return
        }
        cameraVC.model = model
    }
}

extension ViewController:MLClientDelegate{
    
    func mlClient(_ mlClient: MLClient, didUpdateTags tags: GetTags, error: Error?) {
       
    }
    
    func mlClient(_ mlClient: MLClient, didUpdateModel model: VNCoreMLModel, error: Error?) {
        
        performSegue(withIdentifier: Storyboard.cameraSegue, sender: model)
        guard let error = error as? MLError else {
            return
        }
        print(error)
    }
    
    func mlClient(_ mlClient: MLClient, didUpdateiteration iteration: [GetIterations], error: Error?) {
        guard let error  = error as? MLError else {
            return
        }
        print(error)
    }
    
    func mlClient(_ mlClient: MLClient, visionDidChangeState state: VisionStatus) {
        print(state.rawValue)
    }
    
}

let imageCache = NSCache<NSString, UIImage>()

class CustomImageView: UIImageView {
    
    var imageUrlString: String?
    
    func loadImageUsingUrlString(_ urlString: String) {
        
        imageUrlString = urlString
        
        let url = URL(string: urlString)
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, respones, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                let imageToCache = UIImage(data: data!)
                
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }
                
                imageCache.setObject(imageToCache!, forKey: urlString as NSString)
            })
            
        }).resume()
    }
    
}

