//
//  StartView.swift
//  McWebViewApp
//
//  Created by DarkAngel on 11/17/25.
//

import SwiftUI
import McWebview

struct StartView: View {
    @State private var next: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                
                Button(action: {
                    next = true
                }) {
                    Text("누르면 좋아요!!")
                }
            }.navigationDestination(isPresented: $next) { MainView()
            }
        }
        
    }
}


#Preview {
    StartView()
}
