//
//  MemberDetailInfoViewController.swift
//  testapp
//
//  Created by seo on 2017. 11. 12..
//  Copyright © 2017년 seo. All rights reserved.
//

import Foundation
import UIKit

class MemberDetailInfoViewController: UIViewController{
    @IBOutlet weak var membername: UILabel!
    
    var name : String  = "";
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        print("detail view load...");
    }
    
    override func viewDidAppear(_ animated: Bool) //중복으로 호출가능.//
    {
        membername.text = name;
        print("name detail: " + name);
        
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
