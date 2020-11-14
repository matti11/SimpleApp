//
//  MainScreenCell.swift
//  SimpleProject
//
//  Created by Mateusz Wojnar on 14/11/2020.
//  Copyright © 2020 Mateusz Wojnar. All rights reserved.
//

import UIKit
import Kingfisher

class MainScreenCell: UICollectionViewCell {

    @IBOutlet weak var contentColorView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    static let identifier = "MainScreenCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupImage(url : URL){
        let processor = ResizingImageProcessor(referenceSize: CGSize(width: mainImageView.frame.size.width, height: mainImageView.frame.size.height))
        mainImageView.kf.indicatorType = .activity
        mainImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(_):
               break
            case .failure(_):
                self.mainImageView.image = UIImage(named: "logo")
            }
        }
    }
}

