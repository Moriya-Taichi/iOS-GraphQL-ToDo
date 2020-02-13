//
//  TaskViewReactor.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/03.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift

final class TaskViewReactor: Reactor {


    var initialState: State

    private let taskService: TaskServiceType
    private let accessibleApolloStore: AccessibleApolloStoreType

    private let taskIdentifier: String
    private var cachedTask: TaskFields = TaskFields(id: "", title: "", notes: "", completed: false)

    enum Action {
        case load
        case updateTask
        case setTitle(String)
        case setNotes(String)
        case setDue(Date)
        case setCompleted(Bool)
    }

    enum Mutation {
        case setTask(TaskFields)
        case updateTitle(String)
        case updateNotes(String)
        case updateDue(String)
        case updateCompleted(Bool)
    }

    struct State {
        var task: TaskFields
    }

    init(identifier: String,
         taskService: TaskServiceType,
         accessibleApolloStore: AccessibleApolloStoreType)
    {
        self.taskService = taskService
        self.accessibleApolloStore = accessibleApolloStore
        self.taskIdentifier = identifier
        initialState = State(task: TaskFields(id: "", title: "", notes: "", completed: false))
    }

    func mutate(action: Action) -> Observable<Mutation> {
        let state = currentState
        switch action {
        case .load:
            let task = accessibleApolloStore.load(identifier: taskIdentifier,
                                                  fragmentType: TaskFields.self)
                .map(Mutation.setTask)
            return task
        case .updateTask:
            guard cachedTask != state.task else { return .empty() }
            taskService.updateTask(taskIdentifier: taskIdentifier,
                                   title: state.task.title,
                                   notes: state.task.notes,
                                   completed: state.task.completed,
                                   due: state.task.due)

                .do(onNext: {[weak self] task in
                    let _ = self?.accessibleApolloStore.update(identifier: task.id,
                                                               fragmentType: TaskFields.self,
                                                               newItem: task)
                    self?.taskService.onNextUpdateTaskStream(task: task)
                })
                .subscribe()
            return .empty()
        case let .setTitle(title):
            return .just(.updateTitle(title))
        case let .setDue(due):
            let dueString = DateFormatters.rfc3339.string(from: due)
            return .just(.updateDue(dueString))
        case let .setCompleted(completed):
            return .just(.updateCompleted(completed))
        case let .setNotes(note):
            return .just(.updateNotes(note))
        }
    }


    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTask(task):
            newState.task = task
            cachedTask = task
        case let .updateTitle(title):
            newState.task.title = title
        case let .updateNotes(notes):
            newState.task.notes = notes
        case let .updateCompleted(completed):
            newState.task.completed = completed
        case let .updateDue(due):
            newState.task.due = due
        }
        return newState
    }
}
