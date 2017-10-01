//
//  ListCoordination.swift
//  Rex
//
//  Created by Artemiy Sobolev on 27/09/2017.
//  Copyright © 2017 splyshka. All rights reserved.
//

import Foundation
import RexKit

enum Change<T: Equatable> {
    case add(T)
    case remove(T)
    case update(T)
}

typealias ListCoordinatorHandler<Item: Equatable> = ([Item]) -> ((Change<Item>) -> Void)

protocol ListCoordinator {
    associatedtype Item: Equatable
    func update(handler: @escaping ListCoordinatorHandler<Item>) -> Progress
}

protocol ProjectListCoordinator: ListCoordinator {
    associatedtype Item = Project
}

struct CloudProjectListCoordinator: ListCoordinator {
    let context: AppContext
    
    func update(handler: @escaping ([Project]) -> ((Change<Project>) -> Void)) -> Progress {
		//	FIXME: add progress initialization
        context.myProjects { projects in
            
            
            
        }
        return Progress()
    }
}


