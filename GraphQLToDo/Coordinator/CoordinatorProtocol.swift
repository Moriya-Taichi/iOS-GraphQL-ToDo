//
//  CoordinatorProtocol.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/04.
//  Copyright © 2020 Mori. All rights reserved.
//

import Swinject
import UIKit

protocol Coordinator: class {
    var resolver: Resolver { get }
    func start()
}

protocol ContainerCoordinator: Coordinator {
    var presenter: UIViewController { get }
}

protocol NavigationCoordinator: ContainerCoordinator {
    var navigationController: UINavigationController { get }
}

extension NavigationCoordinator {
    var presenter: UIViewController { return navigationController }
}


