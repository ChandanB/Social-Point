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
    
    var user: User?

    override func viewDidAppear(_ animated: Bool) {
        fetchUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(viewController)
        view.backgroundColor = .black
        setupViewControllerView()
    }
    
    func goToUserProfilePage() {
       print("Button pressed")
       let vc = HomeViewController()
       vc.user = self.user
       self.navigationController?.pushViewController(vc, animated: true)
    }

    func setupViewControllerView() {
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewController.view)
        
        viewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        viewController.view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        viewController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    
    func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        
        ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func fetchUser() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.user = User(dictionary: dictionary)
                print("user successfully made on profile view")
            }
        }, withCancel: nil)
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
        let uid = user?.uid
        let deleteRef = FIRDatabase.database().reference().child("Profile-Image-Name").child(uid!).child("image_name")
        
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
        
        uploadNewPic()
    }
    
    func uploadNewPic() {
        
        let user = FIRAuth.auth()?.currentUser
        guard (user?.uid) != nil else {
            return
        }
        let imageName = UUID().uuidString
        let ref = FIRDatabase.database().reference().child("Profile-Image-Name").child((user?.uid)!)
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
