//
//  GraphQLApiType.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/01/30.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation
import Apollo

protocol GraphQLApiType: ApiType {
    var client: ApolloClient { get }
    var rx: ReactiveGQLApiType { get }
}
