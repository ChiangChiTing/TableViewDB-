//
//  AddViewController.swift
//  TableViewDB
//
//  Created by RyanChiang on 2023/6/1.
//

import UIKit
import PhotosUI // 使用PHPickerViewController需引用此框架

class AddViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var txtNo: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtMyclass: UITextField!
    
    
    
    // 接收上一頁的執行實體
    weak var myTableViewController:MyTableViewController!
    // 記錄目前處理中離線資料集的索引值
//    var currentIndex = 0
    // 記錄目前處理中的學生資料
    var currentData = Student()
    // 性別滾輪
    var pkvGender:UIPickerView!
    // 班別滾輪
    var pkvMyclass:UIPickerView!
    // 提供性別滾輪的資料來源
    let arrGender = ["女","男"]
    // 提供班別滾輪的資料來源
    let arrMyclass = ["手機程式設計","網頁程式設計","智能裝置開發"]
    // 記錄目前輸入元件的Y軸底緣位置
    var currentObjectBottomYPosition:CGFloat = 0
    
    
    // MARK: - Target Action
    // 虛擬鍵盤彈出的觸發事件
    @objc func keyboardWillShow(notification: Notification){
//        print("虛擬鍵盤彈出：\(notification.userInfo)")
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                 as? NSValue)?.cgRectValue.size.height {
            print("鍵盤高度：\(keyboardHeight)")
            // 計算扣除鍵盤遮擋範圍之後的可視高度
            let visibleHeight = self.view.bounds.height - keyboardHeight
            // 若可視高度小於輸入元件的Y軸底緣位置，表示輸入元件被遮擋
            if visibleHeight < currentObjectBottomYPosition{
                // 處理被遮擋部分的上移(Y軸往上調整Y軸底緣位置與可視高度的差值)
                self.view.frame.origin.y = -(currentObjectBottomYPosition - visibleHeight)
            }
        }
    }
    
    // 虛擬鍵盤收合的觸發事件
    @objc func keyboardWillHide(){
        print("虛擬鍵盤收合")
        // 移回原點
        self.view.frame.origin.y = 0
    }
    
    
    
    // 按下虛擬鍵盤的return鍵時
    @IBAction func didEndOnExit(_ sender: UITextField) {
        // 無需執行任何程式碼即可收起虛擬鍵盤
    }
    
    // 文字輸入框的開始編輯事件
    @IBAction func editingDidBegin(_ sender: UITextField) {
        // 移回原點(避免鍵盤被遮擋時畫面不斷上移)
        self.view.frame.origin.y = 0
        
        switch sender.tag{
            case 4: // 電話
                sender.keyboardType = .phonePad
            case 6: // Email
                sender.keyboardType = .emailAddress
            default:
                sender.keyboardType = .default
        }
        // 計算目前輸入框的Y軸底緣位置
        currentObjectBottomYPosition = sender.frame.origin.y + sender.frame.size.height
        
    }
    
    // 底面點擊事件
    @IBAction func viewClick(_ sender: UITapGestureRecognizer) {
        // <方法一>
//        txtName.resignFirstResponder()
//        txtGender.resignFirstResponder()
//        txtPhone.resignFirstResponder()
//        txtAddress.resignFirstResponder()
//        txtEmail.resignFirstResponder()
//        txtMyclass.resignFirstResponder()
        
        // <方法二>
//        for aView in self.view.subviews{
//            if aView is UITextField{
//                aView.resignFirstResponder()
//            }
//        }
//
        // <方法三>
        self.view.endEditing(true)
    }
    
    
    
    
    // 相簿按鈕
    @IBAction func buttonPhoto(_ sender: UIButton){
        // 初始化相簿相關的設定
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = PHPickerFilter.images
        config.preferredAssetRepresentationMode = .current
        config.selection = .ordered
        // 設定可以多選照片(0不限張數，1為一張，預設為1)
//        config.selectionLimit = 1
        // 使用以上設定來初始化照片挑選控制器
        let photoPicker = PHPickerViewController(configuration: config)
        photoPicker.delegate = self
        
        // 顯示相簿畫面
        self.show(photoPicker, sender: nil)
    }
    // 相機按鈕
    @IBAction func buttonCamera(_ sender: UIButton){
        
        // 檢查後置相機是否存在
        if !UIImagePickerController.isCameraDeviceAvailable(.rear){
            print("此設備沒有後置相機")
            return
        } else {
            print("此設備有後製相機")
        }
        
        // 宣告影像挑選控制器(目前版本建議只給相機使用，不要給相簿使用)
        let imagePicker = UIImagePickerController()
        // 初始化影像挑選控制器(目前只能給相機使用)
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        
        // 顯示相機畫面
        self.show(imagePicker, sender: nil)
    }
    
    // 新增資料按鈕
    @IBAction func buttonInsert(_ sender: UIButton) {
        
        if txtNo.text! != "" && txtName.text! != "" && txtGender.text! != "" && imgPicture.image != nil && txtPhone.text! != "" && txtAddress.text! != "" && txtEmail.text! != "" && txtMyclass.text! != ""{
            
            // Step1.新增資料庫資料
            //
            
            // Step2.更新離線資料集
            myTableViewController.arrTable.append(Student(no: txtNo.text!, name: txtName.text!, gender: pkvGender.selectedRow(inComponent: 0), picture: imgPicture.image!.jpegData(compressionQuality: 0.7), phone: txtPhone.text!, address: txtAddress.text!, email: txtEmail.text!, myclass: txtMyclass.text!))
            
            //Step2_1.依學號順序排序原陣列資料
            myTableViewController.arrTable.sort {
                student1, student2
                in
                return student1.no < student2.no
            }
            
            // Step3.重整上一頁表格資料
            myTableViewController.tableView.reloadData()
            // Step4.通知使用者資料新增成功
            // 產生提示視窗
            let alert = UIAlertController(title: "資料處理", message: "資料新增成功", preferredStyle: .alert)
            // 產生提示視窗內使用的按鈕
            let okAction = UIAlertAction(title: "確定", style: .default)
            // 在提示視窗中加入按鈕
            alert.addAction(okAction)
            // 顯示提示視窗
            self.present(alert, animated: true)
            
        } else {
            // 產生提示視窗
            let alert = UIAlertController(title: "資料處理", message: "資料輸入不完整", preferredStyle: .alert)
            // 產生提示視窗內使用的按鈕
            let okAction = UIAlertAction(title: "確定", style: .default)
            // 在提示視窗中加入按鈕
            alert.addAction(okAction)
            // 顯示提示視窗
            self.present(alert, animated: true)
            
        }
        
        
        
        
    }
    
    
    
    
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 指定文字輸入框的代理人實作在此類別
        // 收起虛擬鍵盤
