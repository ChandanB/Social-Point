//
//  LoginController+handlers.swift
//  It's Lit
//
//  Created by Chandan Brown on 1/30/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import TwitterKit
import SwiftyJSON

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleFacebookRegister(email: String, name: String, profileImageUrl: String, uid: String, gender: String, friends: Int) {
        let ref = FIRDatabase.database().reference()
        let id = FIRAuth.auth()?.currentUser?.uid
        let usersReference = ref.child("users").child(id!)
        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl, "facebookId": uid, "gender": gender, "friends_Count": friends] as [String : Any]
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err as Any)
                return
            }
            self.user = User(dictionary: values as [String : AnyObject])
            self.registerUserIntoDatabaseWithUID(uid: id!, values: values as [String : AnyObject])
        })
    }
    
    func handleTwitterRegister(followerCount: Int, twitterID: String) {
        let ref = FIRDatabase.database().reference()
        let uid = FIRAuth.auth()?.currentUser?.uid
        let usersReference = ref.child("users").child(uid!)
        let values = ["followers_count": followerCount, "twitterID": twitterID] as [String : Any]
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err as Any)
                return
            }
            
            self.user = User(dictionary: values as [String : AnyObject])
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err as Any)
                return
            }
            
            self.user = User(dictionary: values)
        })
    }
    
    func showEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        linkTwitter()
    }
    
    func linkTwitter() {
        let session = self.twitterSession
        guard let token = session?.authToken else { return }
        guard let secret = session?.authTokenSecret else { return }
        let credential = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        let prevUser = FIRAuth.auth()?.currentUser
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print ("Error \(err)")
            }
            
            print("Successfully created a Firebase-Twitter user: ", user?.uid ?? "")
            
            if prevUser != nil {
                user?.link(with: credential) { (user, error) in
                    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                        if error != nil {
                            return
                        }
                        // Merge prevUser and currentUser accounts and data
                        self.getFacebookFriends()
                    }
                }
            }
        })
    }
    
    func linkFacebook() {
        let session = self.twitterSession
        guard let token = session?.authToken else { return }
        guard let secret = session?.authTokenSecret else { return }
        let credentials = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        let prevUser = FIRAuth.auth()?.currentUser
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                if let unwrappedSession = session {
                    print("Failed to login to Firebase with Twitter: ", err)
                    let alert = UIAlertController(title: "Failed To Log In, Try Again",
                                                  message: "User \(unwrappedSession.userName) has failed to log in",
                        preferredStyle: UIAlertControllerStyle.alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
            
            print("Successfully created a Firebase-Twitter user: ", user?.uid ?? "")
            self.getTwitterFollowers()
            if prevUser != nil {
                user?.link(with: credential) { (user, error) in
                    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                        if error != nil {
                            return
                        }
                        // Merge prevUser and currentUser accounts and data
                        self.getTwitterFollowers()
                    }
                }
            }
            
            if let unwrappedSession = session {
                let alert = UIAlertController(title: "Logged In",
                                              message: "User \(unwrappedSession.userName) has logged in",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        })
    }
    
    
    func getTwitterFollowers() {
        let user = self.user
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let statusesShowEndpoint = "https://api.twitter.com/1.1/users/show.json"
            let params = ["id": userID]
            var clientError : NSError?
            let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(String(describing: connectionError))")
                }
                let json = JSON(data: data!)
                print(json)
                let followersCount = json["followers_count"].int
                if followersCount != nil {
                    self.handleTwitterRegister(followerCount: followersCount!, twitterID: userID)
                    user.followersCount = followersCount
                    print(user.followersCount as Any)
                } else {
                    print ("Followers are nil")
                }
            }
        }
    }
    
    func getFacebookFriends() {
        let user = self.user
        let params = ["fields": "first_name, last_name, user_friends"]
        FBSDKGraphRequest(graphPath: "me/friends", parameters: params).start { (connection, result , error) -> Void in
            if error != nil {
                print(error!)
            } else {
                //Do further work with response
                if let dictionary = result as? [String: AnyObject] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
                        // here "jsonData" is the dictionary encoded in JSON data
                        let json = JSON(data: jsonData)
                        print(json)
                        
                        let summary = json["summary"]
                        let followersCount = summary["total_count"].int
                        if followersCount == followersCount {
                            user.followersCount = followersCount
                            print("Found \(String(describing: user.followersCount)) friends")
                        } else {
                            print ("Followers are nil")
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            self.updateUser()
            self.createFacebookUser()
        }
    }
    
    func createFacebookUser() {
        let user = self.user
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, gender, name, email, picture.type(large)"]).start { (connection, result, err) in
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            
            print(result ?? "")
            connection?.start()
            
            if let dictionary = result as? [String: AnyObject] {
                
                if (dictionary["email"] as? String) != nil {
                    // access individual value in dictionary
                    
                    print ("This is the entire Dictionary: \(dictionary)")
                    user.gender = dictionary["gender"]! as? String
                    user.email = dictionary["email"]! as? String
                    user.id = dictionary["id"]! as? String
                    user.name = dictionary["name"]! as? String
                    
                    if let user_picture = dictionary["picture"] as? [String: AnyObject] {
                        if let data = user_picture["data"] as? [String: AnyObject] {
                            user.profileImageUrl = data["url"]! as? String
                        }
                    }
                }
            }
            
            self.handleFacebookRegister(email: user.email!, name: user.name!, profileImageUrl: user.profileImageUrl!, uid: user.id!, gender: user.gender!, friends: user.followersCount!)
            self.updateUser()
        }
    }
    
    func updateUser() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.user = User(dictionary: dictionary)
            }
        }, withCancel: nil)
    }
    
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
    }
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}
