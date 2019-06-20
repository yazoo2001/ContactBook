//
//  RegisterPageViewController.swift
//  ContactBook
//
//  Created by 菅崎康夫 on 2019/06/15.
//  Copyright © 2019 HARVEST,Y.K. All rights reserved.
//

import UIKit

struct MstChild: Codable {
    var id: String
    var classid: String
    var name: String
    var nickname: String
}

class RegisterPageViewController: UIViewController {

    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextFIeld: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        let userID = userIDTextField.text;
        let userPassword = userPasswordTextField.text;
        let userRepeatPassword = repeatPasswordTextFIeld.text;
        
        // 未入力chk
        if(userID == "" || userPassword == "" || userRepeatPassword == ""){

            // Display alert message
            displayMyAlertMessage(userMessage: "全ての項目に入力してください")
            return;
        }
        
        // パスワード一致chk
        if (userPassword != userRepeatPassword){
            // Display alert message
            displayMyAlertMessage(userMessage: "パスワードが一致していません")
            return;
        }

        // データ保存
        UserDefaults.standard.set(userID, forKey:"userID")
        UserDefaults.standard.set(userPassword, forKey:"userPassword")

        // マスタからID情報をselectし、jsonで出力
        selectDB(selectUserID:userID!)
        getNickname(selectUserID:userID!)
        
        // Display alert message with confirmation
        let myAlert = UIAlertController(title:"Alert", message: "登録しました", preferredStyle:  UIAlertController.Style.alert)
        let okAction = UIAlertAction(title:"OK", style: UIAlertAction.Style.default){
            action in self.dismiss(animated: true, completion:nil)
        }
        myAlert.addAction(okAction)
        self.present(myAlert, animated:true,completion:nil)
        
    }
    
    func displayMyAlertMessage(userMessage: String){
        
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle:  UIAlertController.Style.alert)
        let okAction = UIAlertAction(title:"OK", style: UIAlertAction.Style.default, handler:nil)
        myAlert.addAction(okAction);
        self.present(myAlert,animated:true, completion:nil)
        
    }
    //DBからselectするファンクション
    func selectDB(selectUserID:String) {
        
        //creating the post parameter by concatenating the keys and values from text field
        let postString = "id="+selectUserID;
        print(postString)
        
        var request = URLRequest(url: URL(string: "http://mothers-fukui.com/api/mstletter.php")!)
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
    
    // mst.jsonからマスタデータを取得＆Userdefaultsに保存
    func getNickname(selectUserID:String) {
        let urlStr = "http://mothers-fukui.com/api/" + selectUserID + "/mst.json"
        if let url = URL(string: urlStr) {
            let req = NSMutableURLRequest(url: url)
            req.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: req as URLRequest, completionHandler: {(data, resp, err) in
                // 受け取ったdataをJSONパース、エラーならcatchへジャンプ
                do {
                    let jsonData: [MstChild] = try JSONDecoder().decode([MstChild].self, from: data!)
                    // ニックネームをuserdefaultに保存
                    UserDefaults.standard.set(jsonData[0].nickname, forKey:"userNickname")
                    print("保存"+jsonData[0].nickname)
                } catch {
                    print ("json error")
                    return
                }
            })
            task.resume()
        }
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
