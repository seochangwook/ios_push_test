//
//  NavViewController.swift
//  testapp
//
//  Created by seo on 2017. 11. 5..
//  Copyright © 2017년 seo. All rights reserved.
//

import Foundation
import UIKit

class NavViewController: UIViewController{
    var segue1_value : String = "";
    
    @IBOutlet weak var segue_label: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        print("nav viewcontroller load...");
        
        segue_label.text = segue1_value;
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
    
    @IBAction func back_storyboard(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //스토리보드 이동(Modal, Push(Navigation)방식 모두 prepare에서 한다.)//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //이동할 스토리보드의 id저장.값이 변할 수 있는 것은 가변타입(var)로 한다. 고정값(상수)이면 let//
        var segue_id : String = ""
        segue_id = segue.identifier!;
        
        //identifier값으로 비교한다.//
        print("segue id : ", segue_id+" id")
        
        //스토리보드의 id값을 가지고 이동할 스토리보드를 선택한다.//
        if(segue_id == "pushviewcontroller")
        {
            print("move sotryboard...")
            
            //값을 전달하기 위해서 목표 뷰를 설정(캐스팅)//
            let destination = segue.destination as! PushViewController
            
            //destination.segue1_value = "nav main page" //이동할 스토리보드에 있는 값을 받을 변수설정//
        }
    }
}
