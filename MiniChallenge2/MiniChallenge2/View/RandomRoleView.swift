//
//  RandomRoleView.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 17/06/24.
//

import SwiftUI

struct RandomRoleView: View {
    @State private var role: String? = nil
    @State private var currentImage: String = "fbi-img"
    @State private var isAnimating: Bool = true
    @State private var navigateToNextView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("random-role-img")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("You play as a ...")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .top)
                        .padding(.top, 50)
                    
                    Spacer()
                        .frame(height: 140)
                    
                    if isAnimating {
                        VStack {
                            Text("...")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.bottom, 10)
                            Image(currentImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .onAppear {
                                    startAnimating()
                                }
                        }
                    } else if let role = role {
                        VStack {
                            Text(role.uppercased())
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.bottom, 10)
                            
                            if role == "fbi" {
                                Image("fbi-img")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300, height: 300)
                            } else if role == "terrorist" {
                                Image("terrorist-img")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300, height: 300)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .background(
                    NavigationLink(destination: destinationView(), isActive: $navigateToNextView) {
                        EmptyView()
                    }
                )
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func startAnimating() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation {
                currentImage = (currentImage == "fbi-img") ? "terrorist-img" : "fbi-img"
            }
            
            if !isAnimating {
                timer.invalidate()
                role = Randomizer.randomizeRole()
                currentImage = role == "fbi" ? "fbi-img" : "terrorist-img"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    navigateToNextView = true
                }
            }
        }
        
        // Stop animation after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isAnimating = false
        }
    }
    
    private func destinationView() -> some View {
        if role == "fbi" {
            return AnyView(FBIInstructionView())
        } else {
            return AnyView(TerroristInstructionView())
        }
    }
}

#Preview {
    RandomRoleView()
}
