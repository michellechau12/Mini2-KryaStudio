//
//  TerroristWinningView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 23/06/24.
//

import SwiftUI

struct TerroristWinningView: View {
    
    @State private var textPosition: CGFloat = -500
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("bg-winning")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                Color.black.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                Image("text-win-terrorist")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 800)
                    .offset(y: textPosition)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1).delay(1)) {
                            textPosition = 0}
                    }
            }
        }
    }
}


#Preview {
    TerroristWinningView()
}
