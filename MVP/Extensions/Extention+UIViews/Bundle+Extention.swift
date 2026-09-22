//
//  Bundle+Extention.swift
//  Courses
//
//  Created by Mohab on 7/31/21.
//

import Foundation
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
