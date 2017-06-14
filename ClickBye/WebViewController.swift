//
//  WebViewController.swift
//  ClickBye
//
//  Created by Maxim  on 2/21/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var link = ""
    
    static let storyboardID = "web"
    static var webViewController = {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WebViewController.storyboardID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let url = NSURL(string: link)
        let request = NSURLRequest(url: url as! URL)
        webView.loadRequest(request as URLRequest)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
