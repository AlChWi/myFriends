//
//  User.swift
//  My Friends
//
//  Created by Алексей Перов on 25.09.2019.
//  Copyright © 2019 Алексей Перов. All rights reserved.
//

import Foundation
import SwiftyJSON

class User: Codable {
    //MARK: - VARIVABLES -
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var image: Data?
    var imageOnServer: URL
    var isMyFriend: Bool
    
    //MARK: - INIT -
    init(id: UUID, firstName: String, lastName: String, email: String, phone: String, imageOnServer: URL) {
         self.id = id
         self.firstName = firstName
         self.lastName = lastName
         self.email = email
         self.phone = phone
         self.image = nil
         self.imageOnServer = imageOnServer
         self.isMyFriend = false
     }
    
    init(entity: UserEntity) {
        self.id = entity.id!
        self.firstName = entity.firstName ?? ""
        self.lastName = entity.lastName ?? ""
        self.email = entity.email ?? ""
        self.phone = entity.phone!
        self.image = entity.image ?? nil
        self.imageOnServer = entity.imageOnServer!
        self.isMyFriend = entity.isMyFriend
    }
    
    init?(json: JSON) {
        self.firstName = json["name"]["first"].stringValue
        self.lastName = json["name"]["last"].stringValue
        self.email = json["email"].stringValue
        guard let id = UUID(uuidString: json["login"]["uuid"].stringValue) else {
            return nil
        }
        self.id = id
        self.phone = json["phone"].stringValue
        let imageURLString = json["picture"]["medium"].stringValue
        guard let imageURL = URL(string: imageURLString) else {
            return nil
        }
        self.imageOnServer = imageURL
        self.image = nil
        self.isMyFriend = false
    }
}
