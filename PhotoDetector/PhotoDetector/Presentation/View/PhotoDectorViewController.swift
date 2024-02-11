//
//  ViewController.swift
//  PhotoDetector
//
//  Created by imseonghyeon on 2/1/24.
//

import UIKit
import AVFoundation

final class PhotoDetectorViewController: UIViewController {
    // MARK: - Namespace
    private enum Constants {
        static let defaultLayoutMargin: Double = 10.0
    }
    
    // MARK: - Dependency
    private var viewModel: PhotoDetectorViewModelProtocol = PhotoDetectorViewModel()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startDisplay()
    }
    
    func startDisplay() {
        do {
            try viewModel.handleDisplay()
        } catch {
            print(error)
        }
    }
    
    // MARK: - View Elements
    private let navigationLeftButton: UIBarButtonItem = {
        let uiBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: PhotoDetectorViewController.self, action: nil)
        uiBarButtonItem.tintColor = .white
        return uiBarButtonItem
    }()
    
    private let navigationRightButton: UIBarButtonItem = {
        let uiBarButtonItem = UIBarButtonItem(title: "자동/수동", style: .plain, target: PhotoDetectorViewController.self, action: nil)
        uiBarButtonItem.tintColor = .white
        
        return uiBarButtonItem
    }()
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        
        return layer
    }()
    
    private lazy var wrappedPreviewLayerView: UIView = {
        let view = UIView()
        view.layer.addSublayer(previewLayer)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let thumbnail: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(thumbnailHandler), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var shutterButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle.dashed.inset.filled"), for: .normal)
        button.addTarget(self, action: #selector(shutterButtonHandler), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.addsubViews(thumbnail, shutterButton)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
}

// MARK: - Action Handler
extension PhotoDetectorViewController {
    @objc
    private func thumbnailHandler() {
        let photoPreviewViewController = PhotoPreviewViewController()
        navigationController?.pushViewController(photoPreviewViewController, animated: true)
    }
    
    @objc
    private func shutterButtonHandler() {
        viewModel.didTapShutterButton()
    }
}

// MARK: - Configuration
extension PhotoDetectorViewController {
    private func configureView() {
        view.addsubViews(wrappedPreviewLayerView, bottomView)
        
        configureNavigationBar()
        configureConstraint()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .defaultNavigationBarColor
        navigationItem.setLeftBarButton(navigationLeftButton, animated: true)
        navigationItem.setRightBarButton(navigationRightButton, animated: true)
    }
    
    private func configureConstraint() {
        configureConstraintWrappedPreviewLayerView()
        configureConstraintBottomView()
        configureConstraintThumbnail()
        configureConstraintShutterButton()
    }
    
    private func configureConstraintWrappedPreviewLayerView() {
        NSLayoutConstraint.activate([
            wrappedPreviewLayerView.topAnchor.constraint(equalTo: view.topAnchor),
            wrappedPreviewLayerView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            wrappedPreviewLayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wrappedPreviewLayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wrappedPreviewLayerView.heightAnchor.constraint(equalTo: bottomView.heightAnchor, multiplier: 8.0)
        ])
    }
    
    private func configureConstraintBottomView() {
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureConstraintThumbnail() {
        NSLayoutConstraint.activate([
            thumbnail.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: Constants.defaultLayoutMargin),
            thumbnail.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -Constants.defaultLayoutMargin * 3),
            thumbnail.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: Constants.defaultLayoutMargin),
            thumbnail.widthAnchor.constraint(equalTo: thumbnail.heightAnchor),
        ])
    }
    
    private func configureConstraintShutterButton() {
        NSLayoutConstraint.activate([
            shutterButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: Constants.defaultLayoutMargin),
            shutterButton.bottomAnchor.constraint(equalTo: thumbnail.bottomAnchor),
            shutterButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor)
        ])
    }
    
    private func bind() {
        viewModel.photoListener = updateRectangleView
        viewModel.thumbnailListener = updateThumbnailView
    }
    
    private func updateRectangleView(photo: PhotoOutput) {
        previewLayer.session = photo.sesson
        
        Task { @MainActor in
            previewLayer.sublayers?.removeSubrange(1...)
            
            if let rectangle = photo.rectangle {
                previewLayer.addSublayer(rectangle.layer)
            }
        }
    }
    
    private func updateThumbnailView(thumbnail: UIImage) {
        self.thumbnail.setImage(thumbnail, for: .normal)
    }
}
