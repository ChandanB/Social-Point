//
//  SocialCard.swift
//  Social Point
//
//  Created by Chandan Brown on 4/19/17.
//  Copyright © 2017 Chandan B. All rights reserved.
//

import Firebase
import UIKit

class SocialCard: NSObject {
    var profileImageUrl : String?
    var name  : String?
    var followersCount : Int?
    var friendsCount: Int?
    var bio   : String?
    var location : String?
    
    init(dictionary: [String: AnyObject]) {
        self.name = dictionary["name"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
        self.followersCount = dictionary["followers_count"] as? Int
        self.friendsCount = dictionary["friends_Count"] as? Int
        self.bio = dictionary["bio"] as? String
        self.location = dictionary["location"] as? String
    }

}
