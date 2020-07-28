//
//  LivestreamBackgroundView.swift
//  test
//
//  Created by Long Vo on 7/24/20.
//  Copyright © 2020 Long Vo. All rights reserved.
//

import SwiftUI
struct DonateOptionsFinalScreen: View {
    let opacity: Double
    var body: some View {
        VStack (spacing: 40) {
            
            Image("iDareUicon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaledToFill()
                .frame(width: 150, height: 150)
                .padding(.top,40)
            
            Spacer()
            Text("association text jkdsfh  sdjhfksdf ")
                .font(.largeTitle)
                .fontWeight(.black)
                .padding(15)
                .background(Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            Text("association text dffds dsfad dsadsf dsfas sdadsf  ")
                .font(.headline)
                .fontWeight(.black)
                .padding(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 15).stroke()
                    
            )
                
                .padding(20)
            
            Spacer()
                .frame(height: 200)
            
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
       
        //.edgesIgnoringSafeArea(.all)
            .opacity(opacity)
    }
} 

struct DonateOptionsFinalScreen_Previews: PreviewProvider {
    static var previews: some View {
        DonateOptionsFinalScreen(opacity: 1)
         .background(Color.yellow)
    }
}
