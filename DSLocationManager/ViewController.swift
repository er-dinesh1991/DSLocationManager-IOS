//
//  ViewController.swift
//  DSLocationManager
//
//  Created by Dinesh Saini on 8/25/17.
//  Copyright © 2017 Dinesh Saini. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        if let location = DSLocationManager.shared.currentLocation{
            print(location)
        }
        
        DSLocationManager.shared.updatedLocationCloser = { location in
            print(location)
        }
        
        DSLocationManager.shared.failureCloser = {  error in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

