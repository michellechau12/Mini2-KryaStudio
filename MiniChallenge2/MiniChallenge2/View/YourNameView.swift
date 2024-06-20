//
//  YourNameView.swift
//  MiniChallenge2
//
//  Created by Muhammad Afif Fadhlurrahman on 20/06/24.
//

import SwiftUI

struct YourNameView: View {
    @AppStorage("yourName") var yourName = ""
    @State private var userName = ""
    @State private var changeName = false
    @State private var newName = ""
    
    var body: some View {
        VStack{
            Text("This is the name will be associated with this device.")
            
            TextField("Your Name: ", text: $userName)
                .textFieldStyle(.roundedBorder)
            
            Button("Set"){
            }
        }
    }
}
