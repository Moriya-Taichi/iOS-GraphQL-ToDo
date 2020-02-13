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

    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var dueTextView: UITextView!
    @IBOutlet private weak var completedButton: UIButton!
    @IBOutlet private weak var notesTextView: UITextView!
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

        titleTextField.rx.text
            .distinctUntilChanged()
            .filterNil()
            .map(Reactor.Action.setTitle)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        notesTextView.rx.text
            .distinctUntilChanged()
            .filterNil()
            .map(Reactor.Action.setNotes)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        completedButton.rx.tap
            .map {[weak self] _ in self?.completedButton.isSelected }
            .filterNil()
            .map { !$0 }
            .map(Reactor.Action.setCompleted)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        inputDatePicker.rx.date
            .map(Reactor.Action.setDue)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map { $0.task }
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] task in
                self?.titleTextField.text = task.title
                self?.notesTextView.text = task.notes
                self?.completedButton.isSelected = task.completed
                if let dueString = task.due {
                    self?.dueTextView.text = String(dueString.prefix(dueString.count - 14))
                }
            }).disposed(by: disposeBag)
    }
}

extension TaskViewController: UITextViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
