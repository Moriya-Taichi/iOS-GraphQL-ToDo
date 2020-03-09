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

protocol TaskDelegate: AnyObject {
    var resolver: Resolver { get }
}

extension TaskDelegate {

    func createCreateTaskViewController() -> CreateTaskViewController {
        let createTaskViewController = CreateTaskViewController.create()
        createTaskViewController.modalTransitionStyle = .crossDissolve
        createTaskViewController.reactor = CreateTaskViewReactor(taskService: resolver~>, taskRepository: resolver~>)
        createTaskViewController.delegate = self
        return createTaskViewController
    }

    func createTaskViewController(identifier: String) -> TaskViewController {
        let taskViewController = TaskViewController.create()
        taskViewController.reactor = TaskViewReactor(identifier: identifier,
                                                     taskService: resolver~>,
                                                     taskRepository: resolver~>,
                                                     accessibleApolloStore: resolver~>)
        return taskViewController
    }

    func createTasksViewController() -> TasksViewController {
        let tasksViewController = TasksViewController.create()
        tasksViewController.reactor = TasksViewReactor(taskService: resolver~>, taskRepository: resolver~>)
        tasksViewController.delegate = self
        return tasksViewController
    }

    func close(vc: UIViewController) {
        vc.dismiss(animated: true)
    }

    func showTask(identifier: String, vc: UIViewController) {
        vc.navigationController?.pushViewController(createTaskViewController(identifier: identifier), animated: true)
    }

    func showCreateTask(vc: UIViewController) {
        vc.present(createCreateTaskViewController(), animated: true, completion: nil)
    }
}
