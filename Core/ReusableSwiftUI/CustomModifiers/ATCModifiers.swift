//
//  ATCModifiers.swift
//  FitnessApp
//
//  Created by Duy Bui on 1/8/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import SwiftUI

struct ATCTextModifier: ViewModifier {
    let font: UIFont
    let color: UIColor
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .font(.custom(font.fontName, size: font.pointSize))
            .foregroundColor(Color(color))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
    }
}

struct ATCShadowModifier: ViewModifier {
    let appConfig: FitnessAppConfigurationProtocol
    func body(content: Content) -> some View {
        content
            .shadow(color: Color(appConfig.shadowColor), radius: 5.0, x: 3, y: 3)
    }
}

struct ATCButtonModifier: ViewModifier {
    let appConfig: FitnessAppConfigurationProtocol
    func body(content: Content) -> some View {
        content
            .modifier(ATCTextModifier(font: appConfig.mediumBoldFont,
                                      color: .white))
            .padding()
            .frame(width: 300, height: 50)
            .background(Color(appConfig.mainThemeForegroundColor))
            .cornerRadius(25.0)
    }
}
