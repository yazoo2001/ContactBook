//
//  LoginViewController.swift
//  ContactBook
//
//  Created by 菅崎康夫 on 2019/06/17.
//  Copyright © 2019 HARVEST,Y.K. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {

    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 保存している場合、初期値を出す
        userIDTextField.text = UserDefaults.standard.string(forKey: "userID")
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        let userID = userIDTextField.text;
        let userPassword = userPasswordTextField.text;
        let userIDStored = UserDefaults.standard.string(forKey: "userID")
        let userPasswordStored = UserDefaults.standard.string(forKey: "userPassword")
        if(userIDStored == userID){
            
            if(userPasswordStored == userPassword){
                // ログイン！
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                //UserDefaults.standard.synchronize()
                self.dismiss(animated: true, completion:nil)
                
            }else{
                // Display alert message
                displayMyAlertMessage(userMessage: "パスワードが一致していません")
                return;
            }
            
        }
        
        
    }
    
    func displayMyAlertMessage(userMessage: String){
        
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle:  UIAlertController.Style.alert)
        let okAction = UIAlertAction(title:"OK", style: UIAlertAction.Style.default, handler:nil)
        myAlert.addAction(okAction);
        self.present(myAlert,animated:true, completion:nil)
        
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
