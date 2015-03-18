//
//  GlobalData.swift
//  BB
//
//  Created by Jon Vogel on 3/17/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import UIKit

class GlobalData: NSObject {
  
  class var sharedData: GlobalData {
    struct Static {
      static let instance: GlobalData = GlobalData()
    }

    return Static.instance
  }
  
  
  override init() {
    super.init()
    
    
    
  }
  
  
  
  
  
  
  
  
}
