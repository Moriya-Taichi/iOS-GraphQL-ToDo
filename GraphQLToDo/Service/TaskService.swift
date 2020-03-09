//
//  TaskService.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/01.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation
import RxSwift

protocol TaskServiceType {

    var createTaskStream: Observable<TaskFields> { get }
    var updateTaskStream: Observable<TaskFields> { get }

    func onNextCreateTaskStream(task: TaskFields)
    func onNextUpdateTaskStream(task: TaskFields)
}

final class TaskService: TaskServiceType {

    private let createTaskSubject = PublishSubject<TaskFields>()
    private let updateTaskSubject = PublishSubject<TaskFields>()

    var createTaskStream: Observable<TaskFields> {
        return createTaskSubject
    }

    var updateTaskStream: Observable<TaskFields> {
        return updateTaskSubject
    }

    func onNextCreateTaskStream(task: TaskFields) {
        createTaskSubject.onNext(task)
    }

    func onNextUpdateTaskStream(task: TaskFields) {
        updateTaskSubject.onNext(task)
    }
}
