//
//  TaskCoordinator.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/04.
//  Copyright © 2020 Mori. All rights reserved.
//

import SwinjectAutoregistration
import Swinject
import UIKit

final class TaskCoordinator: NavigationCoordinator, TaskPresentable {

    let navigationController: UINavigationController
    let resolver: Resolver

    init(presenter: UINavigationController, resolver: Resolver) {
        navigationController = presenter
        self.resolver = resolver
    }

    func start() {
        let tasksViewController = createTasksViewController()
        navigationController.viewControllers = [tasksViewController]
    }
}
