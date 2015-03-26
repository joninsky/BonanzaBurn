//
//  ViewController.swift
//  BB
//
//  Created by Jon Vogel on 3/17/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import UIKit

class TakePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageTransferProtocol, MaskTransferProtocol, UIScrollViewDelegate {
  
  //MARK: Properties and outlets
  @IBOutlet weak var myImageView: UIImageView!
  
  @IBOutlet weak var myBurnButton: UIButton!
  
  @IBOutlet weak var myScrollView: UIScrollView!
  
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  
  @IBOutlet weak var imageHeight: NSLayoutConstraint!
  
  @IBOutlet weak var imageWidth: NSLayoutConstraint!
  
  @IBOutlet weak var saveButtom: UIBarButtonItem!
  
  var doubleTap: UITapGestureRecognizer?
  
  var pichRecognizer: UIPinchGestureRecognizer?
  
  var imageID: String?
  
  var blurEffectView: UIVisualEffectView?
  
  var activitySwirl: UIActivityIndicatorView?
  
  var isProcessed = false
  
  //MARK: Image Properties
  
  var lastTouch: CGPoint?
  
  //MARK: Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    //self.imageHeight.constant = self.myImageView.frame.width * 0.6
    
   // self.myImageView
    
    self.myScrollView.delegate = self
    self.doubleTap = UITapGestureRecognizer()
    self.doubleTap!.addTarget(self, action: "doubleTapped:")
    self.doubleTap!.numberOfTapsRequired = 2
    self.view.addGestureRecognizer(self.doubleTap!)
    self.saveButtom.enabled = false
    
