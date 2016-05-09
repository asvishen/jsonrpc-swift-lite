
/**
* Copyright 2016 Avijit Singh Vishen
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* Implementation for HTTP JSON-RPC Client
* @version 1.0.0
* @author: Avijit Vishen avijit.vishen@asu.edu
* Software Engineering, CIDSE, Arizona State University,Polytechnic Campus
*/


import UIKit

public class HttpClient : NSObject,AbstractClient
{

    var stringURl : String = String()

    /**
     HTTP Client Constructor

     Creates a new HTTP client using url and port number

     :param:  url HTTP url of server in String format.

     :param:  port port number of server in string format

     */
    public init(url: String,port : UInt32)
    {
        stringURl = url
        stringURl += ":"
        stringURl += String(port)
    }

    /**
     Sends the HTTP request to server

     Packages the request in HTTP format

     :param:  content dictionary containing JSON request.

     :returns: result JSON-RPC response in dictionary.
     */
    
    public func sendRequest(content: NSMutableDictionary,completion:(result : NSMutableDictionary?)-> Void)  {

        let request = NSMutableURLRequest(URL: NSURL(string: stringURl)!)
        request.HTTPMethod = "POST"
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.addValue("text/plain", forHTTPHeaderField: "Accept-Encoding")
        request.timeoutInterval = 60

        do
        {

            request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(content, options: NSJSONWritingOptions())

        }
        catch let error as NSError
        {
            print(error)
            request.HTTPBody = nil
        }

        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data,response,error -> Void in
            if (error != nil)
            {
                let returnResults : NSMutableDictionary = NSMutableDictionary()
                returnResults.setValue("true", forKey: "error")
                returnResults.setValue("timeOut", forKey: "connectionTimeOut")
                let error : NSError = (error as NSError?)!
                if (error.code == -1001){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                    dispatch_async(dispatch_get_main_queue(), {
                    completion(result: returnResults)
                    })
                    })
                }
                else{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                    dispatch_async(dispatch_get_main_queue(), {
                    completion(result: returnResults)
                    })
                    })
                }
            }
            else{
                let returnResults : NSMutableDictionary = NSMutableDictionary()
                let test : NSHTTPURLResponse = (response as? NSHTTPURLResponse)!
                let contentType:String = (test.allHeaderFields["Content-Type"] as? String)!
                if ((data) != nil && response != nil) {
                    var receivedData: Bool = false
                    let statusCode : Int = (response as? NSHTTPURLResponse)!.statusCode
                if(statusCode == 200 || statusCode == 204 || statusCode == 245){
                    receivedData = true
                }else if(self.statusCodeValidation(String(statusCode), type: "4**") == true){
                    receivedData = false
                }else if(self.statusCodeValidation(String(statusCode), type: "5**") == true){
                    receivedData = false
                }else{
                    receivedData = false
                }
                if(receivedData == true){
                        do{
                            if(contentType == "application/json;charset=UTF-8"){
                                
                                let jsonDictionary:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                                returnResults.setValue(jsonDictionary , forKey: "response")
                                
                            }else if(contentType == "application/json"){
                                
                                let jsonDictionary:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                                    returnResults.setValue(jsonDictionary , forKey: "response")
                                
                            }else if(contentType == "text/plain"){

                                        let jsonDictionary:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                                        returnResults.setValue(jsonDictionary , forKey: "response")
                            }else{
                            }
                        }
                        catch let error as NSError{
                            print(error)
                        }
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                        dispatch_async(dispatch_get_main_queue(), {
                        completion(result: returnResults)})})
                    }
                else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(result: returnResults)

                        })
                    })
                    }

                    }
                    else {

                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                        dispatch_async(dispatch_get_main_queue(), {
                        completion(result: returnResults)

                        })
                        })
                    }
            }


        }).resume()

    }

    /**
     Validates Status codes for HTTP
     
     Uses regular expression to match status codes in 3 categories

     :param:  value code
     
     :param: type type of code

     :returns: true if matched with any category
     */
    public func statusCodeValidation(value : String, type : String) -> Bool{
        if(type == "2**"){
            let statusCodeRegex : String = "2[0-9]{2}"
            let statusCodePredicate : NSPredicate = NSPredicate(format: "SELF MATCHES %@", statusCodeRegex)
            return statusCodePredicate.evaluateWithObject(value)
        }
        else if(type == "4**"){
            let statusCodeRegex : String = "4[0-9]{2}"
            let statusCodePredicate : NSPredicate = NSPredicate(format: "SELF MATCHES %@", statusCodeRegex)
            return statusCodePredicate.evaluateWithObject(value)
        }else if(type == "5**"){
            let statusCodeRegex : String = "5[0-9]{2}"
            let statusCodePredicate : NSPredicate = NSPredicate(format: "SELF MATCHES %@", statusCodeRegex)
            return statusCodePredicate.evaluateWithObject(value)
        }
        return false
    }

}