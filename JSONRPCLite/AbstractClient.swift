//
//  File.swift
//  JSONRPCLite
//
//  Created by Avijit Vishen on 4/9/16.
//  Copyright © 2016 Avijit Vishen. All rights reserved.
//

import Foundation

protocol AbstractClient{

    func sendRequest(request : String) -> String

}