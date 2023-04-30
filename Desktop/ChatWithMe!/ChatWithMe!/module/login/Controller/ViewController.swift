//
//  ViewController.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 20/12/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var customBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        customBtn.layer.cornerRadius = 15
        
    }
    @IBAction func getStartApp(_ sender: Any) {
        goToChat()
    }
    
    private func goToChat (){
        let mainView = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "RegisterId" )as! UIViewController
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true ,completion: nil)
        
    }
}

