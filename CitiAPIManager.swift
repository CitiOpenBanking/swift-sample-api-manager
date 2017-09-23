//
//  CitiAPIManager.swift
//  bar-graph
//
//  Created by Samuel Shields on 6/19/17.
//  Copyright © 2017 Samuel Shields. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CitiAPIManager {
    static let sharedInstance = CitiAPIManager();
    
    var clientID = "61e103d3-1f56-4b1b-901e-7bec976df39d"
    var clientSecret = "S5oK4dP8aW6pL7bE8uM4eE3aA0sU3wW6qR4gW1mS3bD4eK1kU7"
    var tokenURL = "https://sandbox.apihub.citi.com/gcb/api/authCode/oauth2/token/us/gcb"
    var accountsURL = "https://sandbox.apihub.citi.com/gcb/api/v2/accounts"
    var appAuthorization = "Basic NjFlMTAzZDMtMWY1Ni00YjFiLTkwMWUtN2JlYzk3NmRmMzlkOlM1b0s0ZFA4YVc2cEw3YkU4dU00ZUUzYUEwc1Uzd1c2cVI0Z1cxbVMzYkQ0ZUsxa1U3"
    var contentType = "application/x-www-form-urlencoded"
    var grantType = "authorization_code"
    var redirectURI = "https://clktr4ck.com/geh6"
    var code = ""
    var accessToken:String = ""
    var uuid = "a293fe0a-51ff-4b03-9376-022f1a1b453e"
    var accept = "application/json"
    var accountData:NSDictionary = NSDictionary()
    
    
    //handlers for OAuth Process
    var OAuthTokenCompletionHandler:((NSError?) -> Void)?
    
    func hasOAuthToken() -> Bool {
        //TODO: Implement
        return false
    }
    
    func startOAuth2Login(){
        let authPath:String = "https://sandbox.apihub.citi.com/gcb/api/authCode/oauth2/authorize?response_type=code&client_id=61e103d3-1f56-4b1b-901e-7bec976df39d&scope=accounts_details_transactions customers_profiles&countryCode=US&businessCode=GCB&locale=en_US&state=12093&redirect_uri=https://clktr4ck.com/geh6"
        var url: URL!
        url = URL(string: authPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        //print(url.absoluteString)
        
        UIApplication.shared.openURL(url)
    }
    
    func processOAuthStep1Response(url: URL){
        //let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        print("reached process oauth 1")
        let components = URLComponents(string: url.absoluteString)
        var code:String?
        if let queryItems = components?.queryItems {
            for queryItem in queryItems {
                if (queryItem.name.lowercased() == "code") {
                    code = queryItem.value
                    break
                }
            }
        }
        exchangeOAuthCodeForToken(code: code!)
        
    }
    
    func exchangeOAuthCodeForToken(code: String){
        //post, url,
        //headers: Authorization, Content-Type
        //body: grant_type, redirect_uri, code
        CitiAPIManager.sharedInstance.code = code
        
        let headers: HTTPHeaders = [
            "Authorization": appAuthorization,
            "Content-Type": contentType
        ]
        
        let parameters = [
            "grant_type": grantType,
            "redirect_uri": redirectURI,
            "code": code
        ]
        
        Alamofire.request(tokenURL, method: .post, parameters: parameters,encoding: URLEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    CitiAPIManager.sharedInstance.accessToken = JSON["access_token"] as! String
                    self.exchangeTokenForAccounts()
                    
                }
                break
            case .failure(let error):
                print(response)
                print(error)
                break
            }
        }
    }
    
    func exchangeTokenForAccounts(){
        //access token = "Bearer " + token
        //method .get
        //accounts URL
        //headers: Authorization (accesstoken), uuid, Accept, client_id
        print(CitiAPIManager.sharedInstance.accessToken)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + CitiAPIManager.sharedInstance.accessToken,
            "uuid": uuid,
            "Accept": accept,
            "client_id": clientID
        ]
        
        Alamofire.request(accountsURL, method: .get, encoding: URLEncoding.default, headers:headers).responseJSON {
            response in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    CitiAPIManager.sharedInstance.accountData = JSON
                    //get entryviewcontroller instance
                    //call push to arviewcontroller method
                    print("success!")
                    print(CitiAPIManager.sharedInstance.accountData)
                }
                break
            case .failure(let error):
                print(response)
                print(error)
                break
            }
        }
    }
    
    
}
