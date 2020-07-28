//
//  LivestreamBackgroundView.swift
//  test
//
//  Created by Long Vo on 7/24/20.
//  Copyright © 2020 Long Vo. All rights reserved.
//

import SwiftUI
struct BackgroundView: View {
    let opacity: Double
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
                    .frame(maxWidth: .infinity)
                
                VStack( spacing: 0) {
                    Image("img")
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
            .background( Color.black.opacity(self.opacity))
            .edgesIgnoringSafeArea(.all)
        } .edgesIgnoringSafeArea(.all)
    }
} 

struct LivestreamBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView(opacity: 1)
    }
}
