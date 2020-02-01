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

}

final class TaskService: TaskServiceType {

    let repository: TaskRepositoryType

    init(repository: TaskRepositoryType) {
        self.repository = repository
    }

    func fetchTasks(
        completed: Bool? = nil,
        order: TaskOrderFields,
        endSursor: String,
        hasNext: Bool
    )
        -> Observable<Pagination<TaskFields>>
    {
        let page = endSursor.isEmpty ? PaginationInput(first: 20) : PaginationInput(first: 10,
                                                                                    after: endSursor)
        return repository.fetchTasks(input: TasksInput(completed: completed),
                                     orderBy: order,
                                     page: page)
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
}
