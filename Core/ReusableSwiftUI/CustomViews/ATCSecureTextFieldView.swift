//
//  ATCSecureTextFieldView.swift
//  ATCSecureTextFieldView
//
//  Created by Duy Bui on 1/11/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import SwiftUI

struct ATCSecureTextFieldView: View {
    @State private var showPassword: Bool = true
    private var password: Binding<String>
    private var placeholder: String
    private let appConfig: ATCUIGenericConfigurationProtocol
    
    init(placeholder: String,
         text: Binding<String>,
         appConfig: ATCUIGenericConfigurationProtocol){
        self.placeholder = placeholder
        self.password = text
        self.appConfig = appConfig
    }
    
    var body: some View {
        HStack() {
            if showPassword {
                SecureField(placeholder, text: password)
                    .autocapitalization(.none)
                    .multilineTextAlignment(.center)
            } else {
                TextField(placeholder, text: password)
                    .autocapitalization(.none)
                    .font(.custom(appConfig.regularMediumFont.fontName,
                                  size: appConfig.regularMediumFont.pointSize))
                    .multilineTextAlignment(.center)
            }
            Image(showPassword ? "show-password-icon" : "hide-password-icon")
                .frame(width: 24, height: 24)
                .onTapGesture {
                    self.showPassword.toggle()
            }
        }
    }
}
