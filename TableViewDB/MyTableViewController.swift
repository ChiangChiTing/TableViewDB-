//
//  ViewController.swift
//  TableViewDB
//
//  Created by RyanChiang on 2023/5/9.
//

import UIKit

// 定義單筆學生資料的結構
struct Student{
    var no = ""
    var name = ""
    var gender = 0
    var picture: Data?
    var phone = ""
    var address = ""
    var email = ""
    var myclass = ""
}


class MyTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchResultsUpdating, UISearchBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonAddNew: UIButton!
    
    @IBOutlet weak var buttonSearch: UIButton!
    
    @IBOutlet weak var buttonEdit: UIButton!
    
//    private let cities = ["台北", "台中", "高雄"]
    // 記錄單筆資料
    var structRow = Student()
    // 宣告學生資料的陣列，存放從資料庫查詢到的資料(離線資料集)
    var arrTable = [Student]()
    
    // 宣告要加入scrollView的imageView的陣列(離線資料集/recordset/dataset)
    var imageViews = [UIImageView]()
    
    // 宣告要執行自動換圖的計時器
    weak var timer:Timer!
    
    // ----------搜尋元件----------
    // 儲存搜尋篩選過後的結果
    var searchResult = [Student]()
    // 宣告搜尋控制器
    var searchController:UISearchController!
    // 記錄用於搜尋表格資料的關鍵欄位(預設以name當作搜尋欄位)
    var filterKey = "name"
    // 預設表格呈現的資料為非搜尋狀態(呈現arrTable的資料而不是searchResult的)
    var isSearching = false
    // 記錄搜尋列元件
    weak var mySearchBar:UISearchBar!
    // ------------------------------
    
    // ScrollView的Y軸Bug修正(記錄安全區域的上方位置)
    var safeAreaTop:CGFloat = 0
    
    
    
    
    
    
    
    
    // MARK: - Target Action
    // 頁面指示器點擊頁面
    @IBAction func pageControllValueChange(_ sender: UIPageControl) {
        // 以目前頁碼調出陣列中錯開的位置，並執行scrollView捲動到對應位置
        scrollView.scrollRectToVisible(imageViews[sender.currentPage].frame, animated: true)
    }
    
    // 下拉更新元件的觸發事件
    @objc func handleRefresh11(){
//        print("下拉更新元件的觸發事件")
        
        // ----------搜尋元件----------
        // 表格搜尋狀態變更為非搜尋中
        isSearching = false
        // ------------------------------
        
        // 設定下拉更新元件的文字
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "更新中...")
        // 從資料庫讀取資料
        // XXXXXXXXXXXXXX
        // 重新執行TableViewDataSource的代理事件，以新資料重新準備表格
        tableView.reloadData()
        // 資料更新完成後將表格恢復原位置
        tableView.refreshControl?.endRefreshing()
    }
    
    
    // 新增按鈕點擊事件
    @IBAction func buttonAddNewClick(_ sender: UIButton) {
//        print("新增按鈕點擊事件")
//        tableView.tableHeaderView = nil
        
        let addVC = self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        
        addVC.myTableViewController = self
        
        // 如果搜尋時按下新增，則取消搜尋
        searchController.isActive = false
        self.isSearching = false
        
        
        
        self.show(addVC, sender: nil)
    }
    
    // 搜尋按鈕點擊事件
    @IBAction func buttonSearchClick(_ sender: UIButton) {
        if tableView.tableHeaderView == nil{
            tableView.tableHeaderView = mySearchBar
        } else {
            tableView.tableHeaderView = nil
        }
    }
    
    // 編輯按鈕點擊事件
    @IBAction func buttonEditClick(_ sender: UIButton) {
        // 表格非編輯中時
        if !tableView.isEditing{
            // 讓表格進入編輯狀態
            tableView.isEditing = true
//            sender.titleLabel?.text = "test111"
            // 更改按鈕文字
//            let stringDone = NSLocalizedString("buttonDone", comment: "")
            // Step1.從語系檔取得對應的語系文字
            let stringDone = NSLocalizedString("buttonDone", tableName: "InfoPlist", bundle: Bundle.main, value: "", comment: "")
        
//            sender.setTitle(stringDone, for: .normal)
            // Step2.製作帶屬性的文字
            let font = UIFont.systemFont(ofSize: 20)
            let attributes = [NSAttributedString.Key.font: font]
            let attributedQuote = NSAttributedString(string: stringDone, attributes: attributes)
            // Step3.將帶屬性的文字設定給按鈕
            sender.setAttributedTitle(attributedQuote, for: .normal)
        } else { // 表格在編輯中時
            // 讓表格結束編輯狀態
            tableView.isEditing = false
            // 更改按鈕文字
//            let stringEdit = NSLocalizedString("buttonEdit", comment: "")
            // Step1.從語系檔取得對應的語系文字
            let stringEdit = NSLocalizedString("buttonEdit", tableName: "InfoPlist", bundle: Bundle.main, value: "", comment: "")
            
//            sender.setTitle(stringEdit, for: .normal)
            // Step2.製作帶屬性的文字
            let font = UIFont.systemFont(ofSize: 20)
            let attributes = [NSAttributedString.Key.font: font]
            let attributedQuote = NSAttributedString(string: stringEdit, attributes: attributes)
            // Step3.將帶屬性的文字設定給按鈕
            sender.setAttributedTitle(attributedQuote, for: .normal)
        }
        
    }
    
    // 由ScrollView上的單張圖片點擊時呼叫
    @objc func showItemVC(_ sender:UITapGestureRecognizer){
//        print("圖片點擊")
        if let itemVC = self.storyboard?.instantiateViewController(withIdentifier: "ItemViewController") as? ItemViewController{
            itemVC.fileName = String(format: "%02d", pageControl.currentPage + 1)
            self.show(itemVC, sender: nil)
        }
            
    }
    
    
    
    
    

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化下拉更新元件
        let refreshControl = UIRefreshControl()
        // 綁定下拉更新元件的觸發事件
        refreshControl.addTarget(self, action: #selector(handleRefresh11), for: .valueChanged)
        // 將製作好的下拉更新元件設定給表格
        tableView.refreshControl = refreshControl
        
        let pic = UIImage(named: "Pikachu")?.jpegData(compressionQuality: 0.8)
        // 準備離線資料集
        arrTable = [
            Student(no: "S199", name: "王柏融", gender: 1, picture: pic, phone: "199199199", address: "桃園市中壢區環中東路561號", email: "tama@ham.com", myclass: "打擊練習班"),
            Student(no: "S299", name: "餓久久", gender: 0, picture: pic, phone: "299299299", address: "桃園市中壢區環中東路561號", email: "299@ham.com", myclass: "打飯練習班"),
            Student(no: "S557", name: "伍五七", gender: 0, picture: pic, phone: "557557557", address: "桃園市中壢區環中東路561號", email: "ccn@ham.com", myclass: "打擊練習班"),
            Student(no: "S666", name: "陸六六", gender: 1, picture: pic, phone: "666666666", address: "桃園市中壢區環中東路561號", email: "six3@ham.com", myclass: "打擊練習班"),
            Student(no: "S777", name: "七妹", gender: 0, picture: pic, phone: "777777777", address: "桃園市中壢區環中東路561號", email: "seven3@ham.com", myclass: "打擊練習班"),
            Student(no: "S888", name: "八哥", gender: 1, picture: pic, phone: "888888888", address: "桃園市中壢區環中東路561號", email: "888@ham.com", myclass: "打擊練習班"),

        ]
        
//        arrTable = [
//            Student(no: "S101", name: "王大富", gender: 1, picture: UIImage(named: "default")?.jpegData(compressionQuality: 0.8), phone: "0912345678", address: "台中市文心路一段120號", email: "abc@xyz.com", myclass: "手機程式設計"),
//            Student(no: "S102", name: "李小英", gender: 0, picture: UIImage(named: "default")?.jpegData(compressionQuality: 0.8), phone: "0912345678", address: "宜蘭縣礁溪鄉健康路77號", email: "abc@xyz.com", myclass: "網頁程式設計"),
//            Student(no: "S103", name: "吳天勝", gender: 1, picture: UIImage(named: "default")?.jpegData(compressionQuality: 0.8), phone: "0912345678", address: "宜蘭縣礁溪鄉健康路77號", email: "abc@xyz.com", myclass: "智能裝置開發"),
//            Student(no: "S104", name: "邱大同", gender: 1, picture: UIImage(named: "default")?.jpegData(compressionQuality: 0.8), phone: "0912345678", address: "台中市文心路一段120號", email: "abc@xyz.com", myclass: "手機程式設計"),
//            Student(no: "S105", name: "田麗莉", gender: 0, picture: UIImage(named: "default")?.jpegData(compressionQuality: 0.8), phone: "0912345678", address: "宜蘭縣礁溪鄉健康路77號", email: "abc@xyz.com", myclass: "網頁程式設計"),
//            Student(no: "S106", name: "康為仁", gender: 1, picture: UIImage(named: "default")?.jpegData(compressionQuality: 0.8), phone: "0912345678", address: "宜蘭縣礁溪鄉健康路77號", email: "abc@xyz.com", myclass: "智能裝置開發"),
//        ]
        
        
        
        // 隱藏導覽列
        self.navigationController?.navigationBar.isHidden = true
        
        // 指定TableView相關的代理事件實作在此類別
        tableView.dataSource = self
        tableView.delegate = self
        
        // 讓scrollView可以用切換頁面的方式捲動
        scrollView.isPagingEnabled = true
        // scrollView的代理方法實作在此類別
        scrollView.delegate = self
        
        for i in 1...10{
            // 準備每一張圖片的檔名
            let fileName = String(format: "%02d", i)
//            print("檔名：\(fileName)")
            // 以檔名產生imageView
            let imageView = UIImageView(image: UIImage(named: fileName))
            // 將imageView加入陣列
            imageViews.append(imageView)
        }
        // 設定pageControl的寬度與螢幕一致
//        pageControl.bounds.size.width = self.view.bounds.width
        
        pageControl.bounds.size.width = self.view.bounds.size.width
        // 設定pageControl的總頁數
        pageControl.numberOfPages = imageViews.count
        // 設定pageControl的目前頁數
        pageControl.currentPage = 0

        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: {
//            [unowned self]
            timer
            in
            // Step1:決定下一頁的頁碼
            // 如果現在不是最後一頁
            if self.pageControl.currentPage != self.pageControl.numberOfPages - 1{
                self.pageControl.currentPage += 1 // 將頁碼加1
            } else {
                // 如果現在是最後一頁
                self.pageControl.currentPage = 0 // 將頁碼調回第一頁
            }
            // Step2:找到下一張圖片所在位置
            let currentRect = self.imageViews[self.pageControl.currentPage].frame
            // Step3:將scrollView捲動到下一張圖片所在位置
            self.scrollView.scrollRectToVisible(currentRect, animated: true)
        })
        
        // ----------搜尋元件----------
        // 初始化搜尋控制器
        searchController = UISearchController()
        // 指定搜尋結果更新的相關代理事件實作在此類別
        searchController.searchResultsUpdater = self
        // 設定搜尋時背景不要變暗(預設值為true)
        searchController.obscuresBackgroundDuringPresentation = false
        // 指定搜尋列相關代理事件實作在此類別
        searchController.searchBar.delegate = self
        // 設定搜尋列上顯示搜尋的關鍵欄位
        searchController.searchBar.scopeButtonTitles = ["學號", "姓名", "性別"]
