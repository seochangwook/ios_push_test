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

class MongoDBcrudController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    //서버의 ip주소와 포트번호//
    var server_ip_address:String = "172.30.1.2"
    var server_port_number = "3000"
    
    //데이터 배열//
    var usernamelist = [String]();
    var rolelist = [String]();
    var imagelist = [String]();
    
    //검색바를 위한 필요 변수(기준 데이터)//
    var filteredData: [String]!
    
    @IBOutlet weak var memberlist: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
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
        self.searchbar.delegate = self //SearchBar 관련 이벤트 처리//
        
        self.filteredData = self.usernamelist //필터링 배열에 원본데이터배열을 등록//
        
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
        return self.filteredData.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped cell number \((indexPath as NSIndexPath).row).");
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:MemberTableViewCell = self.memberlist.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier) as! MemberTableViewCell
        
        let row = indexPath.row;
        
        cell.membername?.text = self.filteredData[row];
        cell.memberrole?.text = self.rolelist[row];
        cell.movebutton?.tag = row;
        
        //이미지 셋팅//
        let url = URL(string:self.imagelist[row]);
        let processor = RoundCornerImageProcessor(cornerRadius: 80) //이미지 변형(동그랗게 자르기)//
        
        cell.memberimage.kf.setImage(with: url, options: [.processor(processor)]);
        
        //TableView Badge - 데이터를 받아올 시 특수 경우에 대해서는 배지처리//
        if(self.filteredData[row] == "admin3"){
            cell.badgeString = "success"
        } else if(self.filteredData[row] == "admin4"){
            cell.badgeColor = .lightGray
            cell.badgeString = "fail"
            cell.badgeTextColor = .black;
            cell.accessoryType = .detailButton
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headercell = self.memberlist.dequeueReusableCell(withIdentifier: self.headercellIdentifier) as? MemberTableHeaderViewCell;
        
        //각 섹션마다 정보를 다르게 해준다. (복합리스트 가능)//
        switch(section){
        case 0:
            //해당 섹션에서 필요한 작업을 해준다 (셀)//
            headercell?.membercountlabel?.text = String(self.filteredData.count);
            
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
                            
                            self.filteredData = self.usernamelist //네트워크로 받은 데이터를 필터 배열에 저장//
                            self.memberlist.reloadData();
                            
                            self.refreshController.endRefreshing();
                        }
                    }
                    
                    break;
                    
                case .failure(_):
                    print(response.result.error);
                    
                    break;
                }
            }
        }
    }
    
    /** SearchBar 관련 메소드 **/
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchbar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? usernamelist : usernamelist.filter({(dataString: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return dataString.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        memberlist.reloadData() //필터링 된 데이터를 기준으로 다시 테이블뷰를 설정//
    }
    
    //검색바에서 입력을 하기 시작할 경우//
    func searchBarTextDidBeginEditing(_ searchbar: UISearchBar) {
        self.searchbar.showsCancelButton = true //취소버튼 보이기//
    }
    
    //취소버튼 클릭 시 키보드 닫히기, 검색어 초기화//
    func searchBarCancelButtonClicked(_ searchbar: UISearchBar) {
        self.searchbar.showsCancelButton = false
        self.searchbar.text = ""
        self.searchbar.resignFirstResponder()
    }
    
    //키보드에서 검색버튼 눌렀을 경우//
    func searchBarSearchButtonClicked(_ searchbar: UISearchBar){
        print("search text: ", self.searchbar.text!)
        
        let refreshAlert = UIAlertController(title: "검색결과", message: self.searchbar.text!, preferredStyle: UIAlertControllerStyle.alert)
        
        //다이얼로그에 버튼 등록//
        refreshAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action: UIAlertAction!) in
            print("검색확인")
            
            self.searchbar.showsCancelButton = false
            self.searchbar.text = ""
            self.searchbar.resignFirstResponder()
        }))
        
        present(refreshAlert, animated: true, completion: nil) //작성된 다이얼로그를 만들어 준다.//
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //이동할 스토리보드의 id저장.값이 변할 수 있는 것은 가변타입(var)로 한다. 고정값(상수)이면 let//
        var segue_id : String = ""
        segue_id = segue.identifier!
        
        //identifier값으로 비교한다.//
        print("segue id : [ "+segue_id+" ] id")
        
        //스토리보드의 id값을 가지고 이동할 스토리보드를 선택한다.//
        if(segue_id == "memberdetailinfoview")
        {
            print("move sotryboard...")
            
            let button = sender as? UIButton //현재 UIButton의 프로토콜로 왔으니 sender를 UIButton으로 캐스팅한다.//
            let cell_position = button?.tag //버튼의 tag값을 가져온다.(tag: 선택된 셀의 row값)//
            
            //값을 전달하기 위해서 목표 뷰를 설정(캐스팅)//
            let destination = segue.destination as! MemberDetailInfoViewController
            destination.name = self.filteredData[cell_position!];
        }

    }
}
