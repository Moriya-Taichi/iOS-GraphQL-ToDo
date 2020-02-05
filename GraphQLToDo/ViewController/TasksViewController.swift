//
//  TasksViewController.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/03.
//  Copyright © 2020 Mori. All rights reserved.
//

import ReactorKit
import RxSwift
import UIKit

final class TasksViewController: UIViewController, StoryboardInstantiate {

    static var storyboardName: StoryboardName = .tasks

    var disposeBag = DisposeBag()

    var callback: Callback?

    struct Callback {
        let showTask:((_ identifier: String) -> Void)
        let showCreateTask: (() -> Void)
    }

    @IBOutlet weak var tasksTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension TasksViewController: StoryboardView {
    func bind(reactor: TasksViewReactor) {
        
    }
}
