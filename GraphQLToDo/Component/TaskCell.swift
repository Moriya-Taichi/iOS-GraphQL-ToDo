//
//  TaskCell.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/04.
//  Copyright © 2020 Mori. All rights reserved.
//

import ReactorKit
import RxSwift
import UIKit

final class TaskCell: UITableViewCell {

    var disposeBag  = DisposeBag()

    @IBOutlet private weak var checkCompletedButton: UIButton! {
        didSet {
            checkCompletedButton.setImage(#imageLiteral(resourceName: "CheckImage").withRenderingMode(.alwaysOriginal), for: .normal)
            checkCompletedButton.setImage(#imageLiteral(resourceName: "CheckedImage").withRenderingMode(.alwaysOriginal), for: .selected)
        }
    }
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var notes: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setCellContents(task: TaskFields)  {
        self.checkCompletedButton.isSelected = task.completed
        self.titleLabel.text = task.title
        self.notes.text = task.notes
        self.dateLabel.text = task.due
    }
}

extension TaskCell: StoryboardView {
    func bind(reactor: TaskCellReactor) {

        reactor.state.map { $0.task }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] task in
                self?.setCellContents(task: task)
            })
            .disposed(by: disposeBag)

        checkCompletedButton.rx
            .tap
            .map{ _ in Reactor.Action.complete }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
