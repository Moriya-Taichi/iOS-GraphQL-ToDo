//
//  TasksViewReactor.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/03.
//  Copyright © 2020 Mori. All rights reserved.
//

import ReactorKit
import RxSwift

final class TasksViewReactor: Reactor {

    var initialState: State

    let taskService: TaskServiceType

    enum Action {
        case load
        case paginate
    }

    enum Mutation {
        case setIsCompleted(Bool)
        case setIsLoading(Bool)
        case setTaskOrder(TaskOrderFields)
        case setTasks(Pagination<CellItem>)
        case addNextTaskPage(Pagination<CellItem>)
    }

    struct State {
        var isLoading: Bool
        var tasks: Pagination<CellItem>
        var taskOrder: TaskOrderFields
        var isCompleted: Bool?

        var taskCellItemSection: CellItemSection {
            return CellItemSection.init(model: .task, items: tasks.pageElements)
        }
    }

    init(taskService: TaskServiceType) {
        self.taskService = taskService
        initialState = State(
            isLoading: false,
            tasks: .init(pageElements: [],
                         hasNextPage: true,
                         endCursor: ""),
            taskOrder: .latest,
            isCompleted: nil
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        let state = currentState
        switch action {
        case .load:
            let startLoading: Observable<Mutation> = .just(.setIsLoading(true))
            let tasks = taskService.fetchTasks(completed: state.isCompleted,
                                               order: state.taskOrder,
                                               endSursor: "",
                                               hasNext: false)
                .map { page in
                    let cellItem = page.pageElements.map { CellItem.task(
                        TaskCellReactor(taskService: self.taskService, task: $0)
                        )
                    }

                    return Pagination(pageElements: cellItem,
                                      hasNextPage: page.hasNextPage,
                                      endCursor: page.endCursor)
                }
                .map(Mutation.setTasks)
            let endLoading: Observable<Mutation> = .just(.setIsLoading(false))
            return .concat([startLoading, tasks, endLoading])
        case .paginate:
            guard
                state.tasks.hasNextPage && !state.tasks.endCursor.isEmpty
            else { return .empty() }
            let startLoading: Observable<Mutation> = .just(.setIsLoading(true))
            let nextPage = taskService.fetchTasks(completed: state.isCompleted,
                                                  order: state.taskOrder,
                                                  endSursor: state.tasks.endCursor,
                                                  hasNext: state.tasks.hasNextPage)
                .map { page in
                    let cellItem = page.pageElements.map { CellItem.task(
                        TaskCellReactor(taskService: self.taskService, task: $0)
                        )
                    }

                    return Pagination(pageElements: cellItem,
                                      hasNextPage: page.hasNextPage,
                                      endCursor: page.endCursor)
                }
                .map(Mutation.addNextTaskPage)
            let endLoading: Observable<Mutation> = .just(.setIsLoading(false))
            return .concat([startLoading, nextPage, endLoading])
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setIsLoading(isLoading):
            newState.isLoading = isLoading
        case let .setTasks(tasks):
            newState.tasks = tasks
        case let .addNextTaskPage(nextTaskPage):
            newState.tasks.append(nextTaskPage)
        case let .setTaskOrder(taskOrder):
            newState.taskOrder = taskOrder
        case let .setIsCompleted(isCompleted):
            newState.isCompleted = isCompleted
        }
        return newState
    }
}
