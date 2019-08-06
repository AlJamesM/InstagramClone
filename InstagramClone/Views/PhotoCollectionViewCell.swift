//
//  PhotoCollectionViewCell.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/6/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!

    var post : Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            self.photoImageView.sd_setImage(with: photoUrl)
        }
    }
}
