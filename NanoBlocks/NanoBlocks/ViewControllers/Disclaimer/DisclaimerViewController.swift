//
//  DisclaimerViewController.swift
//  NanoBlocks
//
//  Created by Ben Kray on 5/18/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit
import SnapKit

class DisclaimerViewController: TransparentNavViewController {

    lazy private(set) var headerLabel: UILabel = {
       let l = UILabel()
        l.text = "Disclaimer"
        l.font = AppStyle.Font.title
        l.textColor = .white
       return l
    }()
    lazy private(set) var textView: UITextView = {
        let t = UITextView()
        t.backgroundColor = .clear
        t.textColor = .white
        t.font = AppStyle.Font.body
        return t
    }()
    lazy private(set) var separator: UIView = {
        let v = UIView()
        v.backgroundColor = AppStyle.Color.superLowAlphaBlack
        return v
    }()
    lazy private(set) var acceptButton = UIButton(type: .custom)
    lazy private(set) var declineButton = UIButton(type: .custom)
    lazy private(set) var buttonStack = UIStackView()
    var onDecision: ((Bool) -> Void)?
    let showButtons: Bool
    
    init(showButtons: Bool = true) {
        self.showButtons = showButtons
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(textView)
        if showButtons {
            buttonStack.axis = .horizontal
            buttonStack.distribution = .fillEqually
            buttonStack.addArrangedSubview(acceptButton)
            buttonStack.addArrangedSubview(declineButton)
            view.addSubview(buttonStack)
        }
        view.addSubview(headerLabel)
        view.addSubview(separator)
        buildView()
    }

    // MARK: - Setup
    
    fileprivate func buildView() {
        ["Accept": acceptButton, "Decline": declineButton].forEach {
            $0.value.setTitle($0.key, for: .normal)
            $0.value.titleLabel?.font = AppStyle.Font.control
            $0.value.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        }
        if showButtons {
            buttonStack.snp.makeConstraints { (make) in
                make.height.equalTo(70)
                if #available(iOS 11.0, *) {
                    make.bottomMargin.equalTo(self.view.safeAreaInsets.bottom)
                } else {
                    make.bottomMargin.equalToSuperview().offset(AppStyle.Size.padding)
                }
                make.left.right.equalToSuperview()
            }
            separator.snp.makeConstraints { (make) in
                make.center.equalTo(buttonStack.snp.center)
                make.height.equalTo(50)
                make.width.equalTo(1)
            }
        } else {
            textView.textColor = .black
            headerLabel.textColor = .black
            view.backgroundColor = .white
        }
        headerLabel.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin).offset(AppStyle.Size.smallPadding)
            } else {
                make.top.equalToSuperview().offset(AppStyle.Size.padding)
            }
            make.left.equalToSuperview().offset(AppStyle.Size.padding)
            make.right.equalToSuperview().inset(AppStyle.Size.padding)
            make.height.equalTo(AppStyle.Size.padding)
        }
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(AppStyle.Size.padding)
            make.right.equalToSuperview().inset(AppStyle.Size.padding)
            if showButtons {
                make.bottom.equalTo(buttonStack.snp.top).offset(-8)
            } else {
                if #available(iOS 11.0, *) {
                    make.bottomMargin.equalTo(self.view.safeAreaInsets.bottom)
                } else {
                    make.bottomMargin.equalToSuperview().offset(AppStyle.Size.padding)
                }
            }
        }
        let disclaimer = "The software you are about to use, \"Nano Blocks\", is free and open source. The software does not constitute an account where Planar Form LLC serves as financial intermediaries or custodians of your Nano. While the software has undergone beta testing and continues to be improved by feedback from the community, we, Planar Form LLC, cannot guarantee that the software is bug free. You acknowledge that your use of this software is at your own risk and in compliance with all applicable laws. You are responsible for safekeeping your passwords, seeds, private keys, and any other codes (wallet related data) you use to access the software. Planar Form LLC cannot retrieve any wallet related data if you lose or forget them."
        let openSourceLiability = "THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\nWe reserve the right to modify this disclaimer from time to time."
        textView.text = "In order to proceed, you must read and accept the following disclaimer.\n\n\(disclaimer)\n\n\(openSourceLiability)"
        textView.isEditable = false
        acceptButton.addTarget(self, action: #selector(acceptPressed), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(declinePressed), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(.zero, animated: false)
    }
    
    // MARK: - Actions
    
    @objc fileprivate func acceptPressed() {
        onDecision?(true)
    }
    
    @objc fileprivate func declinePressed() {
        onDecision?(false)
    }
}
