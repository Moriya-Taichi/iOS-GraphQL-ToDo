//
//  TaskCellRector.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/07.
//  Copyright © 2020 Mori. All rights reserved.
//

import ReactorKit
import Foundation
import RxSwift

final class TaskCellReactor: Reactor {

    private let taskService: TaskServiceType
    private let repository: TaskRepositoryType
    var initialState: State

    enum Action {
        case complete
    }

    enum Mutation {
        case setTask(TaskFields)
    }

    struct State {
        var task: TaskFields

        var dueString: String? {
            if let dateString = task.due,
                let date = ISO8601DateFormatter().date(from: dateString) {
                return ISO8601DateFormatter.string(from: date, timeZone: .current, formatOptions: [.withFullDate,
                                                                                                   .withTime,
                                                                                                   .withDashSeparatorInDate,
                                                                                                   .withColonSeparatorInTime,
                                                                                                   .withSpaceBetweenDateAndTime])
            }
            return nil
        }
    }

    var identifier: String {
        return currentState.task.id
    }

    init (taskService: TaskServiceType, repository: TaskRepositoryType, task: TaskFields) {
        self.taskService = taskService
        self.repository = repository
        initialState = State(task: task)
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .complete:
            let updateTask = repository.updateTask(taskIdentifier: currentState.task.id,
                                                    title: nil,
                                                    notes: nil,
                                                    completed: !currentState.task.completed,
                                                    due: nil)
                .map(Mutation.setTask)
            return updateTask
        }
    }

    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return .merge(
            mutation,
            taskService
                .updateTaskStream
                .filter { $0.id == self.identifier }
                .map(Mutation.setTask)
        )
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
