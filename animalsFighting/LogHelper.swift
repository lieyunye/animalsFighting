//
//  LogHelper.swift
//  animalsFighting
//
//  Created by lieyunye on 8/26/15.
//  Copyright (c) 2015 lieyunye. All rights reserved.
//

import Foundation


class LogHelper {
    
    var log = Loggerithm() 
    
    class var sharedInstance : LogHelper {
        struct Static {
            static let instance : LogHelper = LogHelper()
        }
        return Static.instance
    }
}
