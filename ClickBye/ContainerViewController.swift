//
//  ContainerViewController.swift
//  ClickBye
//
//  Created by Maxim  on 12/8/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import PageMenu

class ContainerViewController: UIViewController {
    
    var pageMenu: CAPSPageMenu?
    @IBOutlet weak var dropFrame: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        addControllers()
    }
    
    func setupUI() {
        
        self.title = "ClicBye"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.purple]
    }
    
    func addControllers() {
        
        var controllerArray : [UIViewController] = []
        
        let controller1 : ViewController1 = ViewController1(nibName: "vc1", bundle: nil)
        controller1.title = "Wish List"
        controllerArray.append(controller1) // black magick 🙏🏿
        let controller2 : ViewController2 = ViewController2(nibName: "vc2", bundle: nil)
        controller2.title = "Wish List"
        controllerArray.append(controller2)
        let controller3 : ViewController3 = ViewController3(nibName: "vc3", bundle: nil)
        controller3.title = "Wish List"
        controllerArray.append(controller3)
        
        
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)),
            .viewBackgroundColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)),
            .selectionIndicatorColor(UIColor.orange),
            .bottomMenuHairlineColor(UIColor(red: 70.0/255.0, green: 70.0/255.0, blue: 80.0/255.0, alpha: 1.0)),
            .menuItemFont(UIFont(name: "HelveticaNeue", size: 13.0)!),
            .menuHeight(50.0),
            .menuItemWidth(90.0),
            .centerMenuItems(true),
            
            
            
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 0.0,
                                                                                width: self.dropFrame.frame.width,
                                                                                height:self.dropFrame.frame.height),
                                                                        pageMenuOptions: parameters)
        
        self.addChildViewController(pageMenu!)
        self.dropFrame.addSubview(pageMenu!.view)
        
        
        pageMenu!.didMove(toParentViewController: self)
    }
    
    // MARK: - Container View Controller
    override var shouldAutomaticallyForwardAppearanceMethods : Bool {
        return true
    }
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }

    
}
