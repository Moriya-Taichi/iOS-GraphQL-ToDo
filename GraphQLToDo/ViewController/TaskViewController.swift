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

    @IBOutlet private weak var duePlaceholderLabel: UILabel!
    @IBOutlet private weak var notesPlaceholderLabel: UILabel!
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

        Observable<Void>.just(())
            .map { _ in Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        rx.viewWillDisApper
            .map { _ in Reactor.Action.updateTask }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

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
            .skip(1)
            .map(Reactor.Action.setDue)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map { $0.task }
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] task in
                self?.titleTextField.text = task.title
                self?.notesTextView.text = task.notes
                self?.completedButton.isSelected = task.completed

                self?.notesPlaceholderLabel.isHidden = !task.notes.isEmpty

            }).disposed(by: disposeBag)

        reactor.state.map { $0.dueSteing }
            .debug()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in
                self?.dueTextView.text = $0
                self?.duePlaceholderLabel.isHidden = !($0?.isEmpty ?? true)
            }).disposed(by: disposeBag)
    }
}

extension TaskViewController: UITextViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
