//
//  SchemaMirgation.swift
//  Rex
//
//  Created by Sobolev, Artemiy on 8/30/17.
//  Copyright © 2017 splyshka. All rights reserved.
//

protocol SchemaMigrator {
    func migrate(from current: Schema, to target: Schema) throws
}

struct BasicSchemaMigrator: SchemaMigrator {
    
    func migrate(from current: Schema, to target: Schema) throws {
        
        guard !target.priorities.isEmpty else {
            throw Schema.MigrationError.emptySchema
        }
        
        guard !target.resolutions.isEmpty else {
            throw Schema.MigrationError.emptySchema
        }
        
        if current.resolutions != target.resolutions {
            
            let targetResolutionIDs = Set(target.resolutions.map { $0.identifier })
            let currentResolutionIDs = Set(current.resolutions.map { $0.identifier })
            
            guard targetResolutionIDs.count == target.resolutions.count else {
                // dublicating resolutions
                throw Schema.MigrationError.invalidSchema
            }
            
            let idsToCreate = targetResolutionIDs.subtracting(currentResolutionIDs)
            let maxCurrentID = currentResolutionIDs.max()!
            for idToCreate in idsToCreate {
                guard maxCurrentID < idToCreate else {
                    throw Schema.MigrationError.invalidSchema
                }
            }
        }
        
        if current.priorities != target.priorities {
            //    new priorities must be in ascending order
            _ = try target.priorities.reduce(-1) {
                guard $0 < $1.identifier else {
                    throw Schema.MigrationError.invalidSchema
                }
                return $1.identifier
            }
        }
    }
}
