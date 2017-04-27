//
//  SocialCardCollectionViewCell.swift
//  Social Point
//
//  Created by Chandan Brown on 4/27/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import UIKit

class SocialCardCollectionViewCell: UICollectionViewCell {
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    var cardViewRightAnchor: NSLayoutConstraint?
    var cardViewLeftAnchor: NSLayoutConstraint?
    var cardWidthAnchor: NSLayoutConstraint?
    var deckViewController: DeckViewController?
    
    let textView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .clear
        label.text = "Card"
        label.textColor = .white
        return label
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .red
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 16
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        addSubview(cardView)
        addSubview(textView)
        
        // x, y, w, h
        cardViewRightAnchor = cardView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        cardView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        cardWidthAnchor = cardView.widthAnchor.constraint(equalToConstant: 400)
        cardView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        cardView.addSubview(activityIndicatorView)
        cardViewRightAnchor?.isActive = true
        cardWidthAnchor?.isActive = true
        
        // x, y, w, h
        activityIndicatorView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive  = true
        
        // x, y, w, h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive  = true
        
        // x, y, w, h
        textView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: cardView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
