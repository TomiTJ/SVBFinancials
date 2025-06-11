//  TabBarButton.swift
//  SVB-App
//
//  Created by Tomi Nguyen on 15/5/2025.
//

import SwiftUI

struct TabBarButton : View {
    let iconName: String
    let text: String
    let isSelect:Bool
    let action : () -> Void
    
    var body:some View {
        
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(isSelect ? .themePrimary: .gray)
                Text(text)
                    .font(.caption)
                    .foregroundColor(isSelect ?  .themePrimary: .secondary)
                
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TabBarButton_Previews : PreviewProvider {
    static var previews: some View {
        TabBarButton(iconName: "house", text: "Home", isSelect: false, action: { })
        
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

