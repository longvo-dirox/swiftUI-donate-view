//
//  LivestreamBackgroundView.swift
//  test
//
//  Created by Long Vo on 7/24/20.
//  Copyright © 2020 Long Vo. All rights reserved.
//

import SwiftUI
struct BackgroundView: View {
    var body: some View {
        GeometryReader { geo in
            VStack (spacing: 30) {
                
                VStack {
                    Text("abc kdsjfldj  hello ")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.black)
                }
                .frame(height: geo.size.height/4)
                
                Spacer()
                
                VStack( spacing: 0) {
                    Image("flowers-nature-portrait-955782")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 100)
                        .clipShape(Capsule())
                    Text("bottom text ")
                        .padding()
                        .background(Color.red)
                    
                }
                .frame(height: geo.size.height/4)
                .edgesIgnoringSafeArea(.all)
                .background(Color.yellow)
            }
            .foregroundColor(.white)
            .background( Color.init(.sRGBLinear , red: 0, green: 0, blue: 0, opacity: 0.8))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        } .edgesIgnoringSafeArea(.all)
    }
} 
