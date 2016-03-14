//
//  SplitDetailViewController.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/10/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit

class SplitDetailViewController: UISplitViewController, UISplitViewControllerDelegate {

    var detailViewController: ActivityViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool{
        return true
    }
    
    func primaryViewControllerForCollapsingSplitViewController(splitViewController: UISplitViewController) -> UIViewController? {
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ActivityViewController
            return detailViewController
        }
        return nil
    }


}
