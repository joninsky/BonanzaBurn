//
//  ImageTransferProtocol.swift
//  BB
//
//  Created by Jon Vogel on 3/17/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import Foundation
import UIKit

protocol ImageTransferProtocol {
  
  func transferImage (_: UIImage)
  
}

protocol MaskTransferProtocol {
  
  func transferMaks (_:String)
  
  
}
