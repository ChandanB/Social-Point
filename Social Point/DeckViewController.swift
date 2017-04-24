//
//  DeckViewController.swift
//  Social Point
//
//  Created by Chandan Brown on 4/19/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import UIKit
import Koloda
import Firebase

class DeckViewController: UIViewController {
    var loginController = LoginViewController()
    
    weak var kolodaView: KolodaView!
    weak var dataSource: KolodaViewDataSource!
    weak var delegate: KolodaViewDelegate?
    public var currentCardIndex = 0
    public var countOfCards = 0
    var countOfVisibleCards = 0
    var cardDeck = [SocialCard]()
    var cardView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.dataSource = self
        kolodaView.delegate = self
    }
}

extension DeckViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        // datasource.reset
    }
    
    func koloda(koloda: KolodaView, didSelectCardAt index: Int) {
        UIApplication.shared.openURL(NSURL(string: "https://yalantis.com/")! as URL)
    }
}

extension DeckViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return cardDeck.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return cardView
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView",
                                                  owner: self, options: nil)?[0] as? OverlayView
    }
    
}
