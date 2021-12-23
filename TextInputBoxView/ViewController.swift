//
//  ViewController.swift
//  TextInputBoxView
//
//  Created by Damor on 2021/12/23.
//

import UIKit

final class ViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let openButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("열기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didTapOpen), for: .touchUpInside)
        return button
    }()
    
    private lazy var textInputBoxView: TextInputBoxView = {
        let view = TextInputBoxView(delegate: self, textViewMaximumHeight: 200)
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
        view.addSubview(label)
        
        let labelBottomConstraint = label.bottomAnchor.constraint(equalTo: openButton.topAnchor, constant: -15)
        labelBottomConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            openButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            openButton.heightAnchor.constraint(equalToConstant: 50),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            labelBottomConstraint,
        ])
    }
    
    @objc
    func didTapOpen() {
        textInputBoxView.open(anchorView: view)
    }
    
    @objc
    func didTapClose() {
        textInputBoxView.close()
    }
}

extension ViewController: TextInputBoxViewDelegate {
    func didTapComplete(_ text: String?) {
        label.text = text
    }
    
    func didTapInfoView() {
        print("## infoview ")
    }
}
