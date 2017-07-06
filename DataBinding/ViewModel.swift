//
//  ViewModel.swift
//  DataBinding
//
//  Created by Jürgen F. Kilian on 06.07.17.
//  Copyright © 2017 Kilian IT-Consulting. All rights reserved.
//

import UIKit


class ViewModel: NSObject {
    weak var delegate: DataBindingContextOwner?
    var dataModel = DataModel()

    init(delegate: DataBindingContextOwner) {
        self.delegate = delegate
    }

    var name: String {
        get {
            return dataModel.name
            delegate?.updateTargets()
        }
        set {
            dataModel.name = newValue
        }
    }

    var value: Float {
        get {
            return dataModel.value
        }
        set {
            dataModel.value = newValue
            delegate?.updateTargets()
        }
    }

    var state: Bool {
        get {
            return dataModel.state
        }
        set {
            dataModel.state = newValue
            delegate?.updateTargets()
        }
    }

    var backGroundColor: UIColor {
        return dataModel.state ? UIColor.green : UIColor.yellow
    }

    var valueAsString : String {
        get {
            return "\(Int(value * 100))"
        }
        set {
            if let n = NumberFormatter().number(from: newValue) {
                value = n.floatValue / 100
            } else {
                value = 0
            }
        }
    }

}
