//
//  MongoDBcrudController.swift
//  testapp
//
//  Created by seo on 2017. 11. 12..
//  Copyright © 2017년 seo. All rights reserved.
//
import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class MongoDBcrudController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //서버의 ip주소와 포트번호//
    var server_ip_address:String = "172.30.1.60"
    var server_port_number = "3000"
    
    //데이터 배열//
    var usernamelist = [String]();
    var rolelist = [String]();
    var imagelist = [String]();
    
    //선택값//
    var selectusername : String  = "";
    
    @IBOutlet weak var memberlist: UITableView!
    
    //TableView관련 Swipe Refresh 이벤트//
    var refreshController : UIRefreshControl!;
    
    //tableview id//
    let cellReuseIdentifier = "memberlistcell"
    let headercellIdentifier = "membertableheadercell"
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        print("mongodb viewdidload success...");
        
        self.memberlist.delegate = self;
        self.memberlist.dataSource = self;
        
        refreshController = UIRefreshControl();
        refreshController.attributedTitle = NSAttributedString(string:"Pull to refresh");
        
        refreshController.addTarget(self, action: #selector(self.refresh(_:)), for: UIControlEvents.valueChanged);
        
        memberlist.addSubview(refreshController); //새로고침 기능의 뷰를 테이블 뷰에 추가//
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        setListData(); //데이터 로드//
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    @IBAction func backbutton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usernamelist.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped cell number \((indexPath as NSIndexPath).row).");
        self.selectusername = self.usernamelist[(indexPath as NSIndexPath).row];
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MemberTableViewCell = self.memberlist.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier) as! MemberTableViewCell
        let row = indexPath.row;
        
        cell.membername?.text = self.usernamelist[row];
        cell.memberrole?.text = self.rolelist[row];
        
        //이미지 셋팅//
        let url = URL(string:self.imagelist[row]);
        let processor = RoundCornerImageProcessor(cornerRadius: 80) //이미지 변형(동그랗게 자르기)//
        
        cell.memberimage.kf.setImage(with: url, options: [.processor(processor)]);
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headercell = self.memberlist.dequeueReusableCell(withIdentifier: self.headercellIdentifier) as? MemberTableHeaderViewCell;
        
        //각 섹션마다 정보를 다르게 해준다. (복합리스트 가능)//
        switch(section){
        case 0:
            //해당 섹션에서 필요한 작업을 해준다 (셀)//
            headercell?.membercountlabel?.text = String(self.usernamelist.count);
            
            break;
        default:
            break;
        }
        
        return headercell;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch(section){
        case 0:
            return 30.0
        default:
            return 40.0
        }
    }
    
    //새로고침 함수//
    @objc func refresh(_ sender:AnyObject){
        print("refresh table");
        
        self.usernamelist.removeAll();
        self.rolelist.removeAll();
        self.imagelist.removeAll();
        
        self.selectusername = "";
        
        self.refreshController.endRefreshing();
        
        setListData(); //데이터 로드//
    }
    
    func setListData(){
        if(self.usernamelist.count != 0){
            print("refresh table")
            
            memberlist.reloadData() //뷰를 재로드//
            
            refreshController.endRefreshing() //다시 새로고침을 끝낸다.//
        } else{
            //데이터를 불러온다.(배열에 저장)//
            print("MongoDB memberdb get data list");
            
            var progress = ProgressDialog(delegate: self)
            
            progress.Show(true, mesaj: "Loading...")
            
            //호출//
            Alamofire.request("http://"+self.server_ip_address+":"+self.server_port_number+"/user/getuserinfo", method: .post, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                
                //swift-case로 응답성공/실패를 분리//
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value{
                        //JSON값을 가지고 파싱//
                        let json = JSON(data);
                        
                        //데이터를 해당 형식에 맞게 적절히 파싱//
                        for item in json.arrayValue {
                            self.usernamelist.append(item["username"].stringValue);
                            self.rolelist.append(item["role"].stringValue);
                            self.imagelist.append("https://raw.githubusercontent.com/seochangwook/Blog_Test_app/master/app/src/main/res/mipmap-xxhdpi/profile_hambur.png");
                        }
                        
                        //네트워크 작업을 다 완료 후 수행(async - 비동기 작업)//
                        DispatchQueue.main.async {
                            progress.Close()
                            
                            print("finish getuserinfo job...");
                            
                            self.memberlist.reloadData();
                            
                            self.refreshController.endRefreshing();
                        }
                    }
                    
                    break
                    
                case .failure(_):
                    print(response.result.error);
                    
                    break
                    
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //이동할 스토리보드의 id저장.값이 변할 수 있는 것은 가변타입(var)로 한다. 고정값(상수)이면 let//
        var segue_id : String = ""
        segue_id = segue.identifier!
        
        //identifier값으로 비교한다.//
        print("segue id : [",segue_id+"] id")
        
        //스토리보드의 id값을 가지고 이동할 스토리보드를 선택한다.//
        if(segue_id == "memberdetailinfoview")
        {
            print("move sotryboard...")
            
            //값을 전달하기 위해서 목표 뷰를 설정(캐스팅)//
            let destination = segue.destination as! MemberDetailInfoViewController
            destination.name = self.selectusername;
            
            self.selectusername = "";
        }

    }
}
