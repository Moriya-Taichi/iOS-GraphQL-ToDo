//
//  TaskCellRector.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/07.
//  Copyright © 2020 Mori. All rights reserved.
//

import ReactorKit
import RxSwift

final class TaskCellReactor: Reactor {

    private let taskService: TaskServiceType
    var initialState: State

    enum Action {
        case complete
    }

    enum Mutation {
        case setTask(TaskFields)
    }

    struct State {
        var task: TaskFields
    }

    var identifier: String {
        return currentState.task.id
    }

    init (taskService: TaskServiceType, task: TaskFields) {
        self.taskService = taskService
        initialState = State(task: task)
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .complete:
            let updateTask = taskService.updateTask(taskIdentifier: currentState.task.id,
                                                         title: nil,
                                                         notes: nil,
                                                         completed: !currentState.task.completed,
                                                         due: nil)
                .map(Mutation.setTask)
            return updateTask
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTask(newTask):
            newState.task = newTask
        }
        return newState
    }
}
