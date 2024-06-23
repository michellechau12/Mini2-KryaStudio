//
//  InputNameView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 19/06/24.
//

import SwiftUI

struct InputNameView: View {
    @State private var playerDeviceName: String = ""
    @State private var isSubmitted: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image("random-role-img")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Enter your Name")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .top)
                        .padding(.top, 48)
                    Spacer()
                    TextField("Enter your name", text: $playerDeviceName)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .frame(width: 400, height: 50)
                        .scaleEffect(1.0)
                        .background(Color.white)
                        .cornerRadius(10)
                    Button(action: {
                        isSubmitted = true
                    }) {
                        Text("Submit")
                            .padding()
                            .background(Color.brown)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                        .frame(height: 300)
                }
                .navigationDestination(isPresented: $isSubmitted) {
//                    NextView(playerDeviceName: playerDeviceName)
                }
                .environment(\.sizeCategory, .medium) // Ensuring no dynamic type size changes

            }
        }
    }
}


#Preview {
    InputNameView()
}