//        // 讓搜尋列的關鍵欄位預設在姓名的搜尋按鈕上
//        searchController.searchBar.selectedScopeButtonIndex = 1
        
        // 讓搜尋列的關鍵欄位預設在學號的搜尋按鈕上
        searchController.searchBar.selectedScopeButtonIndex = 0
        
        // 在畫面上加入搜尋列(須在viewDidLayoutSubviews調整顯示位置)
        mySearchBar = searchController.searchBar
//        self.view.addSubview(searchBar)
        // --------------------
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("畫面即將重現")
        self.navigationController?.navigationBar.isHidden = true
//        self.navigationController?.isNavigationBarHidden = true
    }

    
    // 畫面即將完成定位時
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // ScrollView的Y軸Bug修正(記錄安全區域的上方位置)
        safeAreaTop = view.safeAreaLayoutGuide.layoutFrame.origin.y

        
        
        // 即將完成定位時，此scrollView的contentSize若不歸零，會造成scrollView內部的imageView位置錯亂
        scrollView.contentSize = CGSize.zero
        // 取得目前設備
        let myDevice = UIDevice.current
        // 根據目前設備調整ScrollView佔用的比例(40為搜尋列預留的高度)
        switch myDevice.userInterfaceIdiom{
            case .pad:
//                print("iPad")
//                print(myDevice.orientation)
            
                // ScrollView的Y軸Bug修正(iPad所有機型，不論橫向或直向都不能放在安全區之外)
//            因為沒有瀏海所以ScrollView放在安全區域之外不會有Bug，因此安全區域歸零)
                safeAreaTop = 0
            
                switch myDevice.orientation{
                    case .portrait, .portraitUpsideDown:
//                        tableTopConstraint.constant = self.view.bounds.height / 4 + 40
                        tableTopConstraint.constant = self.view.bounds.height / 4 + 40 + safeAreaTop
                    case .landscapeLeft, .landscapeRight:
//                        tableTopConstraint.constant = self.view.bounds.height / 5 + 40
                        tableTopConstraint.constant = self.view.bounds.height / 5 + 40 + safeAreaTop
                    default:
//                        tableTopConstraint.constant = self.view.bounds.height / 4 + 40
                        tableTopConstraint.constant = self.view.bounds.height / 5 + 40 + safeAreaTop
            }
            case .phone:
//                print("iPhone")
//                print(myDevice.orientation)
            
                // ScrollView的Y軸Bug修正(iPhone直立時，ScrollView須在安全區域之內，才可避免圖片上下篇移的問題(只有在主動翻頁時出現，timer正常))
                switch myDevice.orientation{
                    case .portrait, .portraitUpsideDown:
//                        tableTopConstraint.constant = self.view.bounds.height / 3 + 40
                        tableTopConstraint.constant = self.view.bounds.height / 3 + 40 + safeAreaTop
                    case .landscapeLeft, .landscapeRight:
                    
                        safeAreaTop = 0 // ScrollView的Y軸Bug修正(iPhone橫向時，可以擺放在安全區域之外)
                    
//                        tableTopConstraint.constant = self.view.bounds.height / 4 + 40
                        tableTopConstraint.constant = self.view.bounds.height / 4 + 40 + safeAreaTop
                    default:
//                        tableTopConstraint.constant = self.view.bounds.height / 3 + 40
                        tableTopConstraint.constant = self.view.bounds.height / 3 + 40 + safeAreaTop

            }
            default:
//                print("???")
                break
        }
    }
    
    // 畫面已經完成定位時
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 設定pageControl的寬度與螢幕一致
//        pageControl.bounds.size.width = self.view.bounds.width
        
        pageControl.bounds.size.width = self.view.bounds.size.width
        
        // ScrollView的Y軸Bug修正(記錄安全區域的上方位置)
        
        
        
        
        
        
        
        // 將scrollView放置在螢幕的上半部
        // tableTopConstraint.constant會隨著不同裝置(手機或平板)及擺放而變動
