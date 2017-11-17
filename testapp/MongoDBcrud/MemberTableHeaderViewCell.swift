//
//  MemberTableHeaderViewCell.swift
//  testapp
//
//  Created by seo on 2017. 11. 12..
//  Copyright © 2017년 seo. All rights reserved.
//

import Foundation
import UIKit

class MemberTableHeaderViewCell : UITableViewCell{
    //셀에 적용될 위젯들을 정의한다.//
    @IBOutlet weak var membercountlabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib();
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated);
    }
}
