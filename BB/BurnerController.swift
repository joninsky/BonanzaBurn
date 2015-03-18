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
  
  func lightTheFire(imageURL: String){
    
    var request = NSMutableURLRequest(URL: NSURL(string: "https://api.bonanza.com/api/background_burns")!)
    var session = NSURLSession.sharedSession()
    request.HTTPMethod = "POST"
    
    var params = ["key": "\(self.developerID)", "user_id": "\(self.userID)", "url": "\(imageURL)", "name": "testImage", "description": "First Image"] as Dictionary<String, String>
    
    var err: NSError?
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    
    let go = session.dataTaskWithRequest(request, completionHandler: { (returnedData, response, error) -> Void in
      if error == nil{
        if let httpResponse = response as? NSHTTPURLResponse {
          println(httpResponse.statusCode)
          if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(returnedData, options: nil, error: nil) as? [String: AnyObject] {
            println(jsonDictionary)
          }
          
        }
      }
    })
    
    go.resume()
    
  }
  
  
  
  
  
  
}
