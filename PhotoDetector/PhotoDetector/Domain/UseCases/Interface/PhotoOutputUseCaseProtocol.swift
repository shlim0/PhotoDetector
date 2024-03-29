//
//  DetectorOutputProtocol.swift
//  PhotoDetector
//
//  Created by imseonghyeon on 2/1/24.
//

import UIKit
import AVFoundation

protocol PhotoOutputUseCaseProtocol: AnyObject {
    var delegate: PhotoDetectorViewModelProtocol? { get set }
    
    func capture(_ photo: PhotoOutput) -> UIImage
}
