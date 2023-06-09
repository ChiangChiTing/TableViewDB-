//
//  DetailViewController.swift
//  TableViewDB
//
//  Created by RyanChiang on 2023/5/10.
//

import UIKit
import PhotosUI // 使用PHPickerViewController需引用此框架
import MapKit // 使用地圖框架

class DetailViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    @IBOutlet weak var lblNo: UILabel!
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
    var currentIndex = 0
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
    
    
    // 打電話按鈕
    @IBAction func buttonPhoneCall(_ sender: UIButton){
        // 確保有電話資料
        if let phoneNumber = txtPhone.text{
            // 將電話號碼製成網址物件
            if let url = URL(string: "tel://" + phoneNumber){
                // 由應用程式實體執行電話號碼網址的呼叫(撥打電話)
                UIApplication.shared.open(url)
            }
                
        }
        
 
    }
    // 導航按鈕
    @IBAction func buttonNavi(_ sender: UIButton){
        // 初始化地理資訊解碼器
        let geoCoder = CLGeocoder()
        // 以地理資訊解碼器將地址轉成緯經度資訊
        geoCoder.geocodeAddressString(txtAddress.text!) {
            placemarks, error
            in
            if error == nil{ // 地址解碼成功時
                if placemarks != nil { // 有取得位置資訊時
                    // 取得地址所對應的緯經度位置資訊(CLPlacemark的實體)
                    if let toPlacemark = placemarks?.first{
                        // 將緯經度位置資訊轉換成導航地圖上的目的地大頭針
                        let toPin = MKPlacemark(placemark: toPlacemark)
                        // 設定導航模式的選項(字典的value預設為開車模式)
//                        let naviOption = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        // 產生導航地圖上導航終點的大頭針
                        let destMapItem = MKMapItem(placemark: toPin)
                        // 從現在位置導航到目的地
//                        destMapItem.openInMaps(launchOptions: naviOption)
                        destMapItem.openInMaps()
                    }

                }
            } else {
                print("地址解碼失敗")
            }
        }
        
 
        
        
    }
    // 修改資料按鈕
    @IBAction func buttonUpdate(_ sender: UIButton){
        
        // Step1.更新資料庫資料
        
        // Step2.更新上一頁的當筆離線資料集
        if !myTableViewController.isSearching{
            // 修改原陣列的當筆資料
            myTableViewController.arrTable[currentIndex] = Student(no: lblNo.text!, name: txtName.text!, gender: pkvGender.selectedRow(inComponent: 0), picture: imgPicture.image!.jpegData(compressionQuality: 0.7), phone: txtPhone.text!, address: txtAddress.text!, email: txtEmail.text!, myclass: txtMyclass.text!)
        } else {
            // 修改篩選陣列的當筆資料
            myTableViewController.searchResult[currentIndex] = Student(no: lblNo.text!, name: txtName.text!, gender: pkvGender.selectedRow(inComponent: 0), picture: imgPicture.image!.jpegData(compressionQuality: 0.7), phone: txtPhone.text!, address: txtAddress.text!, email: txtEmail.text!, myclass: txtMyclass.text!)
        }
        // Step3.直接更新上一頁的表格資料
        myTableViewController.tableView.reloadData()
        
        // Step4.通知使用者資料更新成功
        // 產生提示視窗
        let alert = UIAlertController(title: "資料處理", message: "資料更新成功", preferredStyle: .alert)
        // 產生提示視窗內使用的按鈕
        let okAction = UIAlertAction(title: "確定", style: .default)
        // 在提示視窗中加入按鈕
        alert.addAction(okAction)
        // 顯示提示視窗
        self.present(alert, animated: true)
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
        
        
        // 從上一頁取得當筆點選的資料
        if !myTableViewController.isSearching{ // 若上一頁非搜尋中
            // 從原陣列調出當筆資料
            currentData = myTableViewController.arrTable[self.currentIndex]
        } else {
            // 從篩選陣列調出當筆資料
            currentData = myTableViewController.searchResult[self.currentIndex]
        }
        
        
        
        currentData = myTableViewController.arrTable[self.currentIndex]
        // 逐一顯示各種欄位資料
        lblNo.text = currentData.no
        txtName.text = currentData.name
        
        if currentData.gender == 0 {
            txtGender.text = "女"
        } else {
            txtGender.text = "男"
        }
        
        if let aPicData = currentData.picture{
            imgPicture.image = UIImage(data: aPicData)
        }
        
        txtPhone.text = currentData.phone
        txtAddress.text = currentData.address
        txtEmail.text = currentData.email
        txtMyclass.text = currentData.myclass
        
        // 準備性別的滾輪
        pkvGender = UIPickerView()
        pkvGender.tag = 2
        // 性別滾輪指定代理人和資料來源實作在此類別
        pkvGender.delegate = self
        pkvGender.dataSource = self
        // 以性別滾輪替換性別的輸入鍵盤
        txtGender.inputView = pkvGender
        // 選定目前對應性別的滾輪位置
        pkvGender.selectRow(currentData.gender, inComponent: 0, animated: false)
        
        
        // 準備班別的滾輪
        pkvMyclass = UIPickerView()
        pkvMyclass.tag = 7
        // 班別滾輪指定代理人和資料來源實作在此類別
        pkvMyclass.delegate = self
        pkvMyclass.dataSource = self
        // 以班別滾輪替換性別的輸入鍵盤
        txtMyclass.inputView = pkvMyclass
        // 班別陣列每個元素換成Tuple以方便比對班別是否符合
        for (index, item) in arrMyclass.enumerated(){
            // 當陣列的值與當筆的班別符合時
            if item == txtMyclass.text!{
                // 以陣列的索引值來選定目前對應性別的滾輪位置
                pkvMyclass.selectRow(index, inComponent: 0, animated: false)
                break // 直接離開迴圈
            }
        }
       
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        print("detail VC 畫面出現")
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
