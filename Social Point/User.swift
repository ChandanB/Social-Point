//
//  Users.swift
//  Lit
//
//  Created by Chandan Brown on 7/24/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import Firebase
import UIKit

class User: NSObject {
    var profileImageUrl : String?
    var email : String?
    var name  : String?
    var id    : String?
    var gender : String?
    var followersCount : Int?
    var friendsCount: Int?
    var twitterId: String?
    var bio   : String?
    var location : String?
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
        self.gender = dictionary["gender"] as? String
        self.followersCount = dictionary["followers_count"] as? Int
        self.friendsCount = dictionary["friends_Count"] as? Int
        self.twitterId = dictionary["twitterID"] as? String
        self.bio = dictionary["bio"] as? String
        self.location = dictionary["location"] as? String
    }
}
