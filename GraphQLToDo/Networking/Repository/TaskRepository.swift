//
//  TaskRepository.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/01.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation
import RxSwift

protocol TaskRepositoryType: GraphQLRepositoryType {
    func fetchTasks(input: TasksInput, orderBy: TaskOrderFields, page: PaginationInput) -> Single<TasksQuery.Data>

    func createTask(input: CreateTaskInput) -> Single<CreateTaskMutation.Data>
    func updateTask(input: UpdateTaskInput) -> Single<UpdateTaskMutation.Data>
}

final class TaskRepository: TaskRepositoryType {

    var provider: GraphQLApiType

    init(provider: GraphQLApiType) {
        self.provider = provider
    }

    func fetchTasks(
        input: TasksInput,
        orderBy: TaskOrderFields,
        page: PaginationInput
    )
        -> Single<TasksQuery.Data> {
            return provider.rx.fetch(query: TasksQuery(input: input,
                                                       orderBy: orderBy,
                                                       page: page),
                                     cachePolicy: .returnCacheDataElseFetch,
                                     queue: .global())
    }

    func createTask(input: CreateTaskInput) -> Single<CreateTaskMutation.Data> {
        return provider.rx.perform(mutation: CreateTaskMutation(input: input),
                                   queue: .global())
    }

    func updateTask(input: UpdateTaskInput) -> Single<UpdateTaskMutation.Data> {
        return provider.rx.perform(mutation: UpdateTaskMutation(input: input),
                                   queue: .global())
    }
}
