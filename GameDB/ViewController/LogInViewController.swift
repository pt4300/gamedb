//
//  LogInViewController.swift
//  GameDB
//
//  Created by Yuting Yu on 24/5/21.
//

import UIKit
import Firebase

class LogInViewController: UIViewController,UITextFieldDelegate{
    var authHandle:AuthStateDidChangeListenerHandle?
    weak var databaseController: DatabaseProtocol?


    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        //setting delegate for textfield
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController


        // Do any additional setup after loading the view.
    }
    
    @IBAction func logIntoAccount(_ sender: Any) {
        
        guard let password = passwordTextField.text else{
            displayMessage(title: "error", message: "plz enter password")
            return
        }
        guard let email = emailTextField.text else{
            displayMessage(title: "error", message: "plz enter email")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.displayMessage(title: ("error"), message: error.localizedDescription)
            }
            DispatchQueue.main.async {
                // start loading account releaed game into the local storage. Firebase provide local persistence via cach image, the user defaults also used to keep track the current favorite/wishlist game id
                self.databaseController?.setUpAccount()
                self.navigationController?.popViewController(animated: true)
                

            }
        }
    }
    
    @IBAction func RegisterToAccount(_ sender: Any) {
        
        guard let password = passwordTextField.text else{
            displayMessage(title: "error", message: "plz enter password")
            return
        }
        guard let email = emailTextField.text else{
            displayMessage(title: "error", message: "plz enter email")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user,error) in
            if let error = error {
                self.displayMessage(title: ("error"), message: error.localizedDescription)
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authHandle = Auth.auth().addStateDidChangeListener(){
            (auth,user) in
            guard user != nil else{
                return
            }

        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let authHandle = authHandle else{
    return
        }
        Auth.auth().removeStateDidChangeListener(authHandle)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //ensure the keyboard is hiding once the user press enter
        textField.resignFirstResponder()
        return true
    }
    
    func displayMessage(title:String,message:String){
        let alterController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alterController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alterController,animated: true,completion: nil)
    }
}
