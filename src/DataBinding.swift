//
//  DataBinding.swift
//
//  Created by Jürgen F. Kilian on 18.02.17.
//  Copyright © 2017 Kilian IT-Consulting. All rights reserved.
//

import Foundation
import UIKit

/**
 * Updatestrategies between a (view)model and a view-controller == target
 */
enum UpdateValueStrategy {
    /// one way from view model to control
    case model2Target
    /// one way from control to view model
    case target2Model
    /// view model <-> control
    case both
}

/**
 * typically implemented by a view controller that connects controls with a view model
 * using a DataBindingContext
 */
protocol DataBindingContextOwner: class {
    var dataBindingContext: DataBindingContext {get}
}

extension DataBindingContextOwner {
    func updateModels(exclude: DataBinding? = nil) {
        dataBindingContext.updateModels(exclude: exclude)
    }
    func updateTargets(exclude: DataBinding? = nil) {
        dataBindingContext.updateTargets(exclude: exclude)
    }
}

protocol ObservableValue {
    associatedtype T

    weak var observedItem: NSObject? {get set}
    var controlEvent: UIControlEvents?  {get set}

    func getValue() -> T?
    func setValue(value: T)
}

extension ObservableValue {
    func addListener(_ listener: DataBinding, action: Selector) {
        if let ctrl = observedItem as? UIControl,
            let controlEvent = controlEvent {
            ctrl.addTarget(listener, action: action, for: controlEvent)
        } else {
            // log error, not supported??
        }
    }
}

/// a generic property wrapper that can be used for databinding
public class GenericProperty<T2>: ObservableValue {
    public typealias  T = T2

    /// the object that provides the property
    weak var observedItem: NSObject?

    /// generic accesors to property
    var getter: () -> T2?
    var setter: (T2) -> ()

    /// event that might trigger target->model updates
    var controlEvent: UIControlEvents?

    init(observedItem: NSObject,
                     getter: @escaping (() -> T),
                     setter: @escaping (T) -> ()) {
        self.observedItem = observedItem
        self.getter = getter
        self.setter = setter
    }

    fileprivate init(observedItem: NSObject, keyPath: String) {
        self.observedItem = observedItem
        self.getter = {
                        return (observedItem.value(forKey: keyPath) as? T)
        }
        self.setter = { value in
                observedItem.setValue(value, forKey: keyPath)
        }
    }

    func getValue() -> T2? {
        return getter()
    }

    func setValue(value : T2)  {
        setter(value)
    }
}

public class ReadOnlyProperty<T>: GenericProperty<T> {
    init(observedItem: NSObject,
         getter: @escaping (() -> T)) {
        super.init(observedItem: observedItem,
                   getter: getter,
                   setter: {value in /* we don't set anything */})
    }
}


public class TextProperty: GenericProperty<String> {
    override init(observedItem: NSObject, keyPath: String) {
        super.init(observedItem: observedItem, keyPath: keyPath)
    }
}

public class BoolProperty: GenericProperty<Bool> {
    override init(observedItem: NSObject, keyPath: String) {
        super.init(observedItem: observedItem, keyPath: keyPath)
    }
}

public class ColorProperty: GenericProperty<UIColor> {
    override init(observedItem: NSObject, keyPath: String) {
        super.init(observedItem: observedItem, keyPath: keyPath)
    }
}

public class ValueProperty: GenericProperty<Float> {
    override init(observedItem: NSObject, keyPath: String) {
        super.init(observedItem: observedItem, keyPath: keyPath)
    }
}


/// UI Targets
class UIControlProperty<T>: GenericProperty<T> {
    fileprivate init(observedCtrl: UIView, keyPath: String, controlEvent: UIControlEvents?) {
        super.init(observedItem: observedCtrl, keyPath: keyPath)
        self.controlEvent = controlEvent
    }
}

/// convenice class to create pre-defined properties
class UIPropertyFactory {
    public static func text(observedCtrl: UILabel) ->  UIControlProperty<String> {
        return UIControlProperty<String>(observedCtrl: observedCtrl,
                                 keyPath: #keyPath(UILabel.text),
                                controlEvent: UIControlEvents.editingChanged)
    }

    public static func text(observedCtrl: UITextView) ->  UIControlProperty<String> {
        return UIControlProperty<String>(observedCtrl: observedCtrl,
                                     keyPath: #keyPath(UITextView.text),
                                     controlEvent: UIControlEvents.editingChanged)
    }

