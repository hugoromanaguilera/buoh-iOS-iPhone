//
//  TabBarViewController.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 31-03-16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    var detailContract: Contract? {
        return TemporalData.sharedInstance.contrato
    }
    var detailContact : Contact? {
        return TemporalData.sharedInstance.contacto
    }
    var parseConnection : ParseConnection = ParseConnection.sharedInstance
    var tmpData: TemporalData = TemporalData.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
//        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
//        navigationItem.leftItemsSupplementBackButton = true
        // Do any additional setup after loading the view.
    }
    
    func selectItemtab() {
        
        if let viewControllersTab = viewControllers {
            for vc in viewControllersTab {
                if let selectedVC = selectedViewController {
                    vc.isEqual(selectedVC)
                }
            }
        }

    }

    



}
