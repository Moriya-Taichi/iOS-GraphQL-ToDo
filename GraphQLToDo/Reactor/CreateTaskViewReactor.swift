//
//  CreateTaskViewReactor.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/03.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift

final class CreateTaskViewReactor: Reactor {

    var initialState: State

    private let taskService: TaskServiceType

    enum Action {
        case createTask
        case setTitle(String)
        case setDue(Date)
        case setNotes(String)
        case setIsCompleted(Bool)
    }

    enum Mutation {
        case setDue(Date)
        case setTitle(String)
        case setNotes(String)
        case setIsCompleted(Bool)
        case setIsCreated(Bool)
    }

    struct State {
        var title: String
        var notes: String?
        var due: Date?
        var isCompleted: Bool?

        var isCreated: Bool

        var isCreatable: Bool {
            return !title.isEmpty
        }
    }

    init(taskService: TaskServiceType) {
        self.taskService = taskService
        initialState = State(title: "",
                             notes: nil,
                             due: nil,
                             isCompleted: nil,
                             isCreated: false)
    }


    func mutate(action: Action) -> Observable<Mutation> {
        let state = currentState
        switch action {
        case .createTask:
            guard state.isCreatable else { return .empty() }
            let due = state.due == nil ? nil : DateFormatters.rfc3339.string(from: state.due!)
            let isCreated = taskService.createTask(title: state.title,
                                                   notes: state.notes,
                                                   completed: state.isCompleted,
                                                   due: due)
                .map { _ in true }
                .map(Mutation.setIsCreated)
            return isCreated
        case let .setTitle(title):
            return .just(.setTitle(title))
        case let .setNotes(notes):
            return .just(.setNotes(notes))
        case let .setIsCompleted(isCompleted):
            return .just(.setIsCompleted(isCompleted))
        case let .setDue(due):
            return .just(.setDue(due))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setIsCreated(isCreated):
            newState.isCreated = isCreated
        case let .setTitle(title):
            newState.title = title
        case let .setNotes(notes):
            newState.notes = notes
        case let .setDue(due):
            newState.due = due
        case let .setIsCompleted(isCompleted):
            newState.isCompleted = isCompleted
        }
        return newState
    }
}