//        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: tableTopConstraint.constant - 40)
        
        // ScrollView的Y軸Bug修正(計算scrollView位置時，須考慮安全區域或不考慮安全區域，不考慮安全區域時，其值為0)
        scrollView.frame = CGRect(x: 0, y: safeAreaTop, width: self.view.bounds.size.width,
                                  height: tableTopConstraint.constant - 40 - safeAreaTop)
        
        // 將pageControl放置在scrollView的正下方
        pageControl.frame = CGRect(x: self.view.bounds.size.width/2 - pageControl.bounds.width/2, y: scrollView.bounds.height + 20, width: pageControl.bounds.size.width, height: pageControl.bounds.size.height)
        // 取得定位完成後的scrollView總和大小(CGRect)
        let rectScrollView = scrollView.bounds
        // 記錄所有imageView錯開位置之後的總寬度
        var totalImageViewSize = CGSize(width: 0, height: rectScrollView.height)
        // 記錄目前迴圈處理錯位的過程中，左側圖片的實體
        var leftImageView:UIImageView?
        
        for imageView in imageViews {
            // 調整每張圖片的縮放模式
            imageView.contentMode = .scaleAspectFill
            // 如果是第一張圖片時
            if leftImageView == nil{
                // 將scrollView的位置設定給第一張圖片
                imageView.frame = rectScrollView
            } else {
                // 第二張以後的圖片，需錯開上一張圖片的位置
                // <方法一>錯開上一張圖片的位置
                // ScrollView的Y軸Bug修正(y不可為0)
//                imageView.frame = CGRect(x: leftImageView!.frame.origin.x + leftImageView!.frame.width, y: leftImageView!.frame.origin.y, width: rectScrollView.width, height: rectScrollView.height)
                // <方法二>錯開上一張圖片的位置
                imageView.frame = leftImageView!.frame.offsetBy(dx: leftImageView!.frame.size.width, dy: 0)
                
            }
            // 將當次的圖片記錄為上一張圖片，方便下次迴圈參考位置使用
            leftImageView = imageView
            // 累加每一張圖片的寬度
            totalImageViewSize.width += imageView.frame.width
            // 允許圖片與使用者互動(可以感應手勢)
            imageView.isUserInteractionEnabled = true
            // 初始化點擊手勢
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showItemVC(_:)))
            // 在圖片上加入點擊手勢
            imageView.addGestureRecognizer(tapGesture)
            
            
            
            // 將已經錯開位置的圖片加入scrollView
            scrollView.addSubview(imageView)
        }
        
        // 設定scrollView的可捲動範圍為每一張圖片累加後的總寬高
        scrollView.contentSize = totalImageViewSize
