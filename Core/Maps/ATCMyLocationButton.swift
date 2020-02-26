//
//  ATCMyLocationButton.swift
//  ClassifiedsApp
//
//  Created by Florian Marcu on 9/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import SwiftUI

protocol ATCMyLocationButtonDelegate: class {
    func myLocationButtonDidTap()
}

struct ATCMyLocationButton: View {
    weak var delegate: ATCMyLocationButtonDelegate?

    @State var uiConfig: ATCUIGenericConfigurationProtocol

    var body: some View {
        VStack(alignment: .center) {
            Button(action: {
                self.delegate?.myLocationButtonDidTap()
            }) {
                Image("map-marker-icon")
            }.foregroundColor(Color(uiConfig.mainThemeForegroundColor))
        }
    }
}

struct ATCMyLocationButton_Previews: PreviewProvider {
    static var previews: some View {
        ATCMyLocationButton(uiConfig: ATCDefaultUIConfiguration())
    }
}
