//
//  Error+.swift
//  MVP
//
//  Created by Mohab Mowafy on 4/9/2021.
//  Copyright © 2021 Mohab Mowafy. All rights reserved.
//

import Foundation
protocol ValidatorError: Error {
    var associatedMessage: String { get }
}
extension NSError {
    class func create(description: String) -> NSError {
        return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: description])
    }
}

extension Error {
    func validatorError() -> ValidatorError {
        return self as! ValidatorError
    }
    
    var validatorErrorAssociatedMessage: String {
        return (self as! ValidatorError).associatedMessage
    }
}

func Log<T>(_ object: T?, filename: String = #file, line: Int = #line, funcname: String = #function) {
    #if DEBUG
    guard let object = object else { return }
    print("***** \(Date()) \(filename.components(separatedBy: "/").last ?? "") (line: \(line)) :: \(funcname) :: \(object)")
    #endif
}