//        scrollView.contentSize.width = totalImageViewSize.width
        
        // 設定新增按鈕的位置
        // 將新增按鈕放在scrollView之下，tableView之上
//        buttonAddNew.frame = CGRect(x: 0, y: scrollView.bounds.height, width: buttonAddNew.bounds.width, height: 40)
        // ScrollView的Y軸Bug修正
        buttonAddNew.frame = CGRect(x: 0, y: scrollView.bounds.height + safeAreaTop, width: buttonAddNew.bounds.width, height: 40)
        
//        // 設定搜尋列的位置
//        searchBar.frame = CGRect(x: 0 + buttonAddNew.bounds.width + 20, y: scrollView.bounds.height, width: 150, height: 40)
        
        // 設定搜尋按鈕的位置
//        buttonSearch.frame = CGRect(x: self.view.bounds.width/2 - buttonSearch.bounds.width/2, y: scrollView.bounds.height, width: buttonSearch.bounds.width, height: buttonSearch.bounds.height)
        // ScrollView的Y軸Bug修正
        buttonSearch.frame = CGRect(x: self.view.bounds.width/2 - buttonSearch.bounds.width/2, y: scrollView.bounds.height + safeAreaTop, width: buttonSearch.bounds.width, height: buttonSearch.bounds.height)

        // 設定編輯按鈕的位置
        // 將編輯按鈕放在scrollView之下，tableView之上
