//
//  CreateTaskViewReactor.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/03.
//  Copyright © 2020 Mori. All rights reserved.
//

import ReactorKit
import RxSwift

final class CreateTaskViewReactor: Reactor {

    var initialState: State

    private let taskService: TaskServiceType

    enum Action {
        case createTask
    }

    struct State {

    }

    init(taskService: TaskServiceType) {
        self.taskService = taskService
        initialState = State()
    }
}
