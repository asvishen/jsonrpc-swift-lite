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
 * Definition for  JSON-RPC Client
 * @version 1.0.0
 * @author: Avijit Vishen avijit.vishen@asu.edu
 * Software Engineering, CIDSE, Arizona State University,Polytechnic Campus
 */

import Foundation

protocol AbstractClient{

    /**
     Sends the request to client

     Packages the request in protocol format

     :param:  content dictionary containing JSON request.
     :param: completion executes completion handler on receiving the response

     :returns: result JSON-RPC response in dictionary.
     */
    func sendRequest(content: NSMutableDictionary,completion:(result : NSMutableDictionary?)-> Void)

}