//
//  ViewController.swift
//  BB
//
//  Created by Jon Vogel on 3/17/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import UIKit

class TakePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageTransferProtocol, MaskTransferProtocol {
  
  //MARK: Properties and outlets
  @IBOutlet weak var myImageView: UIImageView!
  
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  
  @IBOutlet weak var imageHeight: NSLayoutConstraint!
  
  @IBOutlet weak var saveButtom: UIBarButtonItem!
  
  var doubleTap: UITapGestureRecognizer?
  
  var imageID: String?
  //MARK: Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    self.imageHeight.constant = self.myImageView.frame.width * 0.6
    self.doubleTap = UITapGestureRecognizer()
    self.doubleTap!.addTarget(self, action: "doubleTapped:")
    self.doubleTap!.numberOfTapsRequired = 2
    self.view.addGestureRecognizer(self.doubleTap!)
    self.saveButtom.enabled = false
    
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
    }else{
      var imageData: NSData?
      var imageFile: PFFile?
      if self.myImageView.image != nil {
        imageData = UIImagePNGRepresentation(self.myImageView.image)
        imageFile = PFFile(name: "NewImage.png", data: imageData, contentType: "Image")
      }
      let newPraseImageObject = PFObject(className: "Images")
      if imageFile != nil {
        newPraseImageObject["theImage"] = imageFile
        newPraseImageObject["imageName"] = "An Image"
        newPraseImageObject["description"] = "My Image"
        //newPraseImageObject["imageURL"] = imageFile!.url
        newPraseImageObject.saveInBackgroundWithBlock({ (didSave, error) -> Void in
          if didSave {
            BurnerController.sharedBurn.lightTheFire(imageFile!.url!, completion: { (imageID, imagePosition) -> Void in
              self.imageID = imageID
              let miltiplier: Int = imagePosition!.toInt()!
              let secondsToWait: Double = Double(miltiplier) * 6
              let timer = NSTimer.scheduledTimerWithTimeInterval(secondsToWait, target: self, selector: "finishUpImageProcessing:", userInfo: nil, repeats: false)
              let alertController = UIAlertController(title: "In Line!", message: "Your photo was queued on the server in position \(imagePosition!) ", preferredStyle: UIAlertControllerStyle.Alert)
              
              let alertActionDismiss = UIAlertAction(title: "Thanks.", style: UIAlertActionStyle.Default, handler: nil)
              
              alertController.addAction(alertActionDismiss)
              self.presentViewController(alertController, animated: true, completion: nil)
            })
          }else{
            println("Phrase not saved")
          }
        })
      }
    }
  }
  
  func doubleTapped(sender: UITapGestureRecognizer){
    
    let DVC = self.storyboard?.instantiateViewControllerWithIdentifier("photoCollectionController") as PhotoCollectionViewController
    DVC.delegate = self
    DVC.mainImageSize = self.myImageView?.frame.size
    self.navigationController?.pushViewController(DVC, animated: true)    
  }
  
  
  //MARK: Button Functions
  @IBAction func saveImageAction(sender: AnyObject) {
    
    UIImageWriteToSavedPhotosAlbum(self.myImageView.image, nil, nil, nil)
    let alertController = UIAlertController(title: "Saved!", message: "We saved your photo on the camera roll", preferredStyle: UIAlertControllerStyle.Alert)
    
    let alertActionDismiss = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
    
    alertController.addAction(alertActionDismiss)
    self.presentViewController(alertController, animated: true, completion: nil)

  }
  
  
  
  func transferImage(theImage: UIImage) {
    self.myImageView.image = theImage
  }
  
  
  func transferMaks(theMask: String){
      BurnerController.sharedBurn.riseFromTheAshes(theMask, imageID: self.imageID!, completion: { (imageURL) -> Void in
        BurnerController.sharedBurn.fetchFinalImage(imageURL!, completion: { (theReturnedImage) -> Void in
            self.myImageView.image = theReturnedImage
            self.saveButtom.enabled = true
        })
    
      })
  }
  
  func finishUpImageProcessing(sender: AnyObject) {
    BurnerController.sharedBurn.getTheCharcoal(self.imageID!, completion: { (returnedDictionary) -> Void in
      if returnedDictionary.count == 0{
        let timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "finishUpImageProcessing:", userInfo: nil, repeats: false)
      }else{
        let dictionaryOfMasks = returnedDictionary
        let arrayOfKeys = [String](dictionaryOfMasks.keys)
        let DVC = self.storyboard?.instantiateViewControllerWithIdentifier("MaskCollectionView") as MaskCollectionViewController
        DVC.dictionaryOfMasks = returnedDictionary
        DVC.originalImage = self.myImageView.image
        DVC.delegate = self
        self.navigationController?.pushViewController(DVC, animated: true)
        
    
      }
    })
  }
}

