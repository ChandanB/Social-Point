//
//  HomeViewController.swift
//  Social Point
//
//  Created by Chandan Brown on 4/26/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import CoreLocation

class HomeViewController: FormViewController {
    
    var user: User?
    var bio: String?
    var location: String?
    var count = 0
    
    var continueButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(HomeViewController.updateUser), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContinueButton()
        
        form +++ Section("Setup Account")
            <<< TextAreaRow() {
                $0.tag = "Bio"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
                
                if user?.bio != nil {
                    $0.placeholder = user?.bio
                } else {
                    $0.placeholder = "Describe yourself"
                }
                
            }
        
            <<< TextRow() { row in
                row.tag = "Location"
                row.title = "Enter Location"
                if user?.location != nil {
                    row.placeholder = user?.location
                } else {
                    row.placeholder = "Where are you from?"
                }
            }
        
      
        // Enables smooth scrolling on navigation to off-screen rows
        animateScroll = true
        // Leaves 20pt of space between the keyboard and the highlighted row after scrolling to an off screen row
        rowKeyboardSpacing = 40
    }
    
    func setupContinueButton() {
        view.addSubview(continueButton)
        continueButton.setTitle("Save", for: .normal)
        continueButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100).isActive = true
        continueButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 240).isActive = true
    }
    
    func updateUser() {
        print("User updated")
        let ref = FIRDatabase.database().reference()
        let uid = FIRAuth.auth()?.currentUser?.uid
        let usersReference = ref.child("users").child(uid!)
        
        let valuesDictionary = form.values()
        
      //  let bioRow: TextRow? = form.rowBy(tag: "Bio")
        bio = valuesDictionary["Bio"] as? String
        
      //  let locRow: TextAreaRow? = form.rowBy(tag: "Location")
        location = valuesDictionary["Location"] as? String
        

        user?.bio = bio
        user?.location = location
        
        let values = ["bio": bio, "location": location] as [String : AnyObject]
        
        usersReference.updateChildValues(values) { (err, ref) in
            if err != nil {
                print(err as Any)
                return
            }
            
            self.user = User(dictionary: values)
            let vc = ProfileViewController()
            vc.user = self.user
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let viewController = LoginViewController()
        let navController = UINavigationController(rootViewController: viewController)
        present(navController, animated: true, completion: nil)
    }
    
}
