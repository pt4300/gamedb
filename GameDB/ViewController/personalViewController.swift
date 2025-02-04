//
//  personalViewController.swift
//  GameDB
//
//  Created by Yuting Yu on 24/5/21.
//

import UIKit
import Firebase

class personalViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var favoriteGameButton: UIButton!
    @IBOutlet weak var wishListButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    weak var databaseController: DatabaseProtocol?

    var userID:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // hide login button if the user already logged in
        if let userID = Auth.auth().currentUser?.uid{
            loginButton.isHidden = true
        }
        else{
            favoriteGameButton.isHidden = true
            wishListButton.isHidden = true
            signOutButton.isHidden = true
        }

    }
    
    @IBAction func login(_ sender: Any) {
        // do nothing, just seguge trigger
    }
    
    @IBAction func favoriteGameList(_ sender: Any) {
        // do nothing, just seguge trigger

    }
    @IBAction func wishList(_ sender: Any) {
        // do nothing, just seguge trigger

    }
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }catch{
            print()
        }
        databaseController?.setUpAccount()
        // update the view via view will appear
        self.viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // provide dynamic switch between login/logout view via checking whether user is signed through auth function
        super.viewWillAppear(animated)
        if let userID = Auth.auth().currentUser?.uid{
            loginButton.isHidden = true
            favoriteGameButton.isHidden = false
            wishListButton.isHidden = false
            signOutButton.isHidden = false
        }
        else{
            favoriteGameButton.isHidden = true
            wishListButton.isHidden = true
            signOutButton.isHidden = true
            loginButton.isHidden = false

        }
    }


}
