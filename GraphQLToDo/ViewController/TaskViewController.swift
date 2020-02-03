//
//  TaskViewController.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/03.
//  Copyright © 2020 Mori. All rights reserved.
//

import ReactorKit
import RxSwift
import UIKit

final class TaskViewController: UIViewController, StoryboardInstantiate {

    static var storyboardName: StoryboardName = .task

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension TaskViewController: StoryboardView {
    func bind(reactor: TaskViewReactor) {

    }
}
