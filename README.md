#Open Source JSON-RPC Client for Swift iOS Development

This is an open source JSON-RPC Client Library with a Proxy Generator

## Features

- Client Proxy Generator for TCP and HTTP Client
- Highly Automated implementation for Sending and Receiving of JSON Request & Responses
- Support for primitive and user defined object
- Automatic conversion from JSON to Swift Objects requires implementing additional methods to users' classes

## Limitations

- Collections and Arrays not supported
- Multiple request in batches not supported

## Platform Support

- iOS 9.2
- Swift 2.0
- Xcode 7.2

## Usage

Two ways to use this library
- Download the files in your project
- Build the project and add the built framework as an Embedded Framework AND Link Binary with Libraries(under Build Phases)

## Implementation

This library packages the JSON-RPC requests and responses in the background for Server and Clients. 
- Define an interface with the methods for which RPC calls need to be made.
- Proxy generator creates the stub for packaging client calls in JSON Request format
- Client calls the proxy client implementaton of the RPC method to package the call

## Requirements

For sending user defined objecs as Parameters as return types:
- provide .toJson() method for non-primitive objects 
- provide a constructor for non-primitive objects taking a JSON format dictionary as parameter

## Usage

Generate a proxy Client using the Proxy generator defined in Java

- Supply the server methods in a Java interface, together with the HTTP or TCP as a paramter String.
- Use the generated client proxy in Swift to call methods on the server
- Proxy handles the packaging and unpackaging of JSON format
- returns the unmarshalled result back to the user

### Interface 
Define a java interface. Use the Proxy Generator defined in [jsonrpc-java-lite](https://github.com/asvishen/jsonrpc-java-lite/blob/master/src/edu/asu/ser/jsonrpc/proxy/TestGenerator.java) to create a client proxy for HTTP or TCP.

```java
public interface Calculator {
	public int add(int a, int b);
}
```

### TCP Client Proxy

The Proxy Generator generates a Proxy containing implementation of the marshalling of request and unmarshalling of response from the interface
Code below was generated.


```swift
class CalculatorClientProxy: NSObject
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
                    else{
                        var x: Int!
                        handler(finalRes:x,error:true)
                    }
                }
                else{
                    var x: Int!
                    handler(finalRes:x,error:true)
                }
            }
        }
    }
}
```


### HTTP Client Proxy

Proxy Generator can generated HTTP client proxy for JSON-RPC requests and repsonse
Code below was generated.

```swift

class CalculatorClientProxy: NSObject
{
    var url: String
    var id: Int
    var portNo: UInt32
    var client : HttpClient
    init(urlName: String, id: Int, port : UInt32)
    {
        self.url=urlName
        self.id = id
        self.portNo = port
        self.client = HttpClient(url: self.url, port: self.portNo)
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
                    else{
                        var x: Int!
                        handler(finalRes:x,error:true)
                    }
                }
                else{
                    var x: Int!
                    handler(finalRes:x,error:true)
                }
            }
        }
    }
}
```
### Making the RPC call

In your controller intialize this class and call the RPC method when needed.
Use the handler's error object to check for error. 

```swift
let tcpClient : CalculatorClientProxy = CalculatorClientProxy.init(urlName: "localhost", id: 1, port: 8080)
ht.add(3, param2: 5) { (finalRes, error) in
      if(error){
            }else{
                print(finalRes)
            }
        }
```

## Without using the proxy Generator:

If you do not intend to use the proxy generator, you can use provide your own logic for JSON-RPC packaging and unpackaging.

### HTTP Client
```swift
var client: HttpClient = HttpClient(url: self.url, port: self.portNo)
```

### TCP Client
```swift
var client: TCPClient = TCPClient(url: self.url, port: self.portNo)
```
### Making the call for handcrafted stubs

The sendRequest function for both clients will return the result in JSON-RPC response format as an NSArray in the result variable

```swift
client.sendRequest(requestDict) { (result) -> Void in
   /// Your code to handle the NSArray object and extract the response
   }
```






