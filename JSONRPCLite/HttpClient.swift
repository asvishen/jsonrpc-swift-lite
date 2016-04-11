//
//  HttpClient.swift
//  JSONRPCLite
//
//  Created by Avijit Vishen on 4/9/16.
//  Copyright © 2016 Avijit Vishen. All rights reserved.
//

import UIKit

public class HttpClient : NSObject
{

    var stringURl : String = String()

    public init(url: String)
    {
        stringURl = url
    }
    
    public func sendRequest(content: NSMutableDictionary,completion:((result : NSMutableDictionary?)-> Void)!)  {

        var request = NSMutableURLRequest(URL: NSURL(string: stringURl)!)
        request.HTTPMethod = "POST"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 60

        print("Printing content dictionary from framework : \(content)")
        do
        {

//            try NSJSONSerialization.dataWithJSONObject(content, options: NSJSONWritingOptions())
            request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(content, options: NSJSONWritingOptions())

        }
        catch let error as NSError
        {
            request.HTTPBody = nil
        }

        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data,response,error -> Void in
            if (error != nil)
            {
                let returnResults : NSMutableDictionary = NSMutableDictionary()
                returnResults.setValue("timeOut", forKey: "connectionTimeOut")
                let error : NSError = (error as NSError?)!
                //                print(error.code)
                if (error.code == -1001){
                    //                    print ("Connection timeout error")
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                    dispatch_async(dispatch_get_main_queue(), {
                    completion(result: returnResults)
                    })
                    })
                }
                else{                //if(error.code == -1004 || error.code == -1005){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                    dispatch_async(dispatch_get_main_queue(), {
                    completion(result: returnResults)
                    })
                    })
                }
            }
            else{
                let test : NSHTTPURLResponse = (response as? NSHTTPURLResponse)!
                let contentType:String = (test.allHeaderFields["Content-Type"] as? String)!

                //                print("content type++++")
                //                print(contentType)

                //                print("returned Content type for \(requestURL) is \(contentType).")
                //                print("unique")

                if ((data) != nil && response != nil) {
                    var receivedData: Bool = false

                    //let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    let statusCode : Int = (response as? NSHTTPURLResponse)!.statusCode

                    //                    print(jsonStr)
                    //                    print("JSONSTR")

                if(statusCode == 200 || statusCode == 204 || statusCode == 245){
                //                        print("All OK")
                    receivedData = true
                }else if(self.statusCodeValidation(String(statusCode), type: "4**") == true){
                    receivedData = false
                }else if(self.statusCodeValidation(String(statusCode), type: "5**") == true){
                    receivedData = false
                //                            print("server not reachable")
                }else{
                    receivedData = false
                //                            print("Conectivity Error")
                }
                //                        print((response as? NSHTTPURLResponse)!.statusCode)

                if(receivedData == true){
                        let returnResults : NSMutableDictionary = NSMutableDictionary()
                        returnResults.setValue(statusCode, forKey: "StatusCode")
                        do{
                            if(contentType == "application/json;charset=UTF-8"){
                                let jsonDictionary:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                                returnResults.setValue(jsonDictionary , forKey: "DATA")
//                                if(jsonDictionary.allKeys as NSArray).containsObject("returnData" as String){
//                                let results = jsonDictionary["returnData"]!.mutableCopy() as? NSMutableDictionary
//                                returnResults.setValue(results , forKey: "ReturnData")
//                                }else{
//                                    returnResults.setValue("noReturnData", forKey: "noReturnData")
//                                }
                            }else if(contentType == "application/json"){
                            let jsonDictionary:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                                returnResults.setValue(jsonDictionary , forKey: "DATA")
//                            if(jsonDictionary.allKeys as NSArray).containsObject("returnData" as String){
//                            let results = jsonDictionary["returnData"]!.mutableCopy() as? NSMutableDictionary
//                            returnResults.setValue(results , forKey: "ReturnData")
//                        }else{
//                            returnResults.setValue("noReturnData", forKey: "noReturnData")
//                        }
                        }else if(contentType == "text/plain"){

                                let jsonDictionary:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                                returnResults.setValue(jsonDictionary , forKey: "DATA")
                            }else{
                                returnResults.setValue("notValidContentType", forKey: "notValidContentType")
                        }
                        }
                        catch{
                        //                                print(error)
                        }
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                            dispatch_async(dispatch_get_main_queue(), {
                            completion(result: returnResults)})})
                    }
                else {

                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(result: nil)

                        })
                    })
                    }


//                else{
//
//                    let statusCode : Int = (response as? NSHTTPURLResponse)!.statusCode
//                    if(self.statusCodeValidation(String(statusCode), type: "5**") == true){
//                        let returnResults : NSMutableDictionary = NSMutableDictionary()
//                        returnResults.setValue(statusCode, forKey: "StatusCode")
//                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
//                        dispatch_async(dispatch_get_main_queue(), {
//                        completion(result: returnResults)
//                        })
//                        })
//
//                    }else{
//                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
//                        dispatch_async(dispatch_get_main_queue(), {
//                        completion(result: nil)
//
//                        })
//
//                        })
//                    }
//
//                    }
                    }
                    else {

                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                        dispatch_async(dispatch_get_main_queue(), {
                        completion(result: nil)

                        })
                        })
                    }
            }


        }).resume()

    }

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