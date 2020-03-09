//
//  CellItem.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/04.
//  Copyright © 2020 Mori. All rights reserved.
//

import RxDataSources

enum CellItem: Identifiable, Equatable {

    static func == (lhs: CellItem, rhs: CellItem) -> Bool {
        return lhs.identity == rhs.identity
    }

    typealias Identity = String

    var identity: Identity {
        switch self {
        case let .task(task):
            return "Task:\(task.identifier)"
        }
    }

    case task(TaskCellReactor)
}
