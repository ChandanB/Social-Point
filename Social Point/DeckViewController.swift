//
//  File.swift
//  It's  Lit
//
//  Created by Chandan Brown on 7/24/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation


class DeckViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeCards()
        }
    }
    
    // Device and View
    let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var startingImageView: UIImageView?
    var blackBackgroundView: UIView?
    var startingFrame: CGRect?
    
    // Database
    var databaseHandleReceiving: FIRDatabaseHandle?
    var databaseHandle: FIRDatabaseHandle?
    var ref: FIRDatabaseReference?
    var cards = [SocialCard]()
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        collectionView?.register(SocialCardCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.backgroundColor = UIColor.rgb(230, green: 230, blue: 230)
        collectionView?.keyboardDismissMode  = .interactive
        collectionView?.alwaysBounceHorizontal = true
    }
    
    func observeCards() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let usercardsRef = FIRDatabase.database().reference().child("user-cards").child(uid)
        
        usercardsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.cards = [SocialCard(dictionary: dictionary)]
                print("Deck successfully made with cards")
            }
        }, withCancel: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
        
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SocialCardCollectionViewCell
        cell.deckViewController = self
        let card = cards[(indexPath as NSIndexPath).item]
        
        setupCell(cell, card: card)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // let card = cards[(indexPath as NSIndexPath).item]
        
        let height: CGFloat = UIScreen.main.bounds.height - 30
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    fileprivate func setupCell(_ cell: SocialCardCollectionViewCell, card: SocialCard) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        cell.textView.text = user?.name
        cell.cardView.backgroundColor = .red
    }

}
