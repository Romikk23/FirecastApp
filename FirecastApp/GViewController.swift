//
//  GViewController.swift
//  FirecastApp
//
//  Created by USER on 31.01.2022.
//  Copyright © 2022 Roman. All rights reserved.
//

import UIKit

class GViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let name = UserDefaults.standard.string(forKey: "name")
        if (name != nil) {
            print(name)
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let VCLogin = storyBoard.instantiateViewController(withIdentifier: "VC2") as! ViewController
                    VCLogin.modalPresentationStyle = .fullScreen
                    present(VCLogin, animated: true, completion: nil)

        } else {
            print(name)
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let VCLogin = storyBoard.instantiateViewController(withIdentifier: "VC1") as! FirstViewController
                    VCLogin.modalPresentationStyle = .fullScreen
                    present(VCLogin, animated: true, completion: nil)
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
