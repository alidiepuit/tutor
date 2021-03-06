//
//  Connector.swift
//  App568Play
//
//  Created by SSG on 4/26/16.
//  Copyright © 2016 Ramotion. All rights reserved.
//
import Foundation

public typealias ServiceResponse = (AnyObject?) -> Void

public class Connector: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    var _call:ServiceResponse?
    var urlRequest: NSURLRequest?
    
    public func callService(method: String, serviceURL: String, params: Dictionary<String, String>?, callback: ServiceResponse?) {
        var urlString: String = serviceURL
        var paramString: String = ""
        var paramInfo: String = ""
        if params != nil {
            for (key,value) in params! {
                // do stuff
                let v = value.stringByReplacingOccurrencesOfString(" ", withString: "+")
                paramInfo = "\(key)=\(v)&"
                paramString = paramString.stringByAppendingString(paramInfo)
            }
        }
        urlString = urlString.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        let myURL: NSURL = NSURL(string: urlString)!
        
        print("\(myURL)?\(paramString)")
        let myRequest: NSMutableURLRequest = NSMutableURLRequest(URL: myURL, cachePolicy: .ReloadIgnoringCacheData, timeoutInterval: 10.0)
        myRequest.HTTPMethod = method
        myRequest.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        urlRequest = myRequest
        _call = callback
        NSURLConnection.sendAsynchronousRequest(myRequest, queue: NSOperationQueue.mainQueue()) {
            (response, data, error) -> Void in
            do {
                Utils.unlock()
                if data != nil {
                    let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                    if (self._call != nil) {
                        self._call!(jsonObject)
                    }
                }
            } catch let aError as NSError {
                let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(aError)
                print(str)
            }
        }
    }
    
    public func callService(serviceURL: String, params: Dictionary<String, AnyObject>?, callback: ServiceResponse?) {
        let client = SRWebClient.POST(serviceURL).createBodyWithParameters(params)
        client.send({(response:AnyObject!, status:Int) -> Void in
            Utils.unlock()
            if callback != nil {
                callback!(response)
            }
            },failure:{(error:NSError!) -> Void in
                print(error)
        })
    }
    
    public func connection(connection: NSURLConnection, didReceiveData data: NSData) {

        do {
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
            if (_call != nil) {
                _call!(jsonObject)
            }
        } catch let aError as NSError {
            let str = NSString(data: data, encoding: NSUTF8StringEncoding)
            print(aError)
            print(str)
        }
    }
    
    public func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print(error)
        if (_call != nil) {
            _call!(nil)
        }
    }
}