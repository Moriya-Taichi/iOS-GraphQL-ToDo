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

final class TaskCoordinator: TaskDelegate {

    let navigationController: UINavigationController
    var presenter: UIViewController {
        return navigationController
    }
    let resolver: Resolver

    init(presenter: UINavigationController, resolver: Resolver) {
        navigationController = presenter
        self.resolver = resolver
    }

    func start() {
        let tasksViewController = createTasksViewController()
        tasksViewController.delegate = self
        navigationController.viewControllers = [tasksViewController]
    }
}
