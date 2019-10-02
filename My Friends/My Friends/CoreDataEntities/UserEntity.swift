//
//  UserEntity.swift
//  My Friends
//
//  Created by Алексей Перов on 25.09.2019.
//  Copyright © 2019 Алексей Перов. All rights reserved.
//

import Foundation
import CoreData

class UserEntity: NSManagedObject {
    
    //MARK: - CLASS FUNCTIONS -
    class func findOrCreate(_ user: User, context: NSManagedObjectContext) throws -> UserEntityCreationResult {
        if let userEntity = try? UserEntity.find(userId: user.id, context: context) {
            let result = UserEntityCreationResult(entity: userEntity, status: .alreadyExisted)
            
            return result
        } else {
            let userEntity = UserEntity(context: context)
            userEntity.id = user.id
            userEntity.firstName = user.firstName
            userEntity.lastName = user.lastName
            userEntity.email = user.email
            userEntity.phone = user.phone
            userEntity.image = user.image
            userEntity.imageOnServer = user.imageOnServer
            userEntity.isMyFriend = true
            if context.hasChanges {
                try context.save()
            }
            let result = UserEntityCreationResult(entity: userEntity, status: .created)
            
            return result
        }
    }
    
    class func all(_ context: NSManagedObjectContext) throws -> [UserEntity] {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            throw error
        }
    }
    
    class func find(userId: UUID, context: NSManagedObjectContext) throws -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %id", argumentArray: [userId])
        let fetchResult = try context.fetch(request)
            
        return fetchResult.first
    }
}
