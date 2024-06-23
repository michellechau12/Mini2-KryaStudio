//
//  StudioView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 23/06/24.
//

import SwiftUI

struct StudioView: View {
    @State private var navigateToNextView = false
    
    var body: some View {
        ZStack{
            Color.black
                .edgesIgnoringSafeArea(.all)
            Image("credit-studio")
                .resizable()
                .scaledToFit()
                .frame(width: 600)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                withAnimation(.easeInOut) {
                    navigateToNextView = true
                }
            }
        }
        .navigationDestination(isPresented: $navigateToNextView) {
            ContentView()
        }
    }
}

#Preview {
    StudioView()
}
