//
//  ToDoItem.swift
//  GestureDrivenTest
//
//  Created by Shani on 11/15/17.
//  Copyright © 2017 Shani Rivers. All rights reserved.
//

import Foundation

class ToDoItem: NSObject
{
    // A text description of this item
    var text: String

    // A boolean value that determines the completed state of this item
    var completed: Bool

    init(text: String)
    {
        self.text = text
        self.completed = false
    }

}
