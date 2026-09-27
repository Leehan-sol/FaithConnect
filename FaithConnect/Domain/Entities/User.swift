//
//  User.swift
//  FaithConnect
//
//  Created by hansol on 2025/12/21.
//

import Foundation

struct User {
    let name: String
    let nickname: String
    let email: String
    let churchName: String
    let workspaceType: WorkspaceType
    let community: Community?
    let role: UserRole

    var isManna: Bool { workspaceType == .manna }
}
