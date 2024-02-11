//
//  PhotoInputUseCase.swift
//  PhotoDetector
//
//  Created by imseonghyeon on 2/2/24.
//

import UIKit
import AVFoundation

final class PhotoInputUseCase: NSObject, PhotoInputUseCaseProtocol {
    // MARK: - Namespace
    private enum Constants {
        static let defaultXAxisCorrection: Double = 20
        static let defaultYAxisCorrection: Double = 25
    }
    
    // MARK: - Dependencies
    private let context: CIContext
    private let detectorManager: DetectorManagerable = DetectorManager()
    
    // MARK: - Delegate
    var delegate: PhotoDetectorViewModelProtocol?
    
    // MARK: - Life Cycle
    init(context: CIContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    func startObservingDisplay() throws {
        Task {
            guard await detectorManager.isAuthorized else { return }
        }
        
        try detectorManager.setUpCamera(delegate: self)
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            detectorManager.session.startRunning()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension PhotoInputUseCase {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        do {
            let detectorBuilder = DetectorBuilder()
            let detector = try detectorBuilder.build(with: context)
            let transformedciImage = detectorManager.transform(ciImage)
            let rectangle = try detectorManager.detect(of: transformedciImage, with: detector)
            
            Task { @MainActor in
                let windows = UIApplication.shared.windows
                guard let photoDetectorViewController =  windows.first?.rootViewController else { return }
                
                // MARK: - 이미지의 크기와 뷰의 크기를 사용하여 비율 계산
                let scaleX = photoDetectorViewController.view.bounds.width / ciImage.extent.width
                let scaleY = photoDetectorViewController.view.bounds.height / ciImage.extent.height
                
                // MARK: - 사각형의 좌표를 뷰의 좌표계로 변환
                let topLeft = CGPoint(x: rectangle.topLeft.x * scaleX-Constants.defaultXAxisCorrection, y: rectangle.topLeft.y * scaleY)
                let topRight = CGPoint(x: rectangle.topRight.x * scaleX+Constants.defaultYAxisCorrection, y: rectangle.topRight.y * scaleY)
                let bottomLeft = CGPoint(x: rectangle.bottomLeft.x * scaleX-Constants.defaultXAxisCorrection, y: rectangle.bottomLeft.y * scaleY)
                let bottomRight = CGPoint(x: rectangle.bottomRight.x * scaleX+Constants.defaultXAxisCorrection, y: rectangle.bottomRight.y * scaleY)
                
                // MARK: - 대각, 기울임 등의 상황에서도 사각형을 그려줌
                let path = UIBezierPath()
                path.move(to: topLeft)
                path.addLine(to: topRight)
                path.addLine(to: bottomRight)
                path.addLine(to: bottomLeft)
                path.close()
                
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = path.cgPath
                shapeLayer.fillColor = UIColor.mainColorAlpha50.cgColor
                shapeLayer.strokeColor = UIColor.subColor.cgColor
                shapeLayer.lineWidth = 3
                
                let rectangle = Rectangle(topLeft: rectangle.topLeft,
                                          topRight: rectangle.topRight,
                                          bottomLeft: rectangle.bottomLeft,
                                          bottomRight: rectangle.bottomRight,
                                          layer: shapeLayer)
                
                let photoOutput = PhotoOutput(image: ciImage, rectangle: rectangle, sesson: detectorManager.session)
                
                delegate?.latestPhotoOutput = photoOutput
            }
        } catch {
            let photoOutput = PhotoOutput(image: ciImage, rectangle: nil, sesson: detectorManager.session)
            
            delegate?.latestPhotoOutput = photoOutput
        }
    }
}