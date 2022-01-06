//
//  TextInputBoxView.swift
//  TextInputBoxView
//
//  Created by Damor on 2021/12/23.
//

import UIKit

protocol TextInputBoxViewDelegate: AnyObject {
    func didTapComplete(_ text: String?)
    func didTapInfoView()
}

final class TextInputBoxView: UIView {
    weak var anchorView: UIView?
    weak var delegate: TextInputBoxViewDelegate?
    
    // MARK: - Private Properties
    private let textViewTopMargin: CGFloat = 10.0
    private var textViewMaximumHeight: CGFloat = 100.0
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(inputBoxStackView)
        stackView.clipsToBounds = true
        stackView.layer.cornerRadius = 15
        stackView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        return stackView
    }()
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = topViewBackgroundColor
        view.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapInfoView))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.addSubview(infoLabel)
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.textColor = textColor
        textView.returnKeyType = .continue
        textView.font = font
        textView.contentInset = UIEdgeInsets(top: textViewTopMargin, left: 15, bottom: textViewTopMargin, right: 15)
        return textView
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)
        button.backgroundColor = buttonBackgroundColor
        button.setTitleColor(buttonTitleColor, for: .normal)
        button.setTitleColor(buttonTitleDisabledColor, for: .disabled)
        return button
    }()
    
    private lazy var inputBoxStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.backgroundColor = .white
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(completeButton)
        return stackView
    }()
    
    private lazy var textViewHeightConstraint: NSLayoutConstraint = {
        return textView.heightAnchor.constraint(equalToConstant: textViewEstimatedHeight)
    }()
    
    private lazy var containerViewBottomConstraint: NSLayoutConstraint = {
        return containerStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
    }()
    
    // MARK: - Internal Properties
    var dimColor: UIColor = .black.withAlphaComponent(0.5) {
        didSet {
            backgroundColor = dimColor
        }
    }
    
    var textColor: UIColor = .black {
        didSet {
            textView.textColor = textColor
        }
    }
    
    var font: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            textView.font = font
        }
    }
    
    var buttonTitle: String = "완료" {
        didSet {
            completeButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    var buttonTitleColor: UIColor = .systemBlue {
        didSet {
            completeButton.setTitleColor(buttonTitleColor, for: .normal)
        }
    }
    
    var buttonTitleDisabledColor: UIColor = .lightGray {
        didSet {
            completeButton.setTitleColor(buttonTitleDisabledColor, for: .disabled)
        }
    }
    
    var buttonBackgroundColor: UIColor = .white {
        didSet {
            completeButton.backgroundColor = buttonBackgroundColor
        }
    }
    
    var topViewBackgroundColor: UIColor = .lightGray {
        didSet {
            topView.backgroundColor = topViewBackgroundColor
        }
    }
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        addGestureRecognizer(backgroundTapGesture)
        backgroundColor = dimColor
        
        registKeyboardObserver()
    }
    
    deinit {
        removeKeyboardObserver()
    }
    
    convenience init(delegate: TextInputBoxViewDelegate, textViewMaximumHeight: CGFloat = 100) {
        self.init(frame: .zero)
        self.delegate = delegate
        self.textViewMaximumHeight = textViewMaximumHeight
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerViewBottomConstraint,
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            completeButton.widthAnchor.constraint(equalToConstant: 60),
            completeButton.heightAnchor.constraint(equalToConstant: 50),
            textViewHeightConstraint,
            
            topView.heightAnchor.constraint(equalToConstant: 80),
            infoLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 15),
            infoLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -15),
            infoLabel.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
        ])
    }
    
    @objc
    func didTapComplete() {
        delegate?.didTapComplete(textView.text)
        textView.text = nil
        textViewDidChange(textView)
    }
    
    @objc
    func didTapInfoView() { delegate?.didTapInfoView() }
    
    @objc
    func didTapBackground() { detach() }
    
    private func checkAvailable() {
        completeButton.isEnabled = !textView.text.isEmpty
    }

    //MARK: - Keyboard Event
    private func registKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    func keyboardWillShow(_ sender: Notification) {
        guard let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        containerViewBottomConstraint.constant = -(keyboardHeight - safeAreaInsets.bottom)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    @objc
    func keyboardWillHide(_ sender: Notification) {
        containerViewBottomConstraint.constant = 0
    }
}

extension TextInputBoxView {
    func attach(to anchorView: UIView) {
        setupViews()
        checkAvailable()
        
        UIView.transition(with: anchorView, duration: 0.1, options: .transitionCrossDissolve) { [weak self] in
            guard let self = self else { return }
            anchorView.addSubview(self)
            NSLayoutConstraint.activate([
                self.topAnchor.constraint(equalTo: anchorView.topAnchor),
                self.leadingAnchor.constraint(equalTo: anchorView.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: anchorView.trailingAnchor),
                self.bottomAnchor.constraint(equalTo: anchorView.bottomAnchor)
            ])
        } completion: { [weak self] _ in
            self?.textView.becomeFirstResponder()
        }
        
        self.anchorView = anchorView
    }
    
    @discardableResult
    func detach() -> String? {
        guard let anchorView = anchorView else { return textView.text }
        textView.resignFirstResponder()
        
        UIView.transition(with: anchorView, duration: 0.1, options: .transitionCrossDissolve) { [weak self] in
            self?.removeFromSuperview()
        } completion: { _ in }
        
        self.anchorView = nil
        
        return textView.text
    }
}

extension TextInputBoxView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkAvailable()
        textViewHeightConstraint.constant = min(textViewEstimatedHeight, textViewMaximumHeight)
    }
    
    private var textViewEstimatedHeight: CGFloat {
        let size = CGSize(width: frame.width, height: .infinity)
        return textView.sizeThatFits(size).height + (textViewTopMargin * 2)
    }
}
