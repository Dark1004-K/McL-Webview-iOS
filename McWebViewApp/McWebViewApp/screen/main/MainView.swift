//
//  ContentView.swift
//  McWebViewApp
//
//  Created by DarkAngel on 9/17/25.
//

import SwiftUI
import McWebview
import Combine


struct MainView: View {
    @StateObject private var model = MainViewModel()
    
    var body: some View {
        VStack {
            McWebviewRepresentable(model:$model.webViewModel)
                .onAppear {
                    self.model.loadUrl()
                }
                .onDisappear() {
                    self.model.releaseWebView()
                }
        }
        .padding()
        
    }

    
    
    
    
    
    
    
    
    
    
    
    
}

#Preview {
    MainView()
}
