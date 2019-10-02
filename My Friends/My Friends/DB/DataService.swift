//
//  DataService.swift
//  My Friends
//
//  Created by Алексей Перов on 30.09.2019.
//  Copyright © 2019 Алексей Перов. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataService {
    
    //MARK: - SHARED SINGLTONE -
    static let shared = DataService()
    
    //MARK: - VARIABLES -
    lazy var persistentContainer: NSPersistentContainer = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer
    
    //MARK: - INIT -
    private init() {}
    
    //MARK: - METHODS -
    func getAllUsers(_ completionHandler: (([User]) -> Void)?) {
        let viewContext = persistentContainer.viewContext
        persistentContainer.viewContext.perform {
            let userEntities = try? UserEntity.all(viewContext)
            let viewUsers = userEntities?.map({ User(entity: $0)})
            
            completionHandler?(viewUsers ?? [])
        }
    }
    
    func fetchFriendsWith(fetchedResultsController: inout NSFetchedResultsController<UserEntity>,
                          for viewController: NSFetchedResultsControllerDelegate,
                          _ complitionHandler: ([User]) -> Void) {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        let predicate = NSPredicate(format: "isMyFriend == TRUE")
        let sortDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: persistentContainer.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = viewController
        do {
            try fetchedResultsController.performFetch()
            if let fetchedObjects = fetchedResultsController.fetchedObjects {
                let viewUsers = fetchedObjects.map({ User(entity: $0)})
                complitionHandler(viewUsers)
            }
        } catch {
            print(error)
        }
    }
    
    func removeFromFriendlist(_ user: User) {
        let friendToRemove = try? findUser(userID: user.id)
        friendToRemove?.isMyFriend = false
        try? persistentContainer.viewContext.save()
    }
    
    func createFriend(_ user: User) throws -> UserEntityCreationResult {
        return try UserEntity.findOrCreate(user, context: persistentContainer.viewContext)
    }
    
    func findUser(userID: UUID) throws -> UserEntity? {
        return try UserEntity.find(userId: userID, context: persistentContainer.viewContext)
    }
}
