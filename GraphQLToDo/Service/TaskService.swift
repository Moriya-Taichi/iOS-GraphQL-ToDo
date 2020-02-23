//
//  TaskService.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/01.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation
import RxSwift

protocol TaskServiceType {

    var createTaskStream: Observable<TaskFields> { get }
    var updateTaskStream: Observable<TaskFields> { get }

    func fetchTasks(
        completed: Bool?,
        order: TaskOrderFields,
        endCursor: String,
        hasNext: Bool,
        refetch: Bool
    )
        -> Observable<Pagination<TaskFields>>

    func createTask(title: String,
                    notes: String?,
                    completed: Bool?,
                    due: String?)
        -> Observable<TaskFields>

    func updateTask(
        taskIdentifier: String,
        title: String?,
        notes: String?,
        completed: Bool?,
        due: String?)
        -> Observable<TaskFields>

    func onNextCreateTaskStream(task: TaskFields)
    func onNextUpdateTaskStream(task: TaskFields)
}

final class TaskService: TaskServiceType {

    let repository: TaskRepositoryType

    init(repository: TaskRepositoryType) {
        self.repository = repository
    }

    private let createTaskSubject = PublishSubject<TaskFields>()
    private let updateTaskSubject = PublishSubject<TaskFields>()

    var createTaskStream: Observable<TaskFields> {
        return createTaskSubject
    }

    var updateTaskStream: Observable<TaskFields> {
        return updateTaskSubject
    }

    func fetchTasks(
        completed: Bool? = nil,
        order: TaskOrderFields,
        endCursor: String,
        hasNext: Bool,
        refetch: Bool
    )
        -> Observable<Pagination<TaskFields>>
    {
        let page = endCursor.isEmpty ? PaginationInput(first: 20) : PaginationInput(first: 10,
                                                                                    after: endCursor)
        return repository.fetchTasks(input: TasksInput(completed: completed),
                                     orderBy: order,
                                     page: page,
                                     refetch: refetch)
            .asObservable()
            .map { $0.tasks }
            .map { response in
                let elements = response.edges.compactMap { $0?.node.fragments.taskFields }
                return Pagination(
                    pageElements: elements,
                    hasNextPage: response.pageInfo.fragments.pageInfoFields.hasNextPage,
                    endCursor: response.pageInfo.fragments.pageInfoFields.endCursor
                )
        }
    }

    func createTask(title: String,
                    notes: String? = nil,
                    completed: Bool? = nil,
                    due: String? = nil)
        -> Observable<TaskFields>
    {
        return repository.createTask(input: CreateTaskInput(
            title: title,
            notes: notes,
            completed: completed,
            due: due))
            .asObservable()
            .map { response in
                return response.createTask.fragments.taskFields
        }

    }

    func updateTask(
        taskIdentifier: String,
        title: String? = nil,
        notes: String? = nil,
        completed: Bool? = nil,
        due: String? = nil)
        -> Observable<TaskFields>
    {
        return repository.updateTask(input: UpdateTaskInput(
            taskId: taskIdentifier,
            title: title,
            notes: notes,
            completed: completed,
            due: due))
            .asObservable()
            .map { response in
                return response.updateTask.fragments.taskFields
        }
    }

    func onNextCreateTaskStream(task: TaskFields) {
        createTaskSubject.onNext(task)
    }

    func onNextUpdateTaskStream(task: TaskFields) {
        updateTaskSubject.onNext(task)
    }
}
