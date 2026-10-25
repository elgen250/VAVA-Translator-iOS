import WidgetKit
import SwiftUI

/// Widget Bundle declaring all interactive home screen and lock screen widgets for VAVA Translator.
@main
struct VAVAWidgetBundle: WidgetBundle {
    var body: some Widget {
        VAVAInteractiveWidget()
    }
}
