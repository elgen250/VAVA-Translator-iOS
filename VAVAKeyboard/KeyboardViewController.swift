import UIKit
import SwiftUI

/// Main input view controller managing the custom translating VAVA Keyboard.
public class KeyboardViewController: UIInputViewController {

    private var hostingController: UIHostingController<KeyboardRootView>?

    public override func viewDidLoad() {
        super.viewDidLoad()

        let rootView = KeyboardRootView(
            onInsertText: { [weak self] text in
                self?.textDocumentProxy.insertText(text)
            },
            onDeleteBackward: { [weak self] in
                self?.textDocumentProxy.deleteBackward()
            },
            onReturn: { [weak self] in
                self?.textDocumentProxy.insertText("\n")
            },
            onDismiss: { [weak self] in
                self?.dismissKeyboard()
            },
            onNextKeyboard: { [weak self] in
                self?.advanceToNextInputMode()
            },
            needsInputModeSwitchKey: self.needsInputModeSwitchKey
        )

        let host = UIHostingController(rootView: rootView)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear

        addChild(host)
        view.addSubview(host.view)

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 260)
        ])

        host.didMove(toParent: self)
        self.hostingController = host
    }

    public override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        // Proxy context updates if needed
    }
}
