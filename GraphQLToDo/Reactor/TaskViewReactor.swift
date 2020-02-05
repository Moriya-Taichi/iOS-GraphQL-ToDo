//
//  TaskViewReactor.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/03.
//  Copyright © 2020 Mori. All rights reserved.
//

import ReactorKit
import RxSwift

final class TaskViewReactor: Reactor {


    var initialState: State

    private let taskService: TaskServiceType
    private let accessibleApolloStore: AccessibleApolloStoreType

    enum Action {
        case load
        case update
    }

    struct State {

    }

    init(identifier: String,
         taskService: TaskServiceType,
         accessibleApolloStore: AccessibleApolloStoreType)
    {
        self.taskService = taskService
        self.accessibleApolloStore = accessibleApolloStore
        initialState = State()
    }
    
}
