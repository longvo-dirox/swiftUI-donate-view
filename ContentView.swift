//
//  ContentView.swift
//  test
//
//  Created by Long Vo on 7/24/20.
//  Copyright © 2020 Long Vo. All rights reserved.
//

import SwiftUI

import SwiftUI

let holeRadius: CGFloat = 75
fileprivate var holeFrames = [CGRect](repeating: .zero, count:  2)
  fileprivate var coinStartingPos = CGPoint.zero
struct LivestreamView: View {
    enum DragPhase {
        case firstPhase
        case secondPhase
        case confirm
        case finish
    }
    @State private var showCoin = false
    @State private var offset = CGPoint.zero
    @State private var currentY: CGFloat = 0
    @State private var dragPhase: DragPhase = .firstPhase
    @State private var allowHorizontalDrag = false
    @State private var choiceIndex: Int?
    @State private var vcAlpha = CGFloat(1)
    let trayHeight: CGFloat = 300
    let handleRadius: CGFloat = 75
    
    private  var offsetCoin: CGPoint {
        if dragPhase == .finish {
            return offset
        } else {
            let x = self.allowHorizontalDrag ? self.offset.x : 0
            let y =  self.currentY + self.offset.y + self.trayHeight/2 - self.handleRadius/2
            return CGPoint(x: x, y: y)
        }
    }
    var body: some View {
        ZStack {
            VCSwiftUIView(storyboard: "Storyboard", VC: "UIKitVC", alpha: vcAlpha)
            Group {
                BackgroundView()
                ChoicesView(indexHighlighted: choiceIndex)
            }
            .opacity(Double(1-self.vcAlpha))
            HStack {
                Spacer ()
              
                CoinView()
                    .frame(width: self.handleRadius , height: self.handleRadius)
                    .offset(x: self.offsetCoin.x, y: self.offsetCoin.y)
                    .animation(.easeIn(duration: 0.1))
                    .background(
                        GeometryReader{ coinGeo in
                            SliderTray()
                                .frame(width: 75, height: self.trayHeight)
                                .onAppear(perform: {
                                    coinStartingPos = coinGeo.frame(in: .global).origin
                                })
                        }
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onChanged{
                                self.choiceIndex = self.matchHoleIndex(draggingPosition:  $0.location)
                                let yOffset = $0.translation.height
                                self.offset = CGPoint(x: $0.translation.width, y:  yOffset)
                                let top = -self.trayHeight + self.handleRadius
                                if yOffset <  top{//higher than tray's top
                                    self.allowHorizontalDrag = true
                                } 
                                
                                if !self.allowHorizontalDrag {
                                    self.vcAlpha = 1 - abs( yOffset/top)
                                //    print("self.apha=\(self.vcAlpha)")
                                }
                        }
                        .onEnded({
                            if let destination = self.matchHoleIndex(draggingPosition: $0.location) {
                                let deltaW = holeFrames[destination].size.width - self.handleRadius
                                let deltaH = holeFrames[destination].size.height - self.handleRadius
                                self.offset = CGPoint(x: holeFrames[destination].origin.x - coinStartingPos.x + deltaW/2,
                                                      y:  holeFrames[destination].origin.y - coinStartingPos.y + deltaH/2)
                                self.dragPhase = .finish
                                 return
                            }
                            self.offset = .zero
                            if $0.translation.height < -self.trayHeight/2 + self.handleRadius/2 {//center Y of tray
                                self.currentY = -self.trayHeight + self.handleRadius // tray's top
                                self.dragPhase = .secondPhase
                                self.allowHorizontalDrag = true
                            }
                            else {
                                self.currentY = 0 // bottom tray
                                self.dragPhase = .firstPhase
                                self.allowHorizontalDrag = false
                            }
                        })
                )
          //  }
            }
           
        }
        
        
    }
    
    func matchHoleIndex(draggingPosition: CGPoint) -> Int?  {
      //  print("\(draggingPosition)")
        for (index, frame) in holeFrames.enumerated() {
            if frame.contains(draggingPosition) {
                return index
            }
        }
        return nil
    }
}

struct CoinView: View {
    
    
    var body: some View {
          
        Circle()
            .foregroundColor(Color.yellow)
            
        
    }
}


struct SliderTray: View {
    var body: some View {
        Capsule()
            .foregroundColor( Color.init(.sRGBLinear , red: 1, green: 0, blue: 0, opacity: 0.4))
        
    }
    
}


struct ChoicesView: View {
    // let holeRadius: CGFloat = 125
    let indexHighlighted: Int?
    let downSliderHeight = UIScreen.main.bounds.size.height/4
    var body: some View {
        GeometryReader { geo in
            VStack (spacing: geo.size.height/5) {
                HoleView(index: 0, highlighted: 0 == self.indexHighlighted)
                HoleView(index: 1, highlighted: 1 == self.indexHighlighted)
                    .background(
                        Capsule()
                            .frame(width: holeRadius, height: self.downSliderHeight )
                            .offset(x: 0, y: self.downSliderHeight/2 - holeRadius/2)
                )
            }
                
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct HoleView: View {
    
    let index: Int
    let highlighted: Bool
    
    var body: some View {
        Circle()
            //.stroke()
            .frame(width: holeRadius, height: holeRadius)
            .shadow(color: .green  , radius: highlighted ?  30 : 0)
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            holeFrames[self.index] = geo.frame(in: .global)
                    }
                    
            })
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        LivestreamView()
            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
            .previewDisplayName("iPhone XS Max")
    }
}
 

extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }
}
