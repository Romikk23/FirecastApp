//
//  2ViewController.swift
//  FirecastApp
//
//  Created by USER on 31.01.2022.
//  Copyright © 2022 Roman. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var setNameField: UITextField!
    var timer = Timer()
    var interval: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNameField.isHidden = true
        self.label.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.label.text = "Let's keep\nin touch"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.label.text = "How can\nI call\nyou?"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            self.setNameField.isHidden = false
        }
    }
    @IBAction func setName(_ sender: UITextField) {
        goNextView()
    }
    @IBAction func click(_ sender: UIButton) {
        goNextView()
    }
    func goNextView() {
        self.setNameField.isHidden = true
        self.label.isHidden = true
        let name = setNameField.text
        print("Name: \(name)")
        UserDefaults.standard.set(name, forKey: "name")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let VCLogin = storyBoard.instantiateViewController(withIdentifier: "VC2") as! ViewController
                VCLogin.modalPresentationStyle = .fullScreen
                present(VCLogin, animated: true, completion: nil)
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
