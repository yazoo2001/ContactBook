//
//  ViewController.swift
//  ContactBook（連絡帳アプリ）
//
//  Created by Yasuo Kanzaki on 2019/06/15.
//  Copyright © 2019 HARVEST,Y.K. All rights reserved.
//
// userdefaultのIDに保存されているコードでデータ検索ができない場合、
// 「無効なIDです」と表示する

import UIKit

struct CaseTbl: Codable {
    var id: String
    var ymd: String
    var text: String
    var letter: String?
    var reply:String? // nullの場合がある or キーがない場合がある
}

class ViewController: UIViewController {

    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var mothersTextView: UITextView!
    @IBOutlet weak var userTextView: UITextView!
    @IBOutlet weak var mothersReplyTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // datepickerで未来日付を選択できないように設定
        datePicker.maximumDate = Date()
        // この画面がs表示されたタイミングでDBをidで検索し、
        // 現時点で登録済みの全ケース記録データをcasetbl.jsonに出力しとく。
        // php処理（select結果をjsonで出力）
        selectDB(selectUserId:UserDefaults.standard.string(forKey: "userID")!)
        mothersTextView.text = ""
        userTextView.text = ""
        mothersReplyTextView.text = ""
        userNicknameLabel.text = UserDefaults.standard.string(forKey: "userNickname")
        displayCaseData(dirUserID: UserDefaults.standard.string(forKey: "userID")!, datePickerDate: datePicker.date)
    }
    
    /// 画面再表示（別IDでログインして戻ってきた時のために再表示＆再selectする）
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        if(!isUserLoggedIn)
        {
            self.performSegue (withIdentifier: "loginView", sender: self)
        }
    }

    // datePickerの値が変更されたら呼ばれる
    @IBAction func datePicker(_ sender: Any) {
        // TextView clear
        mothersTextView.text = ""
        userTextView.text = ""
        mothersReplyTextView.text = ""
        displayCaseData(dirUserID: UserDefaults.standard.string(forKey: "userID")!, datePickerDate: datePicker.date)
    }
    
    // 登録ボタン
    @IBAction func recordButtonTapped(_ sender: Any) {
        
        let updateUserText = userTextView.text
        
        if updateUserText == ""{
            displayMyAlertMessage(userMessage: "連絡帳への返信が未入力です")
            return;
        }else{
            // 日付のフォーマット
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            let updateYMD = formatter.string(from: datePicker.date)
            // php処理（select結果をjsonで出力）
            updateDB(userCaseYMD:updateYMD,userCaseLetter:updateUserText!)
            displayMyAlertMessage(userMessage: "マザーズへの連絡を登録しました")
            print("登録完了");
            
            
            // php処理（DBへの変更が入ったらselect結果をjsonで再出力）
            selectDB(selectUserId:UserDefaults.standard.string(forKey: "userID")!)
        }
    }
    // ログアウトボタン
    @IBAction func loggoutButtonTapped(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        //UserDefaults.standard.synchronize()
        self.performSegue(withIdentifier: "loginView", sender: self)
        
    }

    //DBからselectするファンクション
    func selectDB(selectUserId:String) {
        //creating the post parameter by concatenating the keys and values from text field
        let postString = "id="+selectUserId;
        print(postString)
        
        var request = URLRequest(url: URL(string: "http://mothers-fukui.com/api/selectletter.php")!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                return
            }
            
            //print("response: \(response!)")
            //print(String(data: data!, encoding: .utf8)!)
            
        })
        
        task.resume()
    }
    
    //MySQLデータベースに登録するファンクション
    func updateDB(userCaseYMD:String,userCaseLetter:String) {
        
        let UserID = UserDefaults.standard.string(forKey: "userID")
        //creating the post parameter by concatenating the keys and values from text field
        let postString = "id="+UserID!+"&ymd="+userCaseYMD+"&text="+userCaseLetter;
        print(postString)
        
        var request = URLRequest(url: URL(string: "http://mothers-fukui.com/api/updateletter.php")!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                return
            }
            
            print("response: \(response!)")
            print(String(data: data!, encoding: .utf8)!)
        })
        task.resume()
    }
    // キーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    func displayMyAlertMessage(userMessage: String){
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle:  UIAlertController.Style.alert)
        let okAction = UIAlertAction(title:"OK", style: UIAlertAction.Style.default, handler:nil)
        myAlert.addAction(okAction);
        self.present(myAlert,animated:true, completion:nil)
        
    }
    
    func setJsonDataToTextField(jsonText: String,jsonLetter:String,jsonReply:String){
        DispatchQueue.main.async {
            self.mothersTextView.text = jsonText
            self.userTextView.text = jsonLetter
            self.mothersReplyTextView.text = jsonReply
        }
    }
    
    // 作成されたjsonデータを表示する
    func displayCaseData(dirUserID:String,datePickerDate:Date){
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let selectedDate = formatter.string(from: datePickerDate)
        
        // casetbl.jsonから連絡帳データを取得＆表示
        let urlStr = "http://mothers-fukui.com/api/" + dirUserID + "/casetbl.json"
        if let url = URL(string: urlStr) {
            let req = NSMutableURLRequest(url: url)
            req.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: req as URLRequest, completionHandler: {(data, resp, err) in
                // 受け取ったdataをJSONパース、エラーならcatchへジャンプ
                do {
                    let jsonData: [CaseTbl] = try JSONDecoder().decode([CaseTbl].self, from: data!)
                    //print(jsonData)
                    Array(0..<jsonData.count).forEach {
                        if jsonData[$0].ymd == selectedDate{
                            
                            self.setJsonDataToTextField(jsonText:jsonData[$0].text,jsonLetter:jsonData[$0].letter ?? "",jsonReply:jsonData[$0].reply ?? "")
                            
                        }
                    }
                } catch {
                    print ("json error")
                    return
                }
            })
            task.resume()
        }
    }
    
    
}
