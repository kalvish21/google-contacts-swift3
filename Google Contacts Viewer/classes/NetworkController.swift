//
//  GCANetworkController.swift
//  GoogleContactsAppSwift
//
//  Created by Jack Freeman on 2/23/16.
//  Copyright © 2016 Jack Freeman. All rights reserved.
//

import Foundation

public class NetworkController: NSObject {
    
    private var session: URLSession
    private var accessToken: String? = nil
    
    override init() {
        let sessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.ephemeral
        self.session = URLSession.init(configuration: sessionConfiguration)
    }
    
    init(accessToken: String) {
        let sessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.ephemeral
        let formattedToken : NSString = NSString(format: "Bearer %@", accessToken)
        sessionConfiguration.httpAdditionalHeaders = ["Authorization" : formattedToken, "GData-Version" : "3.0"]
        self.accessToken = accessToken
        self.session = URLSession.init(configuration: sessionConfiguration)
    }
    
    public func sendRequestToURL(url : NSURL, completion: @escaping (NSData?, HTTPURLResponse?, NSError?) -> ()) {
        let dataTask : URLSessionDataTask = (self.session.dataTask(with: url as URL, completionHandler:{(data, response, error) -> Void in
            let httpResponse : HTTPURLResponse =  response as! HTTPURLResponse
            DispatchQueue.main.async(execute: { () -> Void in
                completion(data as NSData?, httpResponse, error as NSError?)
            })
        }))
        
        dataTask.resume()
    }
    
    
}
