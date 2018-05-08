//
//  Photo.swift
//  MLModule
//
//  Created by dabechen on 2018/4/22.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import UIKit

struct Photo{
    var title:String
    var photoContent:[PhotoContent]
//    var photoURL:[String]
//    var isSelected:Bool
}
struct PhotoContent {
    var id:String
    var photoURL:String
    var isSelected:Bool
}
