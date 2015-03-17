//
//  ViewController.swift
//  BB
//
//  Created by Jon Vogel on 3/17/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import UIKit

class TakePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageTransferProtocol {
  
  //MARK: Properties and outlets
  @IBOutlet weak var myImageView: UIImageView!
  
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  
  @IBOutlet weak var imageHeight: NSLayoutConstraint!
  
  var doubleTap: UITapGestureRecognizer?
  //MARK: Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    self.imageHeight.constant = self.myImageView.frame.width
    self.doubleTap = UITapGestureRecognizer()
    self.doubleTap!.addTarget(self, action: "doubleTapped:")
    self.doubleTap!.numberOfTapsRequired = 2
    self.view.addGestureRecognizer(self.doubleTap!)
    if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
      self.cameraButton.enabled = false
    }
  }
  
  //MARK: Camera picker methods.

  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    
    self.myImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  //MARK: Action outlets

  @IBAction func cameraButtonPressed(sender: AnyObject) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
    imagePickerController.allowsEditing = true
    imagePickerController.delegate = self
    self.presentViewController(imagePickerController, animated: true, completion: nil)
  }
  
  @IBAction func burnButtonPressed(sender: AnyObject) {
    if self.myImageView.image == nil {
      let alertController = UIAlertController(title: "No Photo", message: "We need something to fuel the burn! \n \n Either select the camera button in the top right or double tap to choose from your library of photos.", preferredStyle: UIAlertControllerStyle.Alert)
      
      let alertActionDismiss = UIAlertAction(title: "Ok, I'll do that.", style: UIAlertActionStyle.Default, handler: nil)
      
      alertController.addAction(alertActionDismiss)
      presentViewController(alertController, animated: true, completion: nil)
    }
  }
  
  func doubleTapped(sender: UITapGestureRecognizer){
    
    let DVC = self.storyboard?.instantiateViewControllerWithIdentifier("photoCollectionController") as PhotoCollectionViewController
    DVC.delegate = self
    DVC.mainImageSize = self.myImageView?.frame.size
    self.navigationController?.pushViewController(DVC, animated: true)    
  }
  
  func transferImage(theImage: UIImage) {
    self.myImageView.image = theImage
  }
  
}