    public static func text(observedCtrl: UITextField) ->  UIControlProperty<String> {
        return UIControlProperty<String>(observedCtrl: observedCtrl,
                                     keyPath: #keyPath(UITextField.text),
                                     controlEvent: UIControlEvents.editingChanged)
    }


    public static func bool(observedCtrl: UIButton, keyPath: String) ->  UIControlProperty<Bool> {
        return UIControlProperty<Bool>(observedCtrl: observedCtrl,
                                     keyPath: keyPath,
                                     controlEvent: UIControlEvents.valueChanged)
    }

    public static func bool(observedCtrl: UISlider, keyPath: String) ->  UIControlProperty<Float> {
        return UIControlProperty<Float>(observedCtrl: observedCtrl,
                                          keyPath: #keyPath(UISlider.value),
                                       controlEvent: UIControlEvents.valueChanged)
    }


    public static func backgroundColor(observedCtrl: UIView) ->  UIControlProperty<UIColor> {
        return UIControlProperty<UIColor>(observedCtrl: observedCtrl,
                                      keyPath: #keyPath(UIView.backgroundColor),
                                      controlEvent: nil)
    }

    public static func bool(observedCtrl: UIView, keyPath: String) ->  UIControlProperty<Bool> {
        return UIControlProperty<Bool>(observedCtrl: observedCtrl,
                                     keyPath: keyPath,
                                     controlEvent: nil)
    }
    public static func bool(observedCtrl: UISwitch) ->  UIControlProperty<Bool> {
        return UIControlProperty<Bool>(observedCtrl: observedCtrl,
                                        keyPath: #keyPath(UISwitch.isOn),
                                        controlEvent: UIControlEvents.valueChanged)
    }
    public static func value(observedCtrl: UISlider) ->  UIControlProperty<Float> {
        return UIControlProperty<Float>(observedCtrl: observedCtrl,
                                       keyPath: #keyPath(UISlider.value),
                                       controlEvent: UIControlEvents.valueChanged)
    }
}

// MARK: DataBinding main classes

/// base protocol for databinding instances
protocol DataBinding {
    var updateValueStrategy: UpdateValueStrategy {get set}
    func updateModel()
    func updateTarget()
}


/// databinding that connects a pair of target/model properties
class GenericDataBinding<O: ObservableValue>: DataBinding {

    var updateValueStrategy: UpdateValueStrategy

    /// typically wraps a control property
    fileprivate var target: O

    /// typically wraps a model property
    fileprivate var model: O

    init(target: O,
         model:  O,
         updateValueStrategy: UpdateValueStrategy = UpdateValueStrategy.both) {

        self.target = target
        self.model = model
        self.updateValueStrategy = updateValueStrategy

        if updateValueStrategy == .both || updateValueStrategy == .target2Model {
            target.addListener(self, action: #selector(updateModel))
        }
    }

    @objc func updateModel() {
        if let value = target.getValue()  {
            model.setValue(value: value)
        }
    }

    func updateTarget() {
        if let value = model.getValue() {
            target.setValue(value: value)
        }
    }
}

/// Data Binding Context, it should hold all data bindings for a view controller
public class DataBindingContext {

    var dataBindings = [DataBinding]()

    @discardableResult
    func bindValue<O: ObservableValue>(target: O,
                                       model: O,
                                     updateValueStrategy: UpdateValueStrategy = .both) -> DataBinding {

        return appendDataBinding(GenericDataBinding(target: target,
                                                       model: model,
                                                       updateValueStrategy: updateValueStrategy))
    }

    func appendDataBinding(_ dataBinding: DataBinding) -> DataBinding {
        dataBindings.append(dataBinding)

        if dataBinding.updateValueStrategy != .target2Model {
            dataBinding.updateTarget()
        }
        return dataBinding
    }

    func updateModels(exclude: DataBinding? = nil) {
        for observer in dataBindings.filter({ (current) -> Bool in
                current.updateValueStrategy != .model2Target
            })
        {
                observer.updateModel()
        }
    }

    func updateTargets(exclude: DataBinding? = nil) {
        for observer in dataBindings.filter({ (current) -> Bool in
                current.updateValueStrategy != .target2Model
            })
        {
            observer.updateTarget()
        }
    }
}
