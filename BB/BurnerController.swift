//
//  BurnerController.swift
//  BB
//
//  Created by Jon Vogel on 3/17/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import UIKIT

class BurnerController: NSObject {
  
  //Global instance for singleton pattern.
  class var sharedBurn: BurnerController {
    struct Static {
      static let instance: BurnerController = BurnerController()
    }
    return Static.instance
  }
  
  override init() {
    super.init()
    
    
    
  }
  
  
  
  
}
