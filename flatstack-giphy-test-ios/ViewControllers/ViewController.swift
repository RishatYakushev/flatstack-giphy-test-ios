//
//  ViewController.swift
//  flatstack-giphy-test-ios
//
//  Created by Ришат Якушев on 13/12/2018.
//  Copyright © 2018 Flatstack. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {

    // MARK: - Instance Methods

    @IBAction func addGifAction(_ sender: Any) {
        addController()
    }
    
    // MARK: -
    
    private func addController() {
        let gifController = GifController()
        gifController.delegate = self
        self.present(gifController, animated: true, completion: nil)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        guard let viewToSwipe = sender.view else { return }
        sender.view?.center = CGPoint(
            x: viewToSwipe.center.x + translation.x,
            y: viewToSwipe.center.y + translation.y
        )
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if let view = sender.view {
            view.transform = view.transform.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1
        }
    }
    
    @objc func handleRotate(_ sender: UIRotationGestureRecognizer) {
        if let view = sender.view {
            view.transform = view.transform.rotated(by: sender.rotation)
            sender.rotation = 0
        }
    }
}

extension ViewController: GifControllerDelegate {
    func didSelect(_ gifImage: URL) {
        let width = view.frame.width/3 - 4
        let size = CGSize(width: width, height: width)
        let gifImageView = AnimatedImageView(frame: CGRect(
            x: 0,
            y: 0,
            width: size.width,
            height: size.height)
        )
        gifImageView.contentMode = .scaleAspectFit
        let imageResource = ImageResource(downloadURL: gifImage)
        
        gifImageView.kf.setImage(with: imageResource)
        
        gifImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        gifImageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinch)))
        gifImageView.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(_:))))
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delegate = self
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        pinch.delegate = self
        
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
        rotation.delegate = self
        
        gifImageView.isUserInteractionEnabled = true
        
        gifImageView.center = view.center
        
        view.addSubview(gifImageView)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ViewController: UIGestureRecognizerDelegate {
    
    // MARK: - Instance Methods

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
