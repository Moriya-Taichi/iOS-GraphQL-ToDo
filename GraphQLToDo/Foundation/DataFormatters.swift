//
//  DataFormatters.swift
//  GraphQLToDo
//
//  Created by Mori on 2020/02/09.
//  Copyright © 2020 Mori. All rights reserved.
//

import Foundation

enum DateFormatters {
    static let rfc3339: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss ZZZZZ 'UTC'"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()
}
