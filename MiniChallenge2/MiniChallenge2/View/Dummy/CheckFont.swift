//
//  CheckFont.swift
//  MiniChallenge2
//
//  Created by Rio Ikhsan on 23/06/24.
//

import SwiftUI

struct CheckFont: View {
    var body: some View {
        VStack {
            Text("Check Font!")
        }         .onAppear {
            
            for family in UIFont.familyNames.sorted() {
                print("Family: \(family)")
                
                let names = UIFont.fontNames(forFamilyName: family)
                for fontName in names {
                    print("- \(fontName)")
                }
            }
        }
    }
    
}

#Preview {
    CheckFont()
}
