//
//  EntityCreationResult.swift
//  My Friends
//
//  Created by Алексей Перов on 30.09.2019.
//  Copyright © 2019 Алексей Перов. All rights reserved.
//

import Foundation

struct UserEntityCreationResult {
    let resultEntity: UserEntity
    let creationStatus: CreationStatus
    
    init(entity: UserEntity, status: CreationStatus) {
        self.resultEntity = entity
        self.creationStatus = status
    }
}

enum CreationStatus {
    case alreadyExisted
    case created
}
