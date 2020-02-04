//
//  TaskPresentable.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/04.
//  Copyright © 2020 Mori. All rights reserved.
//

import SwinjectAutoregistration
import Swinject
import UIKit

protocol TaskPresentable: class {
    func showCreateTask()
    func showTask(identifier: String)
}

extension TaskPresentable where Self: NavigationCoordinator {

    func showCreateTask() {
        self.presenter.present(createCreateTaskViewController(), animated: true, completion: nil)
    }

    private func createCreateTaskViewController() -> CreateTaskViewController {
        let createTaskViewController = CreateTaskViewController.instantiate()
        createTaskViewController.reactor = CreateTaskViewReactor(taskService: resolver~>)
        createTaskViewController.callback = CreateTaskViewController.Callback(
            close: {
                createTaskViewController.dismiss(animated: false, completion: nil)
            }
        )
        return createTaskViewController
    }

    func showTask(identifier: String) {
        self.navigationController.pushViewController(createTaskViewController(identifier: identifier), animated: true)
    }

    private func createTaskViewController(identifier: String) -> TaskViewController {
        let taskViewController = TaskViewController.instantiate()
        taskViewController.reactor = TaskViewReactor(identifier: identifier, taskService: resolver~>)
        return taskViewController
    }

    func createTasksViewController() -> TasksViewController {
        let tasksViewController = TasksViewController.instantiate()
        tasksViewController.reactor = TasksViewReactor(taskService: resolver~>)
        tasksViewController.callback = TasksViewController.Callback(
            showTask: { identifier in
                self.showTask(identifier: identifier)
            },
            showCreateTask: {
                self.showCreateTask()
            }
        )
        return tasksViewController
    }
}
