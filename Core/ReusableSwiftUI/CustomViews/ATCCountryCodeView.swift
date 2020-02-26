//
//  ATCCountryCodeView.swift
//  FitnessApp
//
//  Created by Duy Bui on 1/11/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import SwiftUI

struct ATCCountryCodeView: View {
    private let appConfig: ATCUIGenericConfigurationProtocol
    @State var expand: Bool = false
    
    init(appConfig: ATCUIGenericConfigurationProtocol) {
        self.appConfig = appConfig
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 13) {
            VStack {
                HStack(alignment: .center, spacing: 13) {
                    Image("Romania")
                        .frame(width: 30, height: 21)
                    Text("+40")
                        .font(.custom(appConfig.regularMediumFont.fontName,
                                      size: appConfig.regularMediumFont.pointSize))
                }
                if expand {
                    // To-do: Implement drop down list here
                }
            }
            Image("fitness-dropdown-icon")
                .frame(width: 24, height: 24)
                .onTapGesture {
                    self.expand.toggle()
                    print(self.expand)
            }
        }
    }
}
