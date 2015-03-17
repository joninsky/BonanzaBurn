//
//  PhotoCell.swift
//  BB
//
//  Created by Jon Vogel on 3/17/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import UIKit

class PickerPhotoCell: UICollectionViewCell {
  
  
  let imageView = UIImageView()
  
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.imageView.backgroundColor   = UIColor.whiteColor()
    self.imageView.frame = self.bounds
    self.imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
    self.imageView.layer.masksToBounds  = true
    self.addSubview(imageView)
    var dictionaryOfViews = ["imageView": imageView]
    let imageViewVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: nil, metrics: nil, views: dictionaryOfViews)
    let imageViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: nil, metrics: nil, views: dictionaryOfViews)
    self.addConstraints(imageViewVerticalConstraint)
    self.addConstraints(imageViewHorizontalConstraints)
    
  }
  
  
  
  
  required init (coder aCoder: NSCoder){
    super.init(coder: aCoder)
  }
  
  
  
  
}
