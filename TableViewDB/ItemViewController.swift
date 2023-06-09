//
//  ItemViewController.swift
//  TableViewDB
//
//  Created by RyanChiang on 2023/6/5.
//

import UIKit

class ItemViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    // 接收ScrollView上點擊圖片時的檔名
    var fileName = ""
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let aImage = UIImage(named: fileName){
            imageView.image = aImage
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
