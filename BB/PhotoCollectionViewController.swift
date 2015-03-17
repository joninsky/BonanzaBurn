//
//  PhotoCollectionViewController.swift
//  BB
//
//  Created by Jon Vogel on 3/17/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

  @IBOutlet weak var myCollectionView: UICollectionView!
  
  var arrayOfFetchedResults: PHFetchResult?
  var imageManager: PHCachingImageManager?
  var photoCollectionVIewFlowLayout: UICollectionViewFlowLayout?
  var mainImageSize: CGSize?
  var delegate: ImageTransferProtocol?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      self.photoCollectionVIewFlowLayout = UICollectionViewFlowLayout()
      self.myCollectionView!.collectionViewLayout = self.photoCollectionVIewFlowLayout!
      self.photoCollectionVIewFlowLayout?.itemSize = CGSize(width: 100, height: 100)
      self.photoCollectionVIewFlowLayout?.sectionInset = UIEdgeInsetsMake(10, 50, 10, 50)
      self.myCollectionView!.registerClass(PickerPhotoCell.self, forCellWithReuseIdentifier: "photoCell")
      self.myCollectionView.dataSource = self
      self.myCollectionView.delegate = self
      self.imageManager = PHCachingImageManager()
      self.arrayOfFetchedResults = PHAsset.fetchAssetsWithOptions(nil)

    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return self.arrayOfFetchedResults!.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let Cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as PickerPhotoCell
      let asset = arrayOfFetchedResults![indexPath.row] as PHAsset
      self.imageManager?.requestImageForAsset(asset, targetSize: CGSize(width: 100, height: 100), contentMode: PHImageContentMode.AspectFill, options: nil ) { (requestedImage, infoDictionary) -> Void in
        Cell.imageView.image = requestedImage
      }
    
        // Configure the cell
    
        return Cell
    }
  
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let asset = arrayOfFetchedResults![indexPath.row] as PHAsset
    self.imageManager!.requestImageForAsset(asset, targetSize: self.mainImageSize!, contentMode: PHImageContentMode.AspectFill, options: nil) { (returnedImage, dictionaryOfInfo) -> Void in
      self.delegate!.transferImage(returnedImage)
    }
    self.navigationController!.popViewControllerAnimated(true)
  }



}
