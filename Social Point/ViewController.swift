//
//  ViewController.swift
//  Cards_Layout
//
//  Created by kdas on 11/2/16.
//  Copyright © 2016 Classic Tutorials. All rights reserved.
//

import UIKit
import Firebase
import paper_onboarding

class ViewController: UIViewController {

    //Create Users Social Card At Login
    var socialCard = SocialCard(dictionary: [:])
    
    //Create User using dictionary values
    var user = User(dictionary: [:])
    
    //Catch the results of data from login and store in dictionary
    var resultdict: NSDictionary? = [:]
    
    //Create ImageView to download profileImageinto
    var profileImageView = UIImageView()
    
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
        let setupView = ProfileViewController()
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
    }
}

extension ViewController: PaperOnboardingDataSource, PaperOnboardingDelegate {
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 0 {
        }
        
        if index == 1 {
           
        }
        
        if index >= 2 {
           
        }
    }
    
    func onboardingDidTransitonToIndex(_ index: Int) {
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
    }
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        let font = UIFont (name: "AppleColorEmoji", size: 24)
        let titleFont = UIFont(name: "AmericanTypewriter-Bold", size: 30)
        let white = UIColor.white
        let black = UIColor.black
        let royalPurple = UIColor.rgb(119, green: 0, blue: 255)
        let rookieBronze = UIColor.rgb(201, green: 144, blue: 91)
        let dietyGold = UIColor.rgb(246, green: 230, blue: 0)
        let verifiedGreen = UIColor.rgb(0, green: 253, blue: 41)

        
        return [
            ("Kadeem Card", "Newbie", "I am the recipe to successs", "Black Deck", white, rookieBronze, rookieBronze, titleFont, font),
            ("Madhur Card", "Royal", "Design Code and Ship", "Black Deck", white, royalPurple, royalPurple, titleFont, font),
            ("Marq Card", "Diety", "I'm Super Official", "Deck", UIColor.lightGray, dietyGold, dietyGold, titleFont, font),
            ("Verified Card", "Verified", "Drake is a Canadian Actor, rapper and singer.", "Black Deck", white, verifiedGreen, verifiedGreen, titleFont, font),
            ("Verified Rihanna", "Verified", "Get #ANTI: http://smarturl.it/daANTI", "Black Deck", white, verifiedGreen, verifiedGreen, titleFont, font)
            ][index] as! OnboardingItemInfo
    }
    
    func onboardingItemsCount() -> Int {
        return 5
    }
}

extension ViewController {
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


