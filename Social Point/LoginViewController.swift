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
import paper_onboarding

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate{
    
    //Create Users Social Card At Login
    var socialCard = SocialCard(dictionary: [:])
    
    //Create User using dictionary values
    var user = User(dictionary: [:])
    
    //Catch the results of data from login and store in dictionary
    var resultdict: NSDictionary? = [:]
    
    //Create ImageView to download profileImageinto
    var profileImageView = UIImageView()
    
    var twtrCredential: FIRAuthCredential?
    
    var twitterSession: TWTRSession?
    var twitterButton: TWTRLogInButton?
    var facebookLoginButton: FBSDKLoginButton?
    
    var continueButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(LoginViewController.goToProfileSetup), for: .touchUpInside)
        return button
    }()
    
    func goToProfileSetup() {
        let setupView = ProfileControllerCard()
        setupView.user = self.user
        self.present(setupView, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let onboarding = PaperOnboarding(itemsCount: 3)
        onboarding.dataSource = self
        onboarding.delegate = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        // add constraints
        for attribute: NSLayoutAttribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
        
        //Load Facebook Button into view
        // setupFacebookButton()
        
        //Load Twitter Button into view
        setupTwitterButton()
    }
    
    func setupContinueButton() {
        view.addSubview(continueButton)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100).isActive = true
        continueButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 240).isActive = true
    }
    
    func setupFacebookButton() {
        facebookLoginButton = FBSDKLoginButton()
        view.addSubview(facebookLoginButton!)
        facebookLoginButton?.frame = CGRect(x: 16, y: view.frame.midY - 40, width: view.frame.width - 32, height: 50)
        facebookLoginButton?.delegate = self
        facebookLoginButton?.readPermissions = ["email", "public_profile", "user_friends"]
        facebookLoginButton?.isHidden = false
    }
    
    fileprivate func setupTwitterButton() {
        twitterButton = TWTRLogInButton { (session, error) in
            self.twitterSession = session
            guard let token = session?.authToken else { return }
            guard let secret = session?.authTokenSecret else { return }
            let credentials = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
            self.twtrCredential = credentials
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
        
        view.addSubview(twitterButton!)
        twitterButton?.frame = CGRect(x: 16, y: view.frame.midY - 40, width: view.frame.width - 32, height: 50)
    }
    
    func createSocialCard() {
        if let checkedUrl = URL(string: user.profileImageUrl!) {
            profileImageView.contentMode = .scaleAspectFit
            downloadImage(url: checkedUrl)
        }
        socialCard.name = user.name
        socialCard.followersCount = user.followersCount
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

extension LoginViewController: PaperOnboardingDataSource, PaperOnboardingDelegate {
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 0 {
            view.addSubview(twitterButton!)
            continueButton.removeFromSuperview()
            facebookLoginButton?.removeFromSuperview()
        }
        
        if index == 1 {
            twitterButton?.removeFromSuperview()
            continueButton.removeFromSuperview()
            setupFacebookButton()
        }
        
        if index >= 2 {
            facebookLoginButton?.removeFromSuperview()
            setupContinueButton()
        }
    }
    
    func onboardingDidTransitonToIndex(_ index: Int) {
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
    }
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        let font = UIFont (name: "AppleColorEmoji", size: 20)
        let titleFont = UIFont(name: "AmericanTypewriter-Bold", size: 24)
        let white = UIColor.white
        let black = UIColor.black
        let fbBlue = UIColor.rgb(59, green: 89, blue: 152)
        let twtrBlue = UIColor.rgb(0, green: 132, blue: 180)
        
        return [
            ("Twitter Bird Blue", "Sign In With Twitter", "The more followers you have will increase Social Point", "Twitter Circle", white, twtrBlue, twtrBlue, titleFont, font),
            ("Facebook F", "Sign In With Facebook", "The more friends you have will increase your Social Point", "Facebook Circle", white, fbBlue, fbBlue, titleFont, font),
            ("Demo Card", "A Unique Card", "We will give you a card based on your Social Point Score", "Black Deck", white, black, black, titleFont, font)
            ][index] as! OnboardingItemInfo
    }
    
    func onboardingItemsCount() -> Int {
        return 3
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
