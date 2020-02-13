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

    @IBOutlet private weak var titleTextFIeld: UITextField!
    @IBOutlet private weak var dueTextView: UITextView!
    @IBOutlet private weak var completedButton: UIButton!
    @IBOutlet private weak var notesTextField: UITextView!
    @IBOutlet private var inputDatePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        dueTextView.inputView = inputDatePicker
    }
}

extension TaskViewController: StoryboardView {
    func bind(reactor: TaskViewReactor) {

    }
}

extension TaskViewController: UITextViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
