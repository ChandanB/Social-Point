//
//  ViewController.swift
//  Social Point
//
//  Created by Chandan Brown on 4/17/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import TwitterKit
import Firebase

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    //Create Users Social Card At Login
    var socialCard = SocialCard()
    
    //Create User using dictionary values
    var user = User(dictionary: [:])
    
    //Catch the results of data from login and store in dictionary
    var resultdict: NSDictionary? = [:]
    
    //Create ImageView to download profileImageinto
    var profileImageView = UIImageView()
    
    var twitterSession: TWTRSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Load Facebook Button into view
        setupFacebookButton()
        
        //Load Twitter Button into view
        setupTwitterButton()
    }
    
    fileprivate func setupTwitterButton() {
        let twitterButton = TWTRLogInButton { (session, error) in
            self.twitterSession = session
            guard let token = session?.authToken else { return }
            guard let secret = session?.authTokenSecret else { return }
            let credentials = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
            let prevUser = FIRAuth.auth()?.currentUser
            
            if prevUser != nil {
                self.linkFacebook()
            } else {
                FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                    if let err = error {
                        print("Failed to login to Firebase with Twitter: ", err)
                        return
                    }
                    print("Successfully created a Firebase-Twitter user: ", user?.uid ?? "")
                    self.getTwitterFollowers()
                })
            }
        }
        view.addSubview(twitterButton)
        twitterButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
    }
    
    func setupFacebookButton() {
        let facebookLoginButton = FBSDKLoginButton()
        view.addSubview(facebookLoginButton)
        facebookLoginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["email", "public_profile", "user_friends"]
    }
    
    func fetchUser() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.user = User(dictionary: dictionary)
                print("user successfully made with dictionary")
            }
        }, withCancel: nil)
    }
    
    func createSocialCard() {
        if let checkedUrl = URL(string: user.profileImageUrl!) {
            profileImageView.contentMode = .scaleAspectFit
            downloadImage(url: checkedUrl)
        }
        socialCard.name = user.name
        socialCard.followersCount = user.followersCount
        socialCard.profileImage = profileImageView.image
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result:
        FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        showEmailAddress()
    }
}


extension LoginViewController {
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.profileImageView.image = UIImage(data: data)
            }
        }
    }
}
