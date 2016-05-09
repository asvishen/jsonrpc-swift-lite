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
 * Implementation for TCP JSON-RPC Client
 * @version 1.0.0
 * @author: Avijit Vishen avijit.vishen@asu.edu
 * Software Engineering, CIDSE, Arizona State University,Polytechnic Campus
 */

import UIKit

public class TCPClient : NSObject, NSStreamDelegate,AbstractClient {
    
    var inputStream: NSInputStream!
    var outputStream: NSOutputStream!
    
    var JsonString : NSString = NSString()
    
    var resultDict : NSMutableDictionary = NSMutableDictionary()

    /**
     HTTP Client Constructor

     Creates a new HTTP client using url and port number

     :param:  url HTTP url of server in String format.

     :param:  port port number of server in string format
     
     */
 public  init(url: String, port : UInt32)  {
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil,url, port, &readStream, &writeStream)
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
    }

    /**
     Sends the JSON-RPC request using TCP

     TCP client sending RPC requests to server

     :param:  content dictionary containing JSON request.
     :param: completion exectutes completion handler upon data receive

     :returns: result JSON-RPC response in dictionary in completion handler.
     */
    
    public func sendRequest(content: NSMutableDictionary,completion:(result : NSMutableDictionary?)-> Void) {
    
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        
        self.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        self.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        self.inputStream.open()
        self.outputStream.open()
        
        var JsonString : NSData
        do
        {
            JsonString =  try NSJSONSerialization.dataWithJSONObject(content, options: NSJSONWritingOptions())
            self.outputStream.write(UnsafePointer<UInt8>(JsonString.bytes), maxLength: JsonString.length)
            
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            dispatch_async(backgroundQueue, {
                NSThread.sleepForTimeInterval(1)
                if(self.resultDict.count > 0){
                    let temp: NSMutableDictionary = NSMutableDictionary()
                    temp.setObject(self.resultDict as NSDictionary, forKey: "response")
                    completion(result :temp)
                }else{
                    completion(result :self.resultDict)
                }
                
            })
            
        }
        catch let error as NSError
        {
            print(error)
        }
    }

    /**

     Handles stream status using Stream events

     :param:  aStream stream object to handle
     
     :param: eventCode code for the stream to be handled

     :returns: result JSON-RPC response in dictionary.
     */
    public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch (eventCode){
        case NSStreamEvent.ErrorOccurred:
            break
        case NSStreamEvent.EndEncountered:
            aStream.close()
            aStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            break
        case NSStreamEvent.None:
            break
        case NSStreamEvent.HasBytesAvailable:
            if (aStream == inputStream) {
                
                let bufferSize = 1024
                var buffer = Array<UInt8>(count: bufferSize, repeatedValue: 0)
                var len: Int;
                
                while (inputStream.hasBytesAvailable) {
                    len = inputStream.read(&buffer, maxLength: bufferSize)
                    
                    if (len > 0 ){
                        self.JsonString = NSString(bytes: &buffer, length: len, encoding: NSUTF8StringEncoding)!
                        self.resultDict = getValue(self.JsonString.dataUsingEncoding(NSUTF8StringEncoding)!)
                    }
                }
            }
            break;
        case NSStreamEvent.OpenCompleted:
            break
        default:
            break
        }
        
    }
    /**
     Return the JSON response from the TCP response

     :param:  content dictionary containing TCP response

     :returns: result JSON-RPC response object in dictionary.
     */
   public func getValue(data : NSData) -> NSMutableDictionary{
        var jsonDictionary:NSMutableDictionary = NSMutableDictionary()
        do{
            jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSMutableDictionary
            
        }
        catch let error as NSError{
            print(error)
        }
        return jsonDictionary
    }
}