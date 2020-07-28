//
//  ContentView.swift
//  test
//
//  Created by Long Vo on 7/24/20.
//  Copyright © 2020 Long Vo. All rights reserved.
//

import SwiftUI

import SwiftUI

let holeRadius: CGFloat = 100
fileprivate var holeFrames = [CGRect](repeating: .zero, count: 3)
fileprivate var coinStartingPos = CGPoint.zero
enum DragPhase {
    case firstPhase
    case secondPhase
    case selectedChangeValue
    case selectedDonate
}
struct LivestreamView: View {
    @State private var showCoin = false
    @State private var coinOffset = CGPoint.zero
    @State private var currentY: CGFloat = 0
    @State private var dragPhase: DragPhase = .firstPhase
    @State private var allowHorizontalDrag = false
    @State private var choiceIndex: Int?
    @State private var uikitAlpha = CGFloat(1)
    @State private var coinAngle: Double = 0
    let trayHeight: CGFloat = 300
    let handleRadius: CGFloat = 75
    private var trayCoinDiff: CGFloat {
        return self.trayHeight - self.handleRadius
    }
    private  var offsetCoin: CGPoint {
        if dragPhase == .selectedDonate || dragPhase == .selectedChangeValue {
            return coinOffset
        } else {
            let x = self.allowHorizontalDrag ? self.coinOffset.x : 0
            let y =  self.currentY + self.coinOffset.y + self.trayHeight/2 - self.handleRadius/2
            return CGPoint(x: x, y: y)
        }
    }
    var body: some View {
        ZStack {
            VCSwiftUIView(storyboard: "Storyboard", VC: "UIKitVC", alpha: uikitAlpha)
            Group {
                BackgroundView()
                ChoicesView(indexHighlighted: choiceIndex, dragPhase: dragPhase)
            }
            .opacity(Double(1-self.uikitAlpha))
            HStack {
                Spacer ()
                
                CoinView()
                    .frame(width: self.handleRadius , height: self.handleRadius)
                    .rotationEffect(.degrees(self.coinAngle))
                    .offset(x: self.coinOffset.x, y: self.coinOffset.y)
                    //   .animation(.easeIn(duration: 0.1))
                    .background(
                        GeometryReader{ coinGeo in
                            SliderTray()
                                .frame(width: 75, height: self.trayHeight)
                                .onAppear(perform: {
                                    coinStartingPos = coinGeo.frame(in: .global).origin
                                    self.coinOffset = CGPoint(x: 0, y: self.trayCoinDiff/2)
                                })
                        }
                )
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onChanged { drag in
                                self.choiceIndex = self.matchHoleIndex(draggingPosition:  drag.location)
                                withAnimation(.easeIn(duration: 0.08)) {
                                    let x = self.allowHorizontalDrag ? drag.translation.width : 0
                                    let y =  self.currentY + drag.translation.height + self.trayCoinDiff/2
                                    self.coinOffset = CGPoint(x: x, y:  y)
                                }
                                
                                let top = -self.trayCoinDiff
                                if drag.translation.height <  top{//higher than tray's top
                                    self.allowHorizontalDrag = true
                                } 
                                
                                if !self.allowHorizontalDrag {
                                    self.uikitAlpha = 1 - abs( drag.translation.height/top)
                                }
                        }
                        .onEnded({ drop in
                            if let holeIndex = self.matchHoleIndex(draggingPosition: drop.location) {//go to Holes
                                withAnimation(.easeIn(duration: 0.1)) {
                                    self.coinOffset = self.offsetFromHole(holeIndex)
                                }
                                
                                if holeIndex == 0 {//go to Hole 1st
                                    self.dragPhase =  .selectedChangeValue
                                } else if holeIndex == 1 {//go to Hole 2nd
                                    self.dragPhase = .selectedDonate
                                    withAnimation(Animation.easeIn(duration: 0.8).delay(0.2)) {//go to hole 3rd
                                        self.coinOffset = self.offsetFromHole(2)
                                        self.coinAngle = 180
                                    }
                                }
                            } else {//go back to tray
                                if drop.translation.height < -self.trayCoinDiff/2 {//center Y of tray
                                    self.currentY = -self.trayHeight + self.handleRadius // tray's TOP
                                    self.dragPhase = .secondPhase
                                    self.allowHorizontalDrag = true
                                }
                                else {
                                    self.currentY = 0 // BOTTOM tray
                                    self.dragPhase = .firstPhase
                                    self.uikitAlpha = 1
                                    self.allowHorizontalDrag = false
                                }
                                
                                let x = self.allowHorizontalDrag ? self.coinOffset.x : 0
                                let y =  self.currentY + self.trayCoinDiff/2
                                //withAnimation(Animation.interpolatingSpring(mass: 1, stiffness: 1, damping: 0.5, initialVelocity: 5))
                                withAnimation(.easeIn(duration: 0.2)) {
                                    self.coinOffset = CGPoint(x: x, y: y)
                                }
                                
                                
                                
                            }
                        })
                )
            }
            
        }
        
        
    }
    
    private func offsetFromHole(_ holeIndex: Int) -> CGPoint {
        let deltaW = holeFrames[holeIndex].size.width - self.handleRadius
        let deltaH = holeFrames[holeIndex].size.height - self.handleRadius
        return CGPoint(x: holeFrames[holeIndex].origin.x - coinStartingPos.x + deltaW/2,
                       y: holeFrames[holeIndex].origin.y - coinStartingPos.y + deltaH/2)
    }
    
    private func matchHoleIndex(draggingPosition: CGPoint) -> Int?  {
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
            .stroke()
            .foregroundColor(.clear)
            .overlay(Image("coin")
                .resizable()
                .scaleEffect(1.2)
        )
        
        
    }
}


struct SliderTray: View {
    var body: some View {
        Capsule()
            .foregroundColor( Color.init(.sRGBLinear , red: 1, green: 0, blue: 0, opacity: 0.4))
        
    }
    
}


struct ChoicesView: View {
    let padding: CGFloat = 20
    let indexHighlighted: Int?
    let dragPhase: DragPhase?
    let downSliderHeight = UIScreen.main.bounds.size.height/3.5
    var body: some View {
        GeometryReader { geo in
            VStack (spacing: geo.size.height/5) {
                HoleView(index: 0, highlighted: 0 == self.indexHighlighted, imgName: "holeBorder")
                HoleView(index: 1, highlighted: 1 == self.indexHighlighted, imgName: self.dragPhase == .selectedDonate ? "holeBorderHighlighted" : "holeBorder")
                    
                    .background(
                        Capsule()
                            .frame(width: holeRadius + self.padding , height: self.downSliderHeight + 2*self.padding )
                            .foregroundColor(Color.black.opacity(0.7))
                            .offset(x: 0, y: self.downSliderHeight/2 - holeRadius/2)
                            .overlay(
                                HoleView(index: 2, highlighted:  false, imgName: "holeBorderHighlighted")
                                    .offset(x: 0, y: self.downSliderHeight - holeRadius)
                        )
                            .opacity(self.dragPhase == .selectedDonate ? 1 : 0)
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
    let imgName: String
    var body: some View {
        Circle()
            .foregroundColor(.clear)
            .frame(width: holeRadius, height: holeRadius)
            .overlay(Image(imgName)
                .resizable()
        )
            .shadow(color: .green  , radius: highlighted ?  30 : 0)
        .padding(40)
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
