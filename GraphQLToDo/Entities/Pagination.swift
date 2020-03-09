//
//  Pagination.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/01.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation

struct Pagination<T: Equatable>: Equatable {

    var pageElements: [T]
    var hasNextPage: Bool
    var endCursor: String

    static func == (lhs: Pagination<T>, rhs: Pagination<T>) -> Bool {
        let isSameCursor   = lhs.endCursor == rhs.endCursor
        let isSameHasNext  = lhs.hasNextPage == rhs.hasNextPage
        let isSameElements = lhs.pageElements == rhs.pageElements
        return isSameCursor && isSameHasNext && isSameElements
    }

    mutating func append(_ nextPage: Self) {
        self.pageElements.append(contentsOf: nextPage.pageElements)
        self.hasNextPage = nextPage.hasNextPage
        self.endCursor = nextPage.endCursor
    }
}
