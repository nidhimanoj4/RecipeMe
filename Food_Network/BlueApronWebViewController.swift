//
//  BlueApronWebViewController.swift
//  Food_Network
//
//  Created by Nidhi Manoj on 8/1/16.

import UIKit

class BlueApronWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    let url = "https://www.blueapron.com/users/sign_up"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let requestURL = NSURL(string: url)
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
