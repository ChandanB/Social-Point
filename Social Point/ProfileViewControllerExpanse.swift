//
//  ProfileControllerExpanse.swift
//  Link
//
//  Created by Chandan Brown on 3/27/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var viewController = ProfileControllerCard()
    
    let likesButtonText: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Likes", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica-Light", size: 15)
        return button
    }()
    
    let profileImageIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "Profile Image Shape")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let backButton: UIButton = {
        let imageView = UIButton(type: .custom)
        let image = UIImage(named: "Back Button")
        imageView.setImage(image, for: .normal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let settingsButton: UIButton = {
        let imageView = UIButton(type: .custom)
        let image = UIImage(named: "Settings Image Shape")
        imageView.setImage(image, for: .normal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let topView: UIView = {
        let view = UIView()
        // UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(viewController)
        view.backgroundColor = .clear
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.layer.cornerRadius = 18
        setupViewControllerView()
        settingsButton.addTarget(self, action: #selector (handleSelectProfileImageView), for: .touchUpInside)
    }
    
    func setupViewControllerView() {
        view.addSubview(viewController.view)
        view.addSubview(self.topView)
        view.addSubview(self.settingsButton)
        let screenSize: CGRect = UIScreen.main.bounds
        print(screenSize.width)
        
        self.topView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        self.topView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.topView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.topView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 320).isActive = true
    
        viewController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 64).isActive = true
        viewController.view.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        viewController.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    }
    
    func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        
        ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleSelectProfileImageView(sender: UIButton!) {
        print("Button Pressed")
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            viewController.profileImageView.image = selectedImage
            profilePicUpdate()
            viewController.updateImageViewBackground()
            viewController.imageViewBackground.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func profilePicUpdate() {
        let user = FIRAuth.auth()?.currentUser
        guard (user?.uid) != nil else {
            return
        }
        //successfully authenticated user
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference().child("Profile-Image-Name").child(uid)
        let deleteRef = FIRDatabase.database().reference().child("Profile-Image-Name").child(uid).child("image_name")
        
        deleteRef.observe(.value, with: { (snapshot) in
            if snapshot.value != nil {
                let deleteThis = snapshot.value!
                print(deleteThis)
                let storageDeleteRef = FIRStorage.storage().reference().child("profile_images").child("\(deleteThis).jpg")
                storageDeleteRef.delete { error in
                    if let error = error {
                        print("Uh-oh, an error occurred!")
                        print (error as Any)
                    } else {
                        print("File deleted successfully")
                    }
                }
            }
        })
        
        let imageName = UUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
        let metadata = FIRStorageMetadata()
        
        if let profileImage = viewController.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            let nameValues = ["image_name": imageName]
            ref.updateChildValues(nameValues, withCompletionBlock: { (err, ref) in
            })
            
            storageRef.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                
                if error != nil {
                    print(error as Any)
                    return
                }
                
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    let values = ["profileImageUrl": profileImageUrl]
                    self.registerUserIntoDatabaseWithUID((user?.uid)!, values: values as [String : AnyObject])
                }
            })
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
}
