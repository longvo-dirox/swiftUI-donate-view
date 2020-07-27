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
fileprivate var holeFrames = [CGRect](repeating: .zero, count:  2)
fileprivate var coinStartingPos = CGPoint.zero
enum DragPhase {
    case firstPhase
    case secondPhase
    case selectedChangeValue
    case selectedDonate
}
struct LivestreamView: View {
    @State private var showCoin = false
    @State private var offset = CGPoint.zero
    @State private var currentY: CGFloat = 0
    @State private var dragPhase: DragPhase = .firstPhase
    @State private var allowHorizontalDrag = false
    @State private var choiceIndex: Int?
    @State private var uikitAlpha = CGFloat(1)
    let trayHeight: CGFloat = 300
    let handleRadius: CGFloat = 75
    
    private  var offsetCoin: CGPoint {
        if dragPhase == .selectedDonate || dragPhase == .selectedChangeValue {
            return offset
        } else {
            let x = self.allowHorizontalDrag ? self.offset.x : 0
            let y =  self.currentY + self.offset.y + self.trayHeight/2 - self.handleRadius/2
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
                    .offset(x: self.offsetCoin.x, y: self.offsetCoin.y)
                 //   .animation(.easeIn(duration: 0.1))
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
                                    self.uikitAlpha = 1 - abs( yOffset/top)
                                }
                        }
                        .onEnded({
                            if let destination = self.matchHoleIndex(draggingPosition: $0.location) {
                                let deltaW = holeFrames[destination].size.width - self.handleRadius
                                let deltaH = holeFrames[destination].size.height - self.handleRadius
                                withAnimation(.easeIn(duration: 0.1)) {
                                    self.offset = CGPoint(x: holeFrames[destination].origin.x - coinStartingPos.x + deltaW/2,
                                                          y:  holeFrames[destination].origin.y - coinStartingPos.y + deltaH/2)
                                }
                                 
                                withAnimation(.easeIn(duration: 0.2)) {
                                    if destination == 0 {
                                        self.dragPhase =  .selectedChangeValue
                                    } else if destination == 1 {
                                        self.dragPhase =   .selectedDonate
                                        withAnimation(Animation.easeIn(duration: 0.2).delay(0.2)) {
                                            self.offset = CGPoint(x: self.offset.x,  y: self.offset.y + 50)
                                        }
                                    }
                                }
                                
                            
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
                                self.uikitAlpha = 1
                                self.allowHorizontalDrag = false
                            }
                        })
                )
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
                                HoleView(index: -1, highlighted:  false, imgName: "holeBorderHighlighted")
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
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            if  self.index >= 0 {
                                holeFrames[self.index] = geo.frame(in: .global)
                            }
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
