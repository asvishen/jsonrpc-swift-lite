//
//  ViewController.swift
//  testRPC
//
//  Created by Avijit Vishen on 4/9/16.
//  Copyright © 2016 Avijit Vishen. All rights reserved.
//

import UIKit
import JSONRPCLite


class ViewController: UIViewController {

    var id : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        let dict: NSMutableDictionary = NSMutableDictionary()

        let httpClient : CalculatorHTTPClientProxy = httpClient.init(urlName: "localhost", id: 1, port: 8080)
        
        httpClient.add(2,param2:33) { (finalRes, error) in
            if(error){

            }else{
                print(finalRes)
            }

        }

        let tcpClient : CalculatorTCPClientProxy = tcpClient.init(urlName: "localhost", id: 2, port: 8080)


        tcpClient.get("JimBuffett") { (finalRes, error) in
            if(error){
                
            }else{
                print(finalRes.name)
                print(finalRes.studentid)
                print(finalRes.takes)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

