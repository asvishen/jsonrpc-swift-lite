//
//  TCPClientProxy.swift
//  JSONRPCLite
// Generated class by proxy generator for swift
//
//  Created by Avijit Vishen on 5/9/16.
//  Copyright © 2016 Avijit Vishen. All rights reserved.
//

import Foundation

import UIKit
import JSONRPCLite

class TCPClientProxy: NSObject
{
    var url: String
    var id: Int
    var portNo: UInt32
    var client : TCPClient
    init(urlName: String, id: Int, port : UInt32)
    {
        self.url=urlName
        self.id = id
        self.portNo = port
        self.client = TCPClient(url: self.url, port: self.portNo)
    }


    func add(param1 : Int, param2 : Int, handler:(finalRes:Int, error:Bool) -> Void) {
        let requestDict : NSMutableDictionary = NSMutableDictionary()
        requestDict.setObject("add", forKey: "method")
        requestDict.setObject(id++,forKey:"id")
        requestDict.setObject("2.0", forKey: "jsonrpc")
        let paramArray : NSMutableArray = NSMutableArray()
        paramArray.addObject(param1 as Int)
        paramArray.addObject(param2 as Int)
        requestDict.setObject(paramArray as NSArray, forKey: "params")
        client.sendRequest(requestDict) { (result) -> Void in
            if(result  != nil){
                if(((result?.allKeys)! as NSArray).containsObject("response"))
                {
                    let jsonResult : NSDictionary = result?.valueForKey("response") as! NSDictionary
                    if((jsonResult.allKeys as NSArray).containsObject("result"))
                    {
                        let any : AnyObject = jsonResult.valueForKey("result")!
                        if let check = any as? Int {
                            handler(finalRes:check,error:false)
                        }
                    }else if((jsonResult.allKeys as NSArray).containsObject("error")){
                        var x: Int!
                        handler(finalRes:x,error:true)
                    }
                    else{let x: Int!
                        handler(finalRes:x,error:true)
                    }
                }
                else{
                    let x: Int!
                    handler(finalRes:x,error:true)
                }
            }
        }
    }
}