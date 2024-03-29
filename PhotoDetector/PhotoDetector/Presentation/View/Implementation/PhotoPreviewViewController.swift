//
//  PhotoPreviewViewController.swift
//  PhotoDetector
//
//  Created by imseonghyeon on 2/2/24.
//

import UIKit

final class PhotoPreviewViewController: UIViewController {
    // MARK: - Namespace
    private enum Constants {
        static let defaultLayoutXMargin: Double = 30.0
        static let defaultLayoutYMargin: Double = 10.0
    }
    
    // MARK: - Dependencies
    private var viewModel: PhotoPreviewViewModelProtocol = PhotoPreviewViewModel()
    
    // MARK: - Delegate
    weak var delegate: PhotoDetectorViewControllerDelegate?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGesture()
        configureView()
    }
    
    private func bind() {
        viewModel.photoListener = updatePreview
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.resetNavigationBarColor(self)
    }
    
    // MARK: - View Elements
    private let statusBar: UIView = {
        let view = UIView()
        view.backgroundColor = .mainColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let preview: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let trashButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.addTarget(self, action: #selector(trashButtonHandler(index: )), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let counterclockwiseButton: UIButton = {
        let button = UIButton()
        button.setTitle("반시계", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(counterclockwiseButtonHandler), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let resizeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "crop"), for: .normal)
        button.addTarget(self, action: #selector(resizeButtonHandler), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.addsubViews(trashButton, counterclockwiseButton, resizeButton)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
}

// MARK: - Action Handler
extension PhotoPreviewViewController {
    @objc
    func swipeLeftHandler(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
        }
    }

    @objc
    func swipeRightHandler(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
        }
    }
    
    @objc
    func trashButtonHandler(index: String) {
        do {
            try viewModel.didTapTrashButton(index: index)
        } catch {
            print(error)
        }
    }
    
    @objc
    func counterclockwiseButtonHandler(index: String) {
        do {
            try viewModel.didTapCounterclockwiseButton(index: index)
        } catch {
            print(error)
        }
    }
    
    @objc
    func resizeButtonHandler() {
        let photoRepointingViewController = PhotoRepointingViewController()
        navigationController?.pushViewController(photoRepointingViewController, animated: true)
    }
}


// MARK: - Configuration
extension PhotoPreviewViewController {
    private func configureGesture() {
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftHandler(gesture: )))
        leftRecognizer.direction = .left
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightHandler(gesture: )))
        rightRecognizer.direction = .right
        
        view.addGestureRecognizer(leftRecognizer)
        view.addGestureRecognizer(rightRecognizer)
    }
    
    private func configureView() {
        view.addsubViews(statusBar, preview, bottomView)
        
        configureNavigationBar()
        configureConstraint()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .mainColor
    }
        
    private func configureConstraint() {
        configureConstraintStatusBar()
        configureConstraintPreview()
        configureConstraintrBottomView()
        configureConstraintTrashButton()
        configureConstraintCounterclockwiseButton()
        configureConstraintResizeButton()
    }
    
    private func configureConstraintStatusBar() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            statusBar.topAnchor.constraint(equalTo: view.topAnchor),
            statusBar.bottomAnchor.constraint(equalTo: safeArea.topAnchor),
            statusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureConstraintPreview() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            preview.topAnchor.constraint(equalTo: safeArea.topAnchor),
            preview.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            preview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            preview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            preview.heightAnchor.constraint(equalTo: bottomView.heightAnchor, multiplier: 8.0)
        ])
    }
    
    private func configureConstraintrBottomView() {
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureConstraintTrashButton() {
        NSLayoutConstraint.activate([
            trashButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor, constant: -Constants.defaultLayoutYMargin),
            trashButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: Constants.defaultLayoutXMargin),
        ])
    }
    
    private func configureConstraintCounterclockwiseButton() {
        NSLayoutConstraint.activate([
            counterclockwiseButton.centerYAnchor.constraint(equalTo: trashButton.centerYAnchor),
            counterclockwiseButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor)
        ])
    }
    
    private func configureConstraintResizeButton() {
        NSLayoutConstraint.activate([
            resizeButton.centerYAnchor.constraint(equalTo: trashButton.centerYAnchor),
            resizeButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -Constants.defaultLayoutXMargin)
        ])
    }
    
    private func updatePreview(photos: [Entity.Photo]) {
    }
}
