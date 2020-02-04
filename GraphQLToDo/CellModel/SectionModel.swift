//
//  SectionModel.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/04.
//  Copyright © 2020 Mori. All rights reserved.
//

import RxDataSources

typealias CellItemSection = AnimatableSectionModel<SectionID, CellItem>

protocol Identifiable: IdentifiableType, Equatable {
    associatedtype Identifier: Equatable
    var identity: Identifier { get }
}

enum SectionID: String, IdentifiableType {

    case task

    var identity: String {
        return self.rawValue
    }
}
