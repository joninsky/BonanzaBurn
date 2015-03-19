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
  
  
  var userID = "joninsky"
  var developerID = "BnJ9NLEG8d7zRia"
  
  override init() {
    super.init()
    
    
    
  }
  
  func lightTheFire(imageURL: String, completion: (id: String, position: String)-> Void){
    
    var request = NSMutableURLRequest(URL: NSURL(string: "https://api.bonanza.com/api/background_burns")!)
    var session = NSURLSession.sharedSession()
    request.HTTPMethod = "POST"
    
    var params = ["key": "\(self.developerID)", "user_id": "\(self.userID)", "url": "\(imageURL)"] as Dictionary<String, String>
    
    var err: NSError?
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    
    let go = session.dataTaskWithRequest(request, completionHandler: { (returnedData, response, error) -> Void in
      if error == nil{
        if let httpResponse = response as? NSHTTPURLResponse {
          println(httpResponse.statusCode)
          if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(returnedData, options: nil, error: nil) as? [String: AnyObject] {
            
            let id: AnyObject = jsonDictionary["id"]!
            let position: AnyObject = jsonDictionary["position_in_queue"]!
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              completion(id: "\(id)", position: "\(position)")
            })
            
          }
          
        }
      }
    })
    
    go.resume()
    
  }
  
  func getTheCharcoal(theImageID: String, completion: ([String:String]) -> Void){
    var request = NSMutableURLRequest(URL: NSURL(string: "https://api.bonanza.com/api/background_burns/\(theImageID)?key=BnJ9NLEG8d7zRia&user_id=joninsky")!)
    var session = NSURLSession.sharedSession()
    request.HTTPMethod = "GET"
    
    let go = session.dataTaskWithRequest(request, completionHandler: { (returnedData, response, error) -> Void in
      
      if error == nil{
        if let httpResponse = response as? NSHTTPURLResponse {
          //println(httpResponse.statusCode)
          if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(returnedData, options: nil, error: nil) as? [String: AnyObject] {
            let arrayOfMasks: [AnyObject] = jsonDictionary["masks"] as [AnyObject]
            var dictionaryToReturn: [String:String] = [String:String]()
            for item in arrayOfMasks{
              if let miniDictionary = item as? [String:AnyObject]{
                let idString: AnyObject = miniDictionary["id"]!
                dictionaryToReturn["\(idString)"] = miniDictionary["url"]! as? String
              }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              completion(dictionaryToReturn)
            })
            
          }
          
        }
      }
    })
    
    go.resume()
    
  }
  
  func riseFromTheAshes(theMask: String, imageID: String, completion: (imageURL: String) -> Void){
    
    var request = NSMutableURLRequest(URL: NSURL(string: "https://api.bonanza.com/api/background_burns/\(imageID)")!)
    //9642481
    var session = NSURLSession.sharedSession()
    request.HTTPMethod = "PUT"
    
     var params = ["key": "\(self.developerID)", "user_id": "\(self.userID)", "selected_mask_id": "\(theMask)"] as Dictionary<String, String>
    var err: NSError?
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let go = session.dataTaskWithRequest(request, completionHandler: { (returnedData, response, error) -> Void in
      println(error)
      println(response)
      
      if error == nil{
        if let httpResponse = response as? NSHTTPURLResponse {
          println(httpResponse.statusCode)
          if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(returnedData, options: nil, error: nil) as? [String: AnyObject] {
              let finalURL = jsonDictionary["final_result_url"] as String
              NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completion(imageURL: finalURL)
                
              })
          }
          
        }
      }
    })
    go.resume()
  }
  
  func fetchFinalImage(urlToImage: String, completion: (UIImage) -> Void){
    
    let URL = NSURL(string: urlToImage)!
    
    let imageQueue = NSOperationQueue()
    
    imageQueue.addOperationWithBlock { () -> Void in
      
      let imageData = NSData(contentsOfURL: URL)
      
      let finalImage = UIImage(data: imageData!)
      
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        
        completion(finalImage!)
        
      })
      
    }
    
    
  }
  
  
  
//End Class
}
