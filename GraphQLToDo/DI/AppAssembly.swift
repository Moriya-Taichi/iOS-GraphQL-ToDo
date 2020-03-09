//
//  AppAssembly.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/02.
//  Copyright © 2020 Mori. All rights reserved.
//

import Swinject
import SwinjectAutoregistration

final class AppAssembly: Assembly {
    func assemble(container: Container) {
        container
            .autoregister(GraphQLApiType.self, initializer: GraphQLApiProvider.init)
            .inObjectScope(.container)

        container
            .autoregister(TaskRepositoryType.self, initializer: TaskRepository.init)
            .inObjectScope(.container)

        container
            .autoregister(TaskServiceType.self, initializer: TaskService.init)
            .inObjectScope(.container)

        container
            .autoregister(AccessibleApolloStoreType.self,
                          initializer: AccessibleApolloStore.init)
            .inObjectScope(.container)
    }
}
