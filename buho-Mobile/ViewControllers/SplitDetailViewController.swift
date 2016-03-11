//
//  SplitDetailViewController.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/10/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit

class SplitDetailViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool{
        return true
    }


}
