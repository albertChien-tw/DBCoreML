//
//  CameraVC.swift
//  MLModule
//
//  Created by dabechen on 2018/4/29.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class CameraVC: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var identityLabel: UILabel!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var model:VNCoreMLModel!{
        didSet{
            setUpOutput()
        }
    }
    
    lazy var captureSession:AVCaptureSession = {
        let session  = AVCaptureSession()
        session.sessionPreset = .high
        guard let back = AVCaptureDevice.default(for: .video),let input = try? AVCaptureDeviceInput.init(device: back) else{return session}
        session.addInput(input)
        return session
    }()
    
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    
    var requests = [VNRequest]()
    var classificationRequest: VNCoreMLRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func setUpOutput(){
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.init(label: "output", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
        captureSession.addOutput(deviceOutput)
        captureSession.startRunning()
        videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: self.captureSession)
        videoPreviewLayer.frame = view.frame
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
        setupModel()
    }
    
    func setupModel(){

        classificationRequest = VNCoreMLRequest.init(model: model, completionHandler: handleClassification)
        self.classificationRequest.imageCropAndScaleOption = .centerCrop
        self.requests = [self.classificationRequest]
    }
    
    func handleClassification(request:VNRequest,error:Error?){
        
        guard error == nil else {
            print("Error:\(error?.localizedDescription)")
            return
        }
        
        guard let results = request.results  else {
            return
        }
        
        
        let observations = results.prefix(4).flatMap{($0 as? VNClassificationObservation)}.map{("\($0.identifier)- \(String(format:" %.2f", $0.confidence))" )}.joined(separator: "\n")
        
        DispatchQueue.main.async {
            
            self.identityLabel.text = ""
            self.identityLabel.text = observations
        }
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let handeler =  VNImageRequestHandler.init(cvPixelBuffer: pixelBuffer, options: [:])
        do{
            try handeler.perform(self.requests)
        }catch{
            print(error.localizedDescription)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
