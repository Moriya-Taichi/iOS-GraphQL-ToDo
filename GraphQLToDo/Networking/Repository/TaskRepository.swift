//
//  TaskRepository.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/01.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation
import RxSwift
import Apollo

protocol TaskRepositoryType: GraphQLRepositoryType {
    func fetchTasks(
        completed: Bool?,
        order: TaskOrderFields,
        endCursor: String,
        hasNext: Bool,
        refetch: Bool
    )
        -> Observable<Pagination<TaskFields>>

    func updateTask(
        taskIdentifier: String,
        title: String?,
        notes: String?,
        completed: Bool?,
        due: String?)
        -> Observable<TaskFields>

    func createTask(title: String,
                    notes: String?,
                    completed: Bool?,
                    due: String?)
        -> Observable<TaskFields>
}

final class TaskRepository: TaskRepositoryType {

    let provider: GraphQLApiType

    init(provider: GraphQLApiType) {
        self.provider = provider
    }

    private func baseFetchTasks(
        input: TasksInput,
        orderBy: TaskOrderFields,
        page: PaginationInput,
        refetch: Bool
    )
        -> Single<TasksQuery.Data> {
            let cachePolicy: CachePolicy = refetch ? .fetchIgnoringCacheData : .returnCacheDataElseFetch
            return provider.rx.fetch(query: TasksQuery(input: input,
                                                       orderBy: orderBy,
                                                       page: page),
                                     cachePolicy: cachePolicy,
                                     queue: .global())
    }

    private func baseCreateTask(input: CreateTaskInput) -> Single<CreateTaskMutation.Data> {
        return provider.rx.perform(mutation: CreateTaskMutation(input: input),
                                   queue: .global())
    }

    private func baseUpdateTask(input: UpdateTaskInput) -> Single<UpdateTaskMutation.Data> {
        return provider.rx.perform(mutation: UpdateTaskMutation(input: input),
                                   queue: .global())
    }

    func fetchTasks(
        completed: Bool?,
        order: TaskOrderFields,
        endCursor: String,
        hasNext: Bool,
        refetch: Bool
    )
        -> Observable<Pagination<TaskFields>>
    {
        let page = endCursor.isEmpty ? PaginationInput(first: 20) : PaginationInput(first: 10,
                                                                                    after: endCursor)
        return baseFetchTasks(input: TasksInput(completed: completed),
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
                    notes: String?,
                    completed: Bool?,
                    due: String?)
        -> Observable<TaskFields>
    {
        return baseCreateTask(input: CreateTaskInput(
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
        title: String?,
        notes: String?,
        completed: Bool?,
        due: String?)
        -> Observable<TaskFields>
    {
        return baseUpdateTask(input: UpdateTaskInput(
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
}
