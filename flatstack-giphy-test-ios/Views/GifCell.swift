//
//  GifCell.swift
//  flatstack-giphy-test-ios
//
//  Created by Ришат Якушев on 13/12/2018.
//  Copyright © 2018 Flatstack. All rights reserved.
//

import UIKit
import Kingfisher

protocol GifCellDelegate: class {
    func didFinishLoad(_ gif: String, data: Data)
}

class GifCell: UICollectionViewCell {
    
    weak var delegate: GifCellDelegate?
    
    public var gifImageView: AnimatedImageView?
    public var gif: String? {
        didSet {
            configureGif()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        gifImageView = AnimatedImageView(frame: .zero)
        gifImageView?.contentMode = .scaleAspectFit
        addSubview(gifImageView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gifImageView?.frame = bounds
    }
    
    private func configureGif() {
        let urlString = gif ?? ""
        guard let url =  URL(string: urlString) else { return }
        let imageResource = ImageResource(downloadURL: url)
        gifImageView?.kf.setImage(with: imageResource)
//        setImage(
//            with: imageResource,
//            placeholder: nil,
//            options: [.backgroundDecode, .downloadPriority(1.0), .waitForCache],
//            progressBlock: nil,
//            completionHandler: nil
//        )
    }
    
}
