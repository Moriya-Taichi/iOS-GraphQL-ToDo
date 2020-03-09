//
//  GraphQLRepositoryType.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/01/30.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation

protocol GraphQLRepositoryType {

    var provider: GraphQLApiType { get }

    init(provider: GraphQLApiType)
}
