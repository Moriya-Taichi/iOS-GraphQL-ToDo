//
//  TaskFields+Equatable.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/01.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation

extension TaskFields: Equatable {
    public static func == (lhs: TaskFields, rhs: TaskFields) -> Bool {
        let isSameIdentifier = lhs.id == rhs.id
        let isSameTitle      = lhs.title == rhs.title
        let isSameNotes      = lhs.notes == rhs.notes
        let isSameDue        = lhs.due == rhs.due
        let isSameCompleted  = lhs.completed == rhs.completed
        return isSameIdentifier && isSameTitle && isSameNotes && isSameDue && isSameCompleted
    }
}
