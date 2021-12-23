//
//  ViewController.swift
//  TextInputBoxView
//
//  Created by Damor on 2021/12/23.
//

import UIKit

class ViewController: UIViewController {

    private let openButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("열기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didTapOpen), for: .touchUpInside)
        return button
    }()
    
    private lazy var textInputBoxView: TextInputBoxView = {
        let view = TextInputBoxView(delegate: self)
        view.textColor = .black
        view.infoLabel.text = "Hello Damor"
        view.buttonTitleColor = .blue
        view.buttonTitleDisabledColor = .lightGray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(openButton)
        
        NSLayoutConstraint.activate([
            openButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            openButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    @objc
    func didTapOpen() {
        textInputBoxView.show(container: view)
    }
    
    @objc
    func didTapClose() {
        textInputBoxView.dismiss()
    }
}

extension ViewController: TextInputBoxViewDelegate {
    func didTapComplete(_ text: String?) {
        print("## text ", text ?? "")
    }
    
    func didTapInfoView() {
        print("## infoview ")
    }
}
