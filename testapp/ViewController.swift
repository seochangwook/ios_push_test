//
//  ViewController.swift
//  testapp
//
//  Created by seo on 2017. 11. 3..
//  Copyright © 2017년 seo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import Firebase

class ViewController: UIViewController {
    var point = 0;
    
    //서버의 ip주소와 포트번호//
    var server_ip_address:String = "172.30.1.60"
    var server_port_number = "8000"
    
    @IBOutlet weak var pointlabel: UILabel!
    @IBOutlet weak var urlimage: UIImageView!
    @IBOutlet weak var testimageview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("success load");
        
        //AppDelegate에서 작업필요//
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        
        print("viewDidAppear()");
        
        testimageview.image = UIImage(named: "Resource/no_image.png"); //아마자 설정(경로 정확히 설정)//
        
        UIApplication.shared.applicationIconBadgeNumber = 0 //해당 페이지로 들어오면 알림 배지를 초기화//
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func test1buttonclick(_ sender: UIButton) {
        print("click button alert");
        
        //create the alert//
        let alertdialog = UIAlertController(
            title: "test app",
            message: "point one increase?",
            preferredStyle:UIAlertControllerStyle.alert);
        
        //add the action (buttons) add Handler action//
        alertdialog.addAction(UIAlertAction(
            title: "Yes",
            style: UIAlertActionStyle.default,
            handler: { action in
                // do something like...
                self.addPointAction()
        }));
        alertdialog.addAction(UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.cancel,
            handler: nil));
        
        //show the alert//
        self.present(alertdialog, animated: true, completion: nil);
    }
    
    @IBAction func getDataServer(_ sender: UIButton) {
        loadData();
    }
    
    func loadData(){
        print("get data for spring server");
        
        var progress = ProgressDialog(delegate: self)
        
        let parameters = [
            "user_id":"1595d09bdc5a5154d5abfb31203753bdf03c2470"
        ]
        
        progress.Show(true, mesaj: "Loading...")
        
        //호출//
        Alamofire.request("http://"+self.server_ip_address+":"+self.server_port_number+"/userdetailinfo", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            //swift-case로 응답성공/실패를 분리//
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    //JSON값을 가지고 파싱//
                    let json = JSON(data);
                    
                    //속성들에 접근//
                    var userphonenumber = json["userphonenumber"].stringValue
                    var username = json["username"].stringValue
                    var address = json["useraddress"].stringValue
                    
                    print("user phonenumber: " + userphonenumber);
                    print("user name: " + username);
                    print("user address: " + address);
                    
                    //네트워크 작업을 다 완료 후 수행(async - 비동기 작업)//
                    DispatchQueue.main.async {
                        progress.Close()
                        
                        print("finish job...");
                        
                        let url = URL(string: "https://raw.githubusercontent.com/seochangwook/ios-blog-project/master/default_humanimage.png") //이미지 로딩(비동기, 캐싱기능 포함)//
                        let processor = RoundCornerImageProcessor(cornerRadius: 80) //이미지 변형(동그랗게 자르기)//
                        self.urlimage.kf.setImage(with: url, options: [.processor(processor)]);
                    }
                }
                
                break
                
            case .failure(_):
                print(response.result.error);
                
                break
                
            }
        }
    }
    
    //Handler function//
    func addPointAction(){
        print("add point");
        
        point = point + 1;
        
        pointlabel.text = String(point);
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
        if(segue_id == "navviewcontroller")
        {
            print("move sotryboard...")
            
            //새로운 UINavigation으로 분기할때는 UINavigationController를 먼저 클래스 할당 후 topViewController로 등록//
            let nav = segue.destination as! UINavigationController
            let destination = nav.topViewController as! NavViewController
            
            destination.segue1_value = "nav main page" //이동할 스토리보드에 있는 값을 받을 변수설정//
        } else if(segue_id == "navviewcontroller"){
            print("move sotryboard...")
            
            //새로운 UINavigation으로 분기할때는 UINavigationController를 먼저 클래스 할당 후 topViewController로 등록//
            let nav = segue.destination as! UINavigationController
            let destination = nav.topViewController as! MongoDBcrudController
        }
    }
}
