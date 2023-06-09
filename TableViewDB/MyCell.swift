//
//  MyCell.swift
//  TableViewDB
//
//  Created by RyanChiang on 2023/5/10.
//

import UIKit

class MyCell: UITableViewCell {
    
    
    @IBOutlet weak var imgPicture: UIImageView!
    
    @IBOutlet weak var lblNo: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblGender: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 大頭照取圓角成為正圓形(使用原寬度的一半取圓角)，並設定框線
        imgPicture.layer.cornerRadius = imgPicture.bounds.width / 2
        imgPicture.layer.borderWidth = 2
        imgPicture.layer.borderColor = UIColor.systemRed.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
