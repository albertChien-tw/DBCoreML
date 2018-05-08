//
//  CollectionViewCell.swift
//  MLModule
//
//  Created by dabechen on 2018/4/16.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: CustomImageView!
    
    override func awakeFromNib() {
        //self.contentView.animation(size: self.frame.size.width)
        self.contentView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    }

    override func prepareForReuse() {

    }
    
}
