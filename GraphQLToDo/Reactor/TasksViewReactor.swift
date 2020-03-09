//
//  TasksViewReactor.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/03.
//  Copyright © 2020 Mori. All rights reserved.
//

import ReactorKit
import RxSwift

enum CompletedSelect: String, CaseIterable {
    case all
    case completed
    case notCompleted
}

final class TasksViewReactor: Reactor {

    var initialState: State

    let taskService: TaskServiceType
    let taskRepository: TaskRepositoryType

    enum Action {
        case load
        case reload
        case loadTask(reload: Bool)
        case paginate
        case updateTask(TaskFields)
        case selectCompletedAndOrder(Int, Int)
    }

    enum Mutation {
        case setIsCompleted(Bool?)
        case setIsLoading(Bool)
        case setTaskOrder(TaskOrderFields)
        case setTasks(Pagination<CellItem>)
        case addNextTaskPage(Pagination<CellItem>)
        case updateTask(CellItem, Int)
    }

    struct State {
        var isLoading: Bool
        var tasks: Pagination<CellItem>
        var taskOrder: TaskOrderFields
        var isCompleted: Bool?

        var taskCellItemSection: CellItemSection {
            return CellItemSection.init(model: .task, items: tasks.pageElements)
        }

        var menuOrderOptions: [[String]] {
            let taskOrders = TaskOrderFields.allCases.compactMap { $0.rawValue }
            let completedSelects = CompletedSelect.allCases.compactMap { $0.rawValue }
            return [taskOrders, completedSelects]
        }
    }

    init(taskService: TaskServiceType, taskRepository: TaskRepositoryType) {
        self.taskService = taskService
        self.taskRepository  = taskRepository
        initialState = State(
            isLoading: false,
            tasks: .init(pageElements: [],
                         hasNextPage: true,
                         endCursor: ""),
            taskOrder: .latest,
            isCompleted: nil
        )
    }

    func transform(action: Observable<Action>) -> Observable<Action> {
        return .merge(
            action,
            taskService.createTaskStream.map { _ in .reload },
            taskService.updateTaskStream.map { .updateTask($0) }
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        let state = currentState
        switch action {
        case .load:
            self.load()
            return .empty()
        case .reload:
            self.reload()
            return .empty()
        case let .loadTask(reload):
            let startLoading: Observable<Mutation> = .just(.setIsLoading(true))
            let tasks = taskRepository.fetchTasks(completed: state.isCompleted,
                                               order: state.taskOrder,
                                               endCursor: "",
                                               hasNext: false,
                                               refetch: reload)
                .map { page in
                    let cellItem = page.pageElements.map { CellItem.task(
                        TaskCellReactor(taskService: self.taskService, repository: self.taskRepository, task: $0)
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
            let nextPage = taskRepository.fetchTasks(completed: state.isCompleted,
                                                  order: state.taskOrder,
                                                  endCursor: state.tasks.endCursor,
                                                  hasNext: state.tasks.hasNextPage,
                                                  refetch: false)
                .map { page in
                    let cellItem = page.pageElements.map { CellItem.task(
                        TaskCellReactor(taskService: self.taskService, repository: self.taskRepository, task: $0)
                        )
                    }

                    return Pagination(pageElements: cellItem,
                                      hasNextPage: page.hasNextPage,
                                      endCursor: page.endCursor)
            }
            .map(Mutation.addNextTaskPage)
            let endLoading: Observable<Mutation> = .just(.setIsLoading(false))
            return .concat([startLoading, nextPage, endLoading])
        case let .updateTask(task):
            let cellItem = CellItem.task(TaskCellReactor(taskService: self.taskService, repository: taskRepository, task: task))
            guard
                let index = state.tasks.pageElements.firstIndex(of: cellItem)
                else { return .empty() }
            return .just(.updateTask(cellItem, index))
        case let .selectCompletedAndOrder(row, component):
            switch state.menuOrderOptions[component][row] {
            case TaskOrderFields.latest.rawValue:
                return .just(.setTaskOrder(.latest))
            case TaskOrderFields.due.rawValue:
                return .just(.setTaskOrder(.due))
            case CompletedSelect.all.rawValue:
                return .just(.setIsCompleted(nil))
            case CompletedSelect.completed.rawValue:
                return .just(.setIsCompleted(true))
            case CompletedSelect.notCompleted.rawValue:
                return .just(.setIsCompleted(false))
            default:
                return .empty()
            }
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
        case let .updateTask(task, index):
            newState.tasks.pageElements[index] = task
        }
        return newState
    }
}

extension TasksViewReactor {
    private func load() {
        self.action.onNext(.loadTask(reload: false))
    }

    private func reload() {
        self.action.onNext(.loadTask(reload: true))
    }
}
