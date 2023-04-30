//
//  LoginViewController.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 31/12/2022.
//

import UIKit
import ProgressHUD
import Firebase
class LoginViewController: UIViewController {

    // MARK: - IBOutlets.
    //lbl
    @IBOutlet weak var registerLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var confirmPasswordLbl: UILabel!
    @IBOutlet weak var haveAnAccountLbl: UILabel!
    //txt
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    // Btn
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    @IBOutlet weak var resendEmailBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    // MARK: - Private Variables.
    var isLogin :Bool = false
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
    super.viewDidLoad()
        emailLbl.text = ""
        passwordLbl.text = ""
        confirmPasswordLbl.text = ""
        emailTxt.delegate = self
        passwordTxt.delegate = self
        confirmPasswordTxt.delegate = self
        setUpBackgroundTab()
        
    }
    // MARK: - IBActions.
    @IBAction func resendEmailPressedBtn(_ sender: Any) {
        resendVerificationEmailToUser()
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        if isDataInputedFor(mood: isLogin ? "login" :"register"){
            isLogin ? loginUser() :registerUser()
            resendVerificationEmailToUser()
        }else{
            ProgressHUD.showError("error, please enter all data")
        }
    }
    
    @IBAction func forgetPasswordPressed(_ sender: Any) {
        if isDataInputedFor(mood: "forgetPassword"){
            print("ok")
            restPassword()
            
        }else{
            ProgressHUD.showError("must enter email")
        }
    }
    @IBAction func loginPressed(_ sender: Any) {
        updateUiMode(mood: isLogin)
    }
    
  
    // MARK: - Private Functions.
    
    
    // MARK: - update UI from Register to Login.
    func updateUiMode (mood :Bool ){
        if !mood{
            registerLbl.text = "Login"
            confirmPasswordLbl.isHidden = true
            confirmPasswordTxt.isHidden = true
            forgetPasswordBtn.isHidden = false
            resendEmailBtn.isHidden = true
            registerBtn.setTitle("Login", for: .normal)
            haveAnAccountLbl.text = "Don't have account?"
            loginBtn.setTitle("Register", for: .normal)
        }else {
            registerLbl.text = "Register"
            confirmPasswordLbl.isHidden = false
            confirmPasswordTxt.isHidden = false
            forgetPasswordBtn.isHidden = true
            resendEmailBtn.isHidden = false
            registerBtn.setTitle("Register", for: .normal)
            haveAnAccountLbl.text = "Have an account?"
            loginBtn.setTitle("Login", for: .normal)
        }
        isLogin.toggle()
    }
    // MARK: - Check Data.
    private func isDataInputedFor (mood :String) -> Bool{
        
        switch mood {
        case "login" :
            return emailTxt.text != "" && passwordTxt .text != ""
        case "register" :
            return emailTxt.text != "" && passwordTxt .text != "" && confirmPasswordTxt.text != ""
        case "forgetPassword" :
            return emailTxt.text != ""


        default:
            return false
        }
    }
    // MARK: - Register User.

    private func registerUser(){
        if passwordTxt.text! == confirmPasswordTxt.text! {
            FUserListener.shared.registerUserWith(email: emailTxt.text!, password: passwordTxt.text!) { error  in
                if error == nil {
                    ProgressHUD.showSuccess("verification email sent , please verfiy your account")
                      //  self.goToChat()
                    
                }else{
                    ProgressHUD.showError(error?.localizedDescription)
                }
            }
        }
    }
    // MARK: - Resend Email Verification.

    func resendVerificationEmailToUser(){
        FUserListener.shared.resendVerificationEmail(email: emailTxt.text!) { error in
            if error == nil {
                ProgressHUD.showSuccess("email sent success")
            }
            else{
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
        
    }
    // MARK: - Login User Func .
    
    private func loginUser(){
        FUserListener.shared.loginUserWith(email: emailTxt.text!, password:passwordTxt.text!) { ( error ,isverified) in
            if error == nil {
                
                if isverified {
                    //will login to app
                    print("login complete")
                    self.goToChat()
                }else{
                    ProgressHUD.showFailed("please verify your email")
                }
            }else{
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    
    // MARK: - Rest Password.
    
    private func restPassword (){
        FUserListener.shared.forgetPassword(email: emailTxt.text!) { error in
            if error == nil {
                ProgressHUD.showSuccess("Email for forget Password sent successfully")
                
            }else{
                ProgressHUD.showFailed(error?.localizedDescription)
            }
        }
    }
    
    // MARK: - Go to main Chat.
    
    private func goToChat (){
        let tabView = UIStoryboard(name: "Chat", bundle: nil) .instantiateViewController(withIdentifier: "TabView" )as! UITabBarController
        tabView.modalPresentationStyle = .fullScreen
        self.present(tabView, animated: true ,completion: nil)
        
    }
    
    // MARK: - Resend Email Verify.

    private func resendVerificationEmail() {
        FUserListener.shared.resendVerificationEmail(email: emailTxt.text!, complition: { error in
            if error == nil {
                ProgressHUD.showSuccess("verification email sent successfully")
            } else {
                ProgressHUD.showFailed(error?.localizedDescription)
            }
        })
            
        }
        
    
   


    
}

// MARK: - UITextFieldDelegate Delegate & DataSource.

extension LoginViewController:UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        emailLbl .text = emailTxt.hasText ? "Email" : ""
        passwordLbl .text = passwordTxt.hasText ? "Password" : ""
        confirmPasswordLbl .text = confirmPasswordTxt.hasText ? "Confirm Password" : ""
        
    }
    private func setUpBackgroundTab (){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard (){
        view.endEditing(false)
    }
}
    

// MARK: - APi.
//
//extension <#UIviewController#> {
//
//
//
//}