//        buttonEdit.frame = CGRect(x: self.view.bounds.width - buttonEdit.bounds.width, y: scrollView.bounds.height, width: buttonEdit.bounds.width, height: 40)
        // ScrollView的Y軸Bug修正
        buttonEdit.frame = CGRect(x: self.view.bounds.width - buttonEdit.bounds.width, y: scrollView.bounds.height + safeAreaTop, width: buttonEdit.bounds.width, height: 40)
        
    }
    
    // 由換頁線換頁時
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        print("由換頁線換頁時")
        // ----------搜尋元件----------
        // 如果即將換頁時，搜尋控制器還在運作
        if searchController.isActive{
            // 則關閉搜尋控制器
            searchController.isActive = false
        }
        // ------------------------------
        if let detailVC = segue.destination as? DetailViewController{
            detailVC.myTableViewController = self
            detailVC.currentIndex = self.tableView.indexPathForSelectedRow!.row
        }
    }
    
    
    // MARK - UITableViewDataSource
    // 表格有幾段
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    // 每一段表格有幾列
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 如果不是正在搜尋，以原資料呈現
        if !isSearching{
            return arrTable.count
        } else {
        // 如果正在搜尋，以篩選過後的資料呈現
            return searchResult.count
        }
    }

    // 準備每一段每一列的儲存格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 取得儲存格轉型成自訂的儲存格類別
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! MyCell
        
        // 如果不是正在搜尋，以原資料呈現
        if !isSearching{
            structRow = arrTable[indexPath.row]
        } else {
        // 如果正在搜尋，以篩選過後的資料呈現
            structRow = searchResult[indexPath.row]
        }
        
        
        
