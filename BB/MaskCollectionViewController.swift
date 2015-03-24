//
//  MaskCollectionViewController.swift
//  BB
//
//  Created by Jon Vogel on 3/19/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import UIKit

class MaskCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  //MARK: Properties
  @IBOutlet weak var myCollectionView: UICollectionView!
  
  //var originalImage: UIImage?
  var dictionaryOfMasks: [String:String]?
  var arrayOfURLs: [String]?
  var arrayOfIDs: [String]?
  var delegate: MaskTransferProtocol?
  
  //MARK:Life Cycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let maskCollectionViewFlowLayout = UICollectionViewFlowLayout()
    self.myCollectionView.collectionViewLayout = maskCollectionViewFlowLayout
    maskCollectionViewFlowLayout.itemSize = CGSize(width: 500, height: 500)
    maskCollectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(10, 50, 10, 50)
    maskCollectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    self.myCollectionView.registerClass(PickerPhotoCell.self, forCellWithReuseIdentifier: "maskCell")
    self.myCollectionView.dataSource = self
    self.myCollectionView.delegate = self
    self.arrayOfURLs = [String](self.dictionaryOfMasks!.values)
    self.arrayOfIDs = [String](self.dictionaryOfMasks!.keys)
    self.navigationItem.title = "Select a Mask"
  }
  
  
  
  //MARK:CollectionView Datasource methods
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if self.dictionaryOfMasks! == NSNull() || self.dictionaryOfMasks!.count == 0 {
      return 1
    }else{
      return self.dictionaryOfMasks!.count
    }
  }
  
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let Cell = collectionView.dequeueReusableCellWithReuseIdentifier("maskCell", forIndexPath: indexPath) as PickerPhotoCell
    
    Cell.imageView.image = nil
    if self.dictionaryOfMasks! == NSNull() || self.dictionaryOfMasks!.count == 0 {
      
    }else{
      
      BurnerController.sharedBurn.fetchFinalImage(self.arrayOfURLs![indexPath.row], completion: { (theImage) -> Void in
        
        let layer = CALayer()
        layer.contents = theImage!.CGImage
        layer.frame = Cell.bounds
        Cell.imageView.layer.mask = layer
        Cell.imageView.backgroundColor = UIColor.whiteColor()
      
      })
      
      
      
    }
    return Cell
    
    
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    self.delegate?.transferMaks(self.arrayOfIDs![indexPath.row])
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  
  
}