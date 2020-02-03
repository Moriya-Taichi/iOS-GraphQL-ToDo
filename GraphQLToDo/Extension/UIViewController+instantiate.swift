//
//  UIViewController+instantiate.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/03.
//  Copyright © 2020 Mori. All rights reserved.
//

import UIKit

enum StoryboardName: String {
    case tasks = "Tasks"
    case task  = "Task"
    case createTask = "CreateTask"
}

protocol StoryboardInstantiate {
    static var storyboardName: StoryboardName { get }
}

extension StoryboardInstantiate where Self: UIViewController {
    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: self.storyboardName.rawValue, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! Self
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = backButtonItem
        return viewController
    }
}
