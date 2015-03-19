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
  
  
  //Hardcoded Developer ID and User ID
  var userID = "joninsky"
  var developerID = "BnJ9NLEG8d7zRia"
  
  
  //Custom init, nothing happens here.
  override init() {
    super.init()
  }
  
  //This is the funciton that initally gets called. It tells the Burner API where the image is located and to start the burn process
  func lightTheFire(imageURL: String, completion: (id: String?, position: String?)-> Void){
    //HTTP request that is initalized with the burn API URL
    var request = NSMutableURLRequest(URL: NSURL(string: "https://api.bonanza.com/api/background_burns")!)
    //Create an HTTP session
    var session = NSURLSession.sharedSession()
    //Set the HTTP method to POST
    request.HTTPMethod = "POST"
    //Create a dictionary of paramates that will be passed in the HTTP body
    var params = ["key": "\(self.developerID)", "user_id": "\(self.userID)", "url": "\(imageURL)"] as Dictionary<String, String>
    //Create an error for the JSON serialization to land on
    var err: NSError?
    //The Dictionary is essentially JSON so we turn it into data to be passed in the HTTP body
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
    //Change the content type HTTP header to tell it that JSON is comming through and can be accepted.
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    //Initiate the Session, this happens on a different thread
    let go = session.dataTaskWithRequest(request, completionHandler: { (returnedData, response, error) -> Void in
      //Check to make sure error is nill
      if error == nil{
        //Turn the response into an HTTP response object
        if let httpResponse = response as? NSHTTPURLResponse {
          println(httpResponse.statusCode)
          //Check to make sure we can turn the returned data into JSON
          if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(returnedData, options: nil, error: nil) as? [String: AnyObject] {
            //Get the burn ID out of the dictionary
            let id: AnyObject = jsonDictionary["id"]!
            //Get the position in queue data from the dictionary
            let position: AnyObject = jsonDictionary["position_in_queue"]!
            //Put the completion back on the main thread
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              //The completion will ge the burn ID and position in queue
              completion(id: "\(id)", position: "\(position)")
            })
            
          }
          
        }
      }else{
        //Put the compleiton on the main Queue
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          //Return nil for both paramaters of the completion
          completion(id: nil, position: nil)
        })
      }
    })
    //Calls the session.
    go.resume()
  //End lightTheFire method
  }
  
  
  //This functon checks for available masks. Available masks means that the burn is done. If no masks come back this funciton will get called again after another wait.
  func getTheCharcoal(theImageID: String, completion: ([String:String]) -> Void){
    //Since this is HTTP method is a GET we have to put eveything in the URL. IMAGEID, KEY, and USERID
    var request = NSMutableURLRequest(URL: NSURL(string: "https://api.bonanza.com/api/background_burns/\(theImageID)?key=BnJ9NLEG8d7zRia&user_id=joninsky")!)
    //create the HTTP session
    var session = NSURLSession.sharedSession()
    //set the HTTP request mehtod to GET
    request.HTTPMethod = "GET"
    //make the network call asynchrynously
    let go = session.dataTaskWithRequest(request, completionHandler: { (returnedData, response, error) -> Void in
      //Check for error
      if error == nil{
        //Create an HTTP response object out of the response
        if let httpResponse = response as? NSHTTPURLResponse {
          //Try and seralize the returned data into JSON
          if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(returnedData, options: nil, error: nil) as? [String: AnyObject] {
            //Get an array of Masks from the seralized JSON
            let arrayOfMasks: [AnyObject] = jsonDictionary["masks"] as [AnyObject]
              //Create the empty dictionary that will get returned
              var dictionaryToReturn: [String:String] = [String:String]()
              //For every items in array of Masks loop through
              for item in arrayOfMasks{
                //Make the item into a mask dictionary
                if let miniDictionary = item as? [String:AnyObject]{
                  //get the mask ID out of the Maks item and make it into a string
                  let idString: AnyObject = miniDictionary["id"]!
                  //Add an an item to the dictionary with the key as the mask ID and the value as the mask URL
                  dictionaryToReturn["\(idString)"] = miniDictionary["url"]! as? String
                }
              }
            //Put the completion handler on to the main queue
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              //Pass back the dictionary to return
              completion(dictionaryToReturn)
            })
          }
        }
      }else{
        //Create the empty dictionary that will get returned
        var dictionaryToReturn: [String:String] = [String:String]()
        //Put the completion handler on to the main queue
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          //Pass back the dictionary to return
          completion(dictionaryToReturn)
        })
      }
    })
    //Call the network request
    go.resume()
  //End getTheCharcoal
  }
  
  //This function will get the URL for the final image. It will apply the selected mask to the image and return the final URL.
  func riseFromTheAshes(theMask: String, imageID: String, completion: (imageURL: String?) -> Void){
    //We put the image ID into the URL
    var request = NSMutableURLRequest(URL: NSURL(string: "https://api.bonanza.com/api/background_burns/\(imageID)")!)
    //Create the HTTP session
    var session = NSURLSession.sharedSession()
    //Set the HTTP request method to PUT
    request.HTTPMethod = "PUT"
    //Dictionary of paramaters, this includes the mask ID
     var params = ["key": "\(self.developerID)", "user_id": "\(self.userID)", "selected_mask_id": "\(theMask)"] as Dictionary<String, String>
    var err: NSError?
    //Turn the dictionary into JSON then the JSON into data that will get passed with the HTTP body
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
    //Set the HTTP header fields to JSON encoding
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    //Start the session
    let go = session.dataTaskWithRequest(request, completionHandler: { (returnedData, response, error) -> Void in
      //Check for error
      if error == nil{
        //Turnt he response into an HTTP response object/
        if let httpResponse = response as? NSHTTPURLResponse {
          //Try and make a dictionary out of the returned data
          if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(returnedData, options: nil, error: nil) as? [String: AnyObject] {
              //The dictionary will contain the final URL
              let finalURL = jsonDictionary["final_result_url"] as String
              //Put the completion onto the main thread
              NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                //pass the final URL with the completion
                completion(imageURL: finalURL)
                
              })
          }
        }
      }else{
        //Put the completion onto the main thread
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          //pass the final URL with the completion
          completion(imageURL: nil)
          
        })
      }
    })
    //Make sure to call the network request
    go.resume()
  //End riseFromAshes method
  }
  
  //This function will fetch an image from a given URL. The URL has to be to only an image.
  func fetchFinalImage(urlToImage: String, completion: (UIImage?) -> Void){
    //Convert the url string into an NSURL
    let URL = NSURL(string: urlToImage)!
    //Create a new Queue that we will put the image download on
    let imageQueue = NSOperationQueue()
    //Add a thread with a block to the image queue
    imageQueue.addOperationWithBlock { () -> Void in
      //Get the image data from the URL
      let imageData = NSData(contentsOfURL: URL)
      //Make a UIImage from the image data
      if let finalImage = UIImage(data: imageData!) {
        //Put the completion back on the main thread
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          //Return the new image in the completion
          completion(finalImage)
        })
      }else{
        //Put the completion back on the main thread
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          //Return the new image in the completion
          completion(nil)
        })
      }
    }
  //End fetchFinalImage method
  }
  
  
  
//End Class
}