//        // 以預設大頭照顯示
//        cell.imgPicture.image = UIImage(data: arrTable[indexPath.row].picture!)
//        // 顯示學號姓名
//        cell.lblNo.text = arrTable[indexPath.row].no
//        cell.lblName.text = arrTable[indexPath.row].name
//        // 顯示性別
//        if arrTable[indexPath.row].gender == 0{
//            cell.lblGender.text = "女"
//        } else {
//            cell.lblGender.text = "男"
//        }
//        // Configure the cell...
//
//        return cell
        
        // 顯示大頭照
        cell.imgPicture.image = UIImage(data: structRow.picture!)
        // 顯示學號、姓名
        cell.lblNo.text = structRow.no
        cell.lblName.text = structRow.name
        // 顯示性別
        if structRow.gender == 0{
            cell.lblGender.text = "女"
        } else {
            cell.lblGender.text = "男"
        }
        return cell
        
        
        
        
    }
    
    // ======================================================================================
    // ====================(舊版)設定滑動刪除的按鈕====================
    // 提交表格的新增或刪除狀態(一般此處只會用作刪除，此事件第二個參數的列舉為多餘的參數，設計有缺陷)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Step1.先刪除資料庫資料
        // XXXXXXXXXXXXXX
        // Step2.刪除當筆離線資料集
        arrTable.remove(at: indexPath.row)
        // Step3.刪除表格的儲存格(此時會重新確認TableViewDatasource的代理事件，離線資料及必須與表格數量符合)
        tableView.deleteRows(at: [indexPath], with: .automatic)
//        print("刪除後陣列：\(arrTable.count)筆")
    }
    
    // 變更刪除按鈕的預設文字
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    // ======================================================================================
    
    
    
    // MARK: - UITableViewDelegate
    // 儲存格被點選時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("儲存格被點選：\(arrTable[indexPath.row])")
    }
    
    // 回傳每一列儲存格的高度
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200
//    }
    
    
    // (新版)儲存格後端滑動時，準備右側按鈕
    // 此事件會取代commit editingStyle代理事件
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 準備刪除按鈕
        let buttonDelete = UIContextualAction(style: .normal, title: "刪除") {
            [unowned self]action, view, complete
            in
            // Step1.先刪除資料庫資料
            // XXXXXXXXXXXXXX
            // Step2.刪除當筆離線資料集
            self.arrTable.remove(at: indexPath.row)
            // Step3.刪除表格的儲存格(此時會重新確認TableViewDatasource的代理事件，離線資料及必須與表格數量符合)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        buttonDelete.backgroundColor = .systemBlue
        
        // 準備更多按鈕
        let buttonMore = UIContextualAction(style: .destructive, title: "更多") { action, view, complete
            in
            print("更多按鈕被按下")
        }
        // 設定右側按鈕的組合
        let config = UISwipeActionsConfiguration(actions: [buttonDelete, buttonMore])
        
        // 預設儲存格從最尾端滑動至最前方，會觸發第一顆按鈕，如果不希望自動觸發，執行以下設定
        config.performsFirstActionWithFullSwipe = false
        
        // 回傳按鈕組合
        return config
    }
    // ==========儲存格移動的相關代理事件==========
    // 實作以下兩個代理事件之後，當表格進入編輯狀態時，儲存格右側才會有三條線的標示
    // 特定位置的儲存格是否可以移動
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // 所有儲存格都可以移動
        return true
    }
    // 儲存格對調時
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        print("來源位置：\(sourceIndexPath.row)，目的位置：\(destinationIndexPath.row)")
        // Step1.依照表格順序對調離線資料集
        let tmp = arrTable.remove(at: sourceIndexPath.row)
        arrTable.insert(tmp, at: destinationIndexPath.row)
//        print("對調後的陣列：\(arrTable)")
        // Step2.將目前順序回寫到資料庫(必須要有對應記錄順序的欄位)
        
    }
    // ========================================
    
    
    
    // MARK: - UIScrollViewDelegate
    // 畫面發生捲動時
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("畫面發生捲動時的內容偏移量:\(scrollView.contentOffset)")
        // 當第一頁捲過頭時
        if scrollView.contentOffset.x < 0{
            // 將偏移量調回起始位置
            scrollView.contentOffset.x = 0
        }
        // 當最後一頁捲過頭時
        if scrollView.contentOffset.x > scrollView.bounds.width * CGFloat(imageViews.count - 1) {
            // 將偏移量調回剛好在頁數倍率的位置
            scrollView.contentOffset.x = scrollView.bounds.width * CGFloat(imageViews.count - 1)
        }
        // 計算scrollView寬度的倍率，來決定pageControl應該指示在哪一頁
