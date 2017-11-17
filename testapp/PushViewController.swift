//
//  PushViewController.swift
//  testapp
//
//  Created by seo on 2017. 11. 6..
//  Copyright © 2017년 seo. All rights reserved.
//

import Foundation
import UIKit

class PushViewController: UIViewController{
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        print("push view load...");
    }
    
    override func viewDidAppear(_ animated: Bool) //중복으로 호출가능.//
    {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
