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
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            Image("popup-paper")
                .resizable()
                .scaledToFit()
                .frame(width: 1000)
            Button {
                showCredit = false
            } label: {
                Image("button-back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
            } .offset(x: 380, y: -240)
            VStack {
                Spacer().frame(height: 100)
                Text("developed by : ")
                    .font(Font.custom("PixelifySans-Regular_SemiBold", size: 24))
                    .foregroundColor(Color.brownSecondary)
                Text("KRYA Studio")
                    .font(Font.custom("PixelifySans-Regular_Bold", size: 56))
                    .foregroundColor(Color.brownSecondary)
                    .padding()
                
                VStack(spacing: 20) {
                    ForEach(0..<2) { row in
                        HStack(spacing: 20) {
                            ForEach(0..<3) { column in
                                let index = row * 3 + column
                                VStack {
                                    Image(creditsName[index].0)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 140, height: 140)
                                        .clipShape(Circle())
                                    Text(creditsName[index].1)
                                        .font(Font.custom("PixelifySans-Regular_SemiBold", size: 32))
                                        .foregroundColor(Color.brownSecondary)
                                }
                            }
                        }
                    }
                }
                Spacer()
                    .frame(height: 170)
            }
        }
    }
}

#Preview {
    CreditOverlay(showCredit: .constant(true))
}