    if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
      self.cameraButton.enabled = false
    }
    
    let theImageFile = NSBundle.mainBundle().pathForResource("BonanzaLogo", ofType: "png")!
    
    var theColor = UIColor(patternImage: UIImage(contentsOfFile: theImageFile)!)
    
    self.view.backgroundColor = theColor
    
    self.myScrollView.backgroundColor = UIColor.whiteColor()
    
    self.myBurnButton.addTarget(self, action: "touchDown:", forControlEvents: UIControlEvents.TouchDown)

  }
  
  //MARK: Camera picker methods.

  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    
    //Set the image from the camera
    let takenImage = info[UIImagePickerControllerEditedImage] as? UIImage
    //Set the image view's constraints
    self.imageHeight.constant = takenImage!.size.height
    self.imageWidth.constant = takenImage!.size.width
    //Set the image in the image view
    self.myImageView.image = takenImage
    
    self.setScrollZoomForImage(takenImage!, theScroll: self.myScrollView)
    
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
  
  
  func touchDown(sender: UIButton!){
    
    if self.isProcessed == true{
    
      self.myScrollView.scrollEnabled = false
      
    }
  }
  
  
  @IBAction func burnButtonPressed(sender: AnyObject) {
    
    if self.isProcessed == true {
      let alertController = UIAlertController(title: "Again?", message: "Do you want to process the photo again? If so the white will be completly removed.", preferredStyle: UIAlertControllerStyle.Alert)
      
      let alertActionProcess = UIAlertAction(title: "Process!", style: UIAlertActionStyle.Default, handler: { (theAction) -> Void in
        self.isProcessed == false
        self.myScrollView.scrollEnabled = true
        self.burnButtonPressed(self)
        
      })
      
      let alertActionDismiss = UIAlertAction(title: "No, I'll hold on.", style: UIAlertActionStyle.Default, handler: { (theAction) -> Void in
        self.myScrollView.scrollEnabled = true
      })
      
      alertController.addAction(alertActionDismiss)
      alertController.addAction(alertActionProcess)
      presentViewController(alertController, animated: true, completion: nil)
      return
    }
    
    
    //self.myScrollView.scrollEnabled = true
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
        //Display and Start Progress Bar
        // Blur Effect
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        self.blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.blurEffectView!.frame = view.bounds
        view.addSubview(self.blurEffectView!)
        
        // Vibrancy Effect
        var vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        var vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = view.bounds
        
        //Make and add progress bar
        self.activitySwirl = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.activitySwirl!.startAnimating()
        self.activitySwirl!.sizeToFit()
        self.activitySwirl!.center = self.view.center
        // Add label to the vibrancy view
        vibrancyEffectView.contentView.addSubview(self.activitySwirl!)
        
        // Add the vibrancy view to the blur view
        self.blurEffectView!.contentView.addSubview(vibrancyEffectView)
        
        //Disable user interactions
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        
        newPraseImageObject.saveInBackgroundWithBlock({ (didSave, error) -> Void in
          if didSave {
            BurnerController.sharedBurn.lightTheFire(imageFile!.url!, completion: { (imageID, imagePosition) -> Void in
              self.imageID = imageID
              UIApplication.sharedApplication().endIgnoringInteractionEvents()
              let miltiplier: Int = imagePosition!.toInt()!
              let secondsToWait: Double = Double(miltiplier) * 6
              let timer = NSTimer.scheduledTimerWithTimeInterval(secondsToWait, target: self, selector: "finishUpImageProcessing:", userInfo: nil, repeats: false)
              let alertController = UIAlertController(title: "In Line!", message: "Your photo was queued on the server in position \(imagePosition!) ", preferredStyle: UIAlertControllerStyle.Alert)
              
              let alertActionDismiss = UIAlertAction(title: "Thanks", style: UIAlertActionStyle.Default, handler: { (theAction) -> Void in
                
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
              })
              
              alertController.addAction(alertActionDismiss)
              self.presentViewController(alertController, animated: true, completion: nil)
              })
          }else{
            println("Phrase not saved")
            self.activitySwirl!.stopAnimating()
            self.blurEffectView?.removeFromSuperview()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
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
    
    let alertController = UIAlertController(title: "Save?", message: "Save your image to your local camera roll?", preferredStyle: UIAlertControllerStyle.Alert)
    
    let alertActionDismiss = UIAlertAction(title: "Wait! No!", style: UIAlertActionStyle.Default, handler: nil)
    let alertActionSave = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) { (theAction) -> Void in
       UIImageWriteToSavedPhotosAlbum(self.myImageView.image, nil, nil, nil)
    }
    
    alertController.addAction(alertActionDismiss)
    alertController.addAction(alertActionSave)
    self.presentViewController(alertController, animated: true, completion: nil)

  }
  
  @IBAction func infoButtonPressed(sender: AnyObject) {
    let alertController = UIAlertController(title: "Info", message: "Double tap to select from your camera roll. \n \n Touch the camera button to take a photo.", preferredStyle: UIAlertControllerStyle.Alert)
    
    let alertActionDismiss = UIAlertAction(title: "Thanks", style: UIAlertActionStyle.Default, handler: nil)
    
    alertController.addAction(alertActionDismiss)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  
  func transferImage(theImage: UIImage) {
    //Set the image view's constraints
    self.imageHeight.constant = theImage.size.height
    self.imageWidth.constant = theImage.size.width
    //Set the image in the image view
    self.myImageView.image = theImage
    
    self.setScrollZoomForImage(theImage, theScroll: self.myScrollView)
  }
  
  
  func transferMaks(theMask: String){
    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    BurnerController.sharedBurn.riseFromTheAshes(theMask, imageID: self.imageID!, completion: { (imageURL) -> Void in
        BurnerController.sharedBurn.fetchFinalImage(imageURL!, completion: { (theReturnedImage) -> Void in
          
          //Set the image view's constraints
          self.imageHeight.constant = theReturnedImage!.size.height
          self.imageWidth.constant = theReturnedImage!.size.width
          //Set the image in the image view
          self.myImageView.image = theReturnedImage
          
          self.setScrollZoomForImage(theReturnedImage!, theScroll: self.myScrollView)
          self.saveButtom.enabled = true
          self.activitySwirl!.stopAnimating()
          self.blurEffectView?.removeFromSuperview()
          UIApplication.sharedApplication().endIgnoringInteractionEvents()
          self.isProcessed = true
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
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        let DVC = self.storyboard?.instantiateViewControllerWithIdentifier("MaskCollectionView") as MaskCollectionViewController
        DVC.dictionaryOfMasks = returnedDictionary
        //DVC.originalImage = self.myImageView.image
        DVC.delegate = self
        self.navigationController?.pushViewController(DVC, animated: true)
      }
    })
  }
  
  
  //MARK: UIScrollVIew Delegate mehtods
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    
    return self.myImageView
    
  }
  
  //Custom Set Zoom method
  func setScrollZoomForImage(theImage: UIImage, theScroll: UIScrollView) {
    
    //Get the image Rect
    let imageRect = CGRectMake(0, 0, theImage.size.width, theImage.size.height)
    
    //Set the minimun (Zoom out) and maximum (Zoom in) properties in accordance to the size of the incomming image
    theScroll.minimumZoomScale = min(theScroll.frame.size.width / imageRect.width, theScroll.frame.height / imageRect.height)
    
    theScroll.maximumZoomScale = 10.0
    //Tell the Scroll view to set Zoom Scale. This call the viewForZoomingInScrollView delegate method.
    theScroll.setZoomScale(min(theScroll.frame.size.width / imageRect.width, theScroll.frame.height / imageRect.height), animated: true)
    //Dismiss the Image Picker controller.
    
    
  }
  
  
  //MARK: Touches Methods
  
  
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    
    let touch: UITouch = touches.anyObject() as UITouch
    if touch.view == self.myScrollView{
      lastTouch = touch.locationInView(self.myImageView)
      println(self.lastTouch)
    }
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    let touch: UITouch = touches.anyObject() as UITouch
    if touch.view == self.myScrollView {
      let currentPoint: CGPoint = touch.locationInView(self.myImageView)
      
      self.lastTouch = currentPoint
      
      println(self.lastTouch)

    }
  }
  
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    
    let touch: UITouch = touches.anyObject() as UITouch
    if touch.view == self.myScrollView{
      println(self.lastTouch)
    }
  }
  
}

