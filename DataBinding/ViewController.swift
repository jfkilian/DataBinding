//
//  ViewController.swift
//  DataBinding
//
//  Created by Jürgen F. Kilian on 06.07.17.
//  Copyright © 2017 Kilian IT-Consulting. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DataBindingContextOwner {
    let dataBindingContext = DataBindingContext()

    var viewModel: ViewModel?


    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderValue: UITextField!
    @IBOutlet weak var state: UISwitch!
    @IBOutlet weak var name: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        initDataBinding()
    }

    func initDataBinding() {
        viewModel = ViewModel(delegate: self)
        if let viewModel = viewModel {
            dataBindingContext.bindValue(target: UIPropertyFactory.value(observedCtrl: slider),
                                         model: GenericProperty(observedItem: viewModel,
                                                                getter: {return viewModel.value},
                                                                setter: {value in
                                                                    viewModel.value = value})
            )

            dataBindingContext.bindValue(target: UIPropertyFactory.text(observedCtrl: sliderValue),
                                         model: GenericProperty(observedItem: viewModel,
                                                                getter: {return viewModel.valueAsString},
                                                                setter: {value in
                                                                    viewModel.valueAsString = value})
            )
            dataBindingContext.bindValue(target: UIPropertyFactory.bool(observedCtrl: state),
                                         model: GenericProperty(observedItem: viewModel,
                                                                getter: {return viewModel.state},
                                                                setter: {value in
                                                                    viewModel.state = value})

            )
            dataBindingContext.bindValue(target: UIPropertyFactory.text(observedCtrl: name),
                                         model: GenericProperty(observedItem: viewModel,
                                                                getter: {return viewModel.name},
                                                                setter: {value in
                                                                    viewModel.name = value})
            )

            dataBindingContext.bindValue(target: UIPropertyFactory.backgroundColor(observedCtrl: view),
                                         model: ReadOnlyProperty(observedItem: viewModel,
                                                                getter: {return viewModel.backGroundColor}),
                                         updateValueStrategy: UpdateValueStrategy.model2Target
            )


        }
    }

}

