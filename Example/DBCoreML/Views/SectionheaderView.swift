//
//  SectionheaderView.swift
//  MLModule
//
//  Created by dabechen on 2018/4/17.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import UIKit

class SectionheaderView: UICollectionReusableView {
    @IBOutlet weak var titleLabel:UILabel!
    
    var title:String!{
        didSet{
            titleLabel.text = title
        }
    }
}
