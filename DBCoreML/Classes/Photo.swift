//
//  Photo.swift
//  MLModule
//
//  Created by dabechen on 2018/4/22.
//  Copyright © 2018年 Dabechen. All rights reserved.
//

import UIKit

public struct Photo{
    public var title:String
    public var photoContent:[PhotoContent]
//    var photoURL:[String]
//    var isSelected:Bool
}
public struct PhotoContent {
   public var id:String
   public var photoURL:String
   public var isSelected:Bool
}
