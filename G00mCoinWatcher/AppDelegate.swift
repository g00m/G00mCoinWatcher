//
//  AppDelegate.swift
//  G00mCoinWatcher
//
//  Created by Etienne on 12/13/17.
//  Copyright © 2017 Etienne. All rights reserved.
//

import Cocoa
import Alamofire

protocol ResponseHandledCallback {
    func handled(currentIndex : Int)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var timer: Timer!
    let coins = ["litecoin", "ripple", "bitcoin", "ethereum"]

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(AppDelegate.initCoinFetching), userInfo: nil, repeats: true)
    }
    
    @objc func initCoinFetching () {
        collectingCoins(index: 0)
    }
    
    func collectingCoins(index : Int) {
        fetchCoin(with: index) { (currentIndex : Int) in
            self.collectingCoins(index: currentIndex+1)
        }
    }
    
    func fetchCoin(with index : Int, completion: @escaping (_ index: Int) -> Void) {
        let request = URLRequest(url: URL(string: "https://api.coinmarketcap.com/v1/ticker/\(coins[index])")!)
        Alamofire.request(request).responseJSON { response in
            self.handleResponse(response: response)

            if(index == self.coins.count-1) {
                self.statusItem.title = self.statusString
            } else {
                completion(index)
            }
            
        }
        
    }
    
    var statusString = ""
    
    func handleResponse (response : DataResponse<Any>) {
        if let json = response.result.value {
            let response = json as! Array<NSDictionary>
            self.appendResponse(dic: response[0])
        }
    }
    
    func appendResponse (dic : NSDictionary) {
        self.statusString.append(String(format: "  %@: %@", dic["symbol"]! as! CVarArg, dic["price_usd"]! as! CVarArg))
    }

}

