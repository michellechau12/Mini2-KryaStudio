//
//  CreditOverlay.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 23/06/24.
//

import SwiftUI

struct CreditOverlay: View {
    
    @Binding var showCredit: Bool
    
    let creditsName = [
        ("circle-michelle", "Michelle"),
        ("circle-tania", "Tania"),
        ("circle-ferris", "Ferris"),
        ("circle-afif", "Afif"),
        ("circle-gilang", "Gilang"),
        ("circle-rio", "Rio")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("developed by : ")
                        .font(Font.custom("PixelifySans-Regular_SemiBold", size: geometry.size.width * 0.018))
                        .foregroundColor(Color.brownSecondary)
                        .padding(.top, geometry.size.width * 0.05)
                    Text("KRYA Studio")
                        .font(Font.custom("PixelifySans-Regular_Bold", size: geometry.size.width * 0.03))
                        .foregroundColor(Color.brownSecondary)
                        .padding(.top, geometry.size.width * 0.001)

                    
                    VStack(spacing: geometry.size.height * 0.02) {
                        ForEach(0..<2) { row in
                            HStack(spacing: geometry.size.width * 0.02) {
                                ForEach(0..<3) { column in
                                    let index = row * 3 + column
                                    VStack {
                                        Image(creditsName[index].0)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width * 0.10, height: geometry.size.width * 0.10)
                                            .clipShape(Circle())
                                        Text(creditsName[index].1)
                                            .font(Font.custom("PixelifySans-Regular_SemiBold", size: geometry.size.width * 0.02))
                                            .foregroundColor(Color.brownSecondary)
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                        .frame(height: geometry.size.height * 0.17)
                }
                .zIndex(1)
                Image("popup-paper")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.7)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .zIndex(0)
                Button {
                    showCredit = false
                } label: {
                    Image("button-back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.05)
                }
                .offset(x: geometry.size.width * 0.26, y: -geometry.size.height * 0.27)
                .zIndex(2)
            }
        }
    }
}

#Preview {
    CreditOverlay(showCredit: .constant(true))
}