//        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        // 計算是否超過半頁
        let diff = (scrollView.contentOffset.x - scrollView.bounds.width / 2) / scrollView.bounds.width
//        print("計算半翻頁的倍率:\(diff)")
        
        var currentPage = 0
        // 翻動第一頁以後頁數的一半以上
        if diff >= 0{
            currentPage = Int(diff) + 1
        } else if (diff < 0 && diff >= -0.5){ // 翻動沒有超過第一頁的一半
            currentPage = 0
        }
        // 更換頁碼指示器上的頁碼
        pageControl.currentPage = currentPage
    }
    
    // 當scrollView捲動動畫完成時(由timer翻頁時，會觸發此事件)
    // The scroll view calls this method at the end of its implementations of the setContentOffset(_:animated:) and scrollRectToVisible(_:animated:) methods, but only if animations are requested.
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        print("捲動動畫完成時的偏移量:\(scrollView.contentOffset)")
        
//        // 當第一頁捲過頭時
//        if scrollView.contentOffset.x < 0{
//            // 捲動超過scrollView的水平原點x軸時(偏左)
//            scrollView.contentOffset.x = 0
//        }else if scrollView.contentOffset.x > 0{
//            // 直接以scrollView在X軸的當頁倍率，調整X軸最終捲動位置必須剛好落在scrollView的寬度倍率之上
//            scrollView.contentOffset.x = CGFloat(Int(scrollView.contentOffset.x / scrollView.bounds.width)) * scrollView.bounds.width
//        }
//        // 以contentOffset的值配合scrollView寬度，計算前半部超出scrollView顯示範圍的倍率，當作『頁面指示器』的目前頁
//        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        // 當在timer捲動且設備橫向時，第二頁之後的位置會捲動過頭，以scrollView的倍率修正回倍率的位置
        scrollView.contentOffset.x = CGFloat(pageControl.currentPage) * scrollView.bounds.width
    }
    
    // MARK: - UISearchResultsUpdating
    // 搜尋控制器狀態變更時(包括：開始搜尋、每輸入一個文字、按下搜尋分類按鈕、取消搜尋)
    func updateSearchResults(for searchController: UISearchController){
        print("search controller更新搜尋結果")
        print("search bar:\(mySearchBar.frame)")
        print("header frame:\(self.tableView.frame)")
//        searchBar.frame.origin.y = self.tableView.frame.origin.y
        // 搜尋控制器啟動中，且搜尋列有輸入文字時
        if searchController.isActive && mySearchBar.text != nil{
            // 記錄表格正在搜尋中(用以判斷tableView的datasource應該讀取哪ㄧ個陣列呈現資料)
            isSearching = true
            // 進行陣列篩選
            searchResult = arrTable.filter({
                student
                in
                switch filterKey{
                    case "no":
                        return student.no.contains(mySearchBar.text!)
                    case "name":
                        return student.name.contains(mySearchBar.text!)
                    case "gender":
                        // 將搜尋列上的性別文字轉換成0或1
                        var seachingGender = -1
                        if mySearchBar.text! == "男"{
                            seachingGender = 1
                        } else if mySearchBar.text! == "女" {
                            seachingGender = 0
                        } else { // 不是輸入男或女時，使用-1
                            seachingGender = -1
                        }
                        // 性別符合或不符合時回傳
                        if student.gender == seachingGender{
                            return true
                        } else {
                            return false
                        }
                    default:
                        return false
                }
            })
            print("篩選過後：\(searchResult)")
            // 重新載入表格資料
            self.tableView.reloadData()
        }
        
    }
    
    // MARK: - UISearchBarDelegate
    // 點選搜尋列上的分類按鈕
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int){
        print("點選搜尋列按鈕第\(selectedScope)個按鈕")
        // 決定篩選用的欄位
        switch selectedScope{
            case 0:
                filterKey = "no"
            case 1:
                filterKey = "name"
            case 2:
                filterKey = "gender"
            default:
                filterKey = "name"
        }
    }
    // 按下搜尋列上的取消按鈕時
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        // 回復表格的原始資料
        isSearching = false
        self.tableView.tableHeaderView = nil
        self.tableView.reloadData()
    }
}

