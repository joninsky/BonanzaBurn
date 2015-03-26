//
//  Custom.swift
//  BB
//
//  Created by Jon Vogel on 3/26/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import UIKit

class Custom: UIImageView {

  var lastTouch: CGPoint?
  
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
  
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    
    super.touchesBegan(touches, withEvent: event)
    let touch: UITouch = touches.anyObject() as UITouch
    
    self.lastTouch = touch.locationInView(self)
    println(lastTouch)
    
  }
  
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    
    
    
    let touch: UITouch = touches.anyObject() as UITouch
    
  
    
    let currentPoint: CGPoint = touch.locationInView(self)
    
    self.lastTouch = currentPoint
    
    println(self.lastTouch)
    
  }
  
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    
    println(self.lastTouch)
    
  }
  
  

}
