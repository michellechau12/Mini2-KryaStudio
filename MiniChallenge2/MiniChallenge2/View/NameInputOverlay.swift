//
//  NameInputOverlay.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 11/06/24.
//

import SwiftUI
import MultipeerConnectivity

struct NameInputOverlay: View {
    @Binding var showNameInput: Bool
    @Binding var newName: String
    @Binding var startGame: Bool
    
    @EnvironmentObject var mpManager: MultipeerConnectionManager
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            Image("popup-paper")
                .resizable()
                .scaledToFit()
                .frame(width: 800)
            Button {
                showNameInput = false
            } label: {
                Image("button-back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
            } .offset(x: 300, y: -190)
            
            
            VStack(spacing: 20) {
                Text("Enter your Name")
                    .font(.system(size: 32, weight: .bold))
                    .padding()
                
                TextField("Enter your name", text: $newName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .frame(width: 300, height: 50)
                    .background(Color.white)
                    .cornerRadius(10)
                
                Button {
                    saveNewName()
                    showNameInput = false
                    startGame = true
                } label: {
                    Image("button-submit")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .padding()
                }
            }
            .padding()
            
            
        }
    }
    
    func saveNewName() {
        if !newName.isEmpty {
            mpManager.updatePeerID(with: newName)
            print(mpManager.myConnectionId.displayName)
        } else {
            print("Name field is empty")
        }
    }
}

#Preview {
    NameInputOverlay(showNameInput: .constant(true), newName: .constant(""), startGame: .constant(false))
}