//        txtName.delegate = self
//        txtGender.delegate = self
//        txtPhone.delegate = self
//        txtAddress.delegate = self
//        txtEmail.delegate = self
//        txtMyclass.delegate = self
        
        // 從型別屬性取得App通知中心的實體
        let notificationCenter = NotificationCenter.default
        // 註冊虛擬鍵盤的彈出通知
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name:  UIResponder.keyboardWillShowNotification, object: nil)
        // 註冊虛擬鍵盤的收合通知
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       
        
        // 準備性別的滾輪
        pkvGender = UIPickerView()
        pkvGender.tag = 2
        // 性別滾輪指定代理人和資料來源實作在此類別
        pkvGender.delegate = self
        pkvGender.dataSource = self
        // 以性別滾輪替換性別的輸入鍵盤
        txtGender.inputView = pkvGender
        
        
        
        // 準備班別的滾輪
        pkvMyclass = UIPickerView()
        pkvMyclass.tag = 7
        // 班別滾輪指定代理人和資料來源實作在此類別
        pkvMyclass.delegate = self
        pkvMyclass.dataSource = self
        // 以班別滾輪替換性別的輸入鍵盤
        txtMyclass.inputView = pkvMyclass
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        print("add VC 畫面出現")
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - UITextFieldDelegate
    // 按下虛擬鍵盤的return鍵時
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 交出第一回應權就會收起鍵盤
        textField.resignFirstResponder()
//        textField.becomeFirstResponder()
    }
    
    // MARK: - UIPickerViewDataSource
    // 滾輪有幾段
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // 每一段滾輪有幾項資料
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag{
            case 2: // 性別
                return arrGender.count
            case 7: // 班別
                return arrMyclass.count
            default:
                return 1
        }
    
    }
    
    // MARK: - UIPickerViewDelegate
    // 回傳滾輪每一個位置的顯示文字
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag{
            case 2: // 性別
                return arrGender[row]
            case 7: // 班別
                return arrMyclass[row]
            default:
                return "??"
        }
    }
    
    // 滾輪滾動到特定位置時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag{
            case 2: // 性別
                txtGender.text = arrGender[row]
            case 7: // 班別
                txtMyclass.text = arrMyclass[row]
            default:
                break
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    // 當相機完成拍照時
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("拍照：\(info)")
        // 取得照片並顯示
        if let image = info[.originalImage] as? UIImage{
            imgPicture.image = image
        }
        // 退掉相機畫面
        picker.dismiss(animated: true)
//        self.navigationController?.popViewController(animated: true) // 此方法失效
    }
    
    // MARK: - PHPickerViewControllerDelegate
    // 當從相簿挑選相片完成時
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print("相簿：\(results)")
        if let itemProvider = results.first?.itemProvider{
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier){
                itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) {
                    imgData, error
                    in
                    guard let photoData = imgData else { return }
                    // 轉回主要執行緒以更新畫面
                    DispatchQueue.main.async {
                        // 顯示選取的照片
                        self.imgPicture.image = UIImage(data: photoData)
                    }
                }
            }
        }
        // 退掉相簿的畫面
        self.navigationController?.popViewController(animated: true)
//        picker.dismiss(animated: true) // 無法退掉相簿
    }

}
