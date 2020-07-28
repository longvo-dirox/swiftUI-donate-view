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
private var allowHorizontalDrag = false

enum DragPhase {
    case firstPhase
    case secondPhase
    case selectedChangeValue
    case selectedDonate
    case donateComplete
}
struct LivestreamView: View {
    @State private var showCoin = false
    @State private var coinOffset = CGPoint.zero
    @State private var currentY: CGFloat = 0
    @State private var dragPhase: DragPhase = .firstPhase
    // @State private var allowHorizontalDrag = false
    @State private var choiceIndex: Int?
    @State private var uikitAlpha: CGFloat  = 1
    @State private var coinAngle: Double = 0
    @State private var coinWhiteHaloAngle: Double = 0
    @State private var coinHaloScale: CGFloat = 1
    @State private var showCoinWhiteHalo: Bool = false
    @State private var coinHaloOpacity: Double = 1
    @State private var finalScreenOpacity: Double = 0
    
    let trayHeight: CGFloat = 300
    let coinRadius: CGFloat = 95
    private var trayCoinDiff: CGFloat {
        return self.trayHeight - self.coinRadius
    }
    private  var offsetCoin: CGPoint {
        if dragPhase == .selectedDonate || dragPhase == .selectedChangeValue {
            return coinOffset
        } else {
            let x = allowHorizontalDrag ? self.coinOffset.x : 0
            let y =  self.currentY + self.coinOffset.y + self.trayHeight/2 - self.coinRadius/2
            return CGPoint(x: x, y: y)
        }
    }
    var body: some View {
        ZStack {
            VCSwiftUIView(storyboard: "Storyboard", VC: "UIKitVC", alpha: 1)
            BackgroundView(opacity: Double(1-self.uikitAlpha)/2)
            ChoicesView(indexHighlighted: choiceIndex, dragPhase: dragPhase)
            .opacity(Double(1-self.uikitAlpha))
            //            .blendMode(.colorBurn)
            
            DonateOptionsFinalScreen(opacity: finalScreenOpacity)
                .zIndex(2)
            
            
            HStack {
                Spacer ()
                
                CoinView(haloOpacity: self.coinHaloOpacity, haloScale: coinHaloScale, showWhiteHalo: showCoinWhiteHalo, whiteHaloAngle: self.coinWhiteHaloAngle)
                    .frame(width: self.coinRadius , height: self.coinRadius)
                    .rotationEffect(.degrees(self.coinAngle))
                    .offset(x: self.coinOffset.x, y: self.coinOffset.y)
                    //   .animation(.easeIn(duration: 0.1))
                    .background(
                        GeometryReader{ coinGeo in
                            SliderTray()
                                .frame(width: self.coinRadius , height: self.trayHeight)
                                .onAppear(perform: {
                                    coinStartingPos = coinGeo.frame(in: .global).origin
                                    self.coinOffset = CGPoint(x: 0, y: self.trayCoinDiff/2)
                                })
                        }
                ) .offset(x: 0, y: self.trayCoinDiff/2)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onChanged { drag in
                                self.choiceIndex = self.matchHoleIndex(draggingPosition:  drag.location)
                                withAnimation(.easeIn(duration: 0.08)) {
                                    let x = allowHorizontalDrag ? drag.translation.width : 0
                                    let y =  self.currentY + drag.translation.height + self.trayCoinDiff/2
                                    self.coinOffset = CGPoint(x: x, y:  y)
                                }
                                
                                let top = -self.trayCoinDiff
                                if drag.translation.height <  top{//higher than tray's top
                                    allowHorizontalDrag = true
                                } 
                                
                                if !allowHorizontalDrag {
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
                                    let duration1 = 0.8
                                    let delay1 = 0.2
                                    withAnimation(Animation.easeInOut(duration: duration1).delay(delay1)) {//fall down to hole 3rd
                                        self.dragPhase = .selectedDonate
                                        self.coinOffset = self.offsetFromHole(2)
                                        self.coinAngle = 360
                                    }
                                    let delay2 = duration1 + delay1 + 0.3
                                    let duration2 = 0.2
                                    withAnimation(
                                        Animation.easeIn(duration: duration2).delay(delay2)
                                    ) {
                                        self.coinHaloScale = 1.25
                                    }
                                    
                                    let delay3 = delay2 + duration2
                                    let duration3 = 0.2
                                    DispatchQueue.main.asyncAfter(deadline: .now() + delay3) {
                                        withAnimation(Animation.easeOut(duration: duration3)) {
                                            self.coinHaloScale = 0.95
                                        }
                                    }
                                    
                                    let delay4 = delay3 + duration3
                                    DispatchQueue.main.asyncAfter(deadline: .now() + delay4) {
                                        withAnimation(Animation.easeIn(duration: 0.4)) {
                                            self.dragPhase = .donateComplete// fade out the capsule
                                        }
                                        
                                        withAnimation(Animation.easeIn(duration: 0.2).delay(0.4)) {
                                            self.finalScreenOpacity = 1
                                        }
                                        
                                        self.coinHaloOpacity = 0.3
                                        withAnimation(Animation.easeIn(duration: 0.2)) {
                                            self.showCoinWhiteHalo = true
                                        }
                                        
                                        withAnimation(Animation.easeOut(duration: 1.4)) {
                                            self.coinHaloScale = 25
                                            self.coinHaloOpacity = 1
                                        }
                                        
                                        withAnimation(Animation.easeIn(duration: 4.2).delay(1.4)) {
                                            self.coinAngle = -360
                                            self.coinWhiteHaloAngle = 1440
                                        }
                                    }
                                    
                                    
                                }
                            } else {//go back to tray
                                if drop.translation.height < -self.trayCoinDiff/2 {//center Y of tray
                                    self.currentY = -self.trayHeight + self.coinRadius // tray's TOP
                                    self.dragPhase = .secondPhase
                                    self.uikitAlpha = 0
                                    allowHorizontalDrag = true
                                }
                                else {
                                    self.currentY = 0 // BOTTOM tray
                                    self.dragPhase = .firstPhase
                                    self.uikitAlpha = 1
                                    allowHorizontalDrag = false
                                }
                                
                                let y =  self.currentY + self.trayCoinDiff/2
                                //withAnimation(Animation.interpolatingSpring(mass: 1, stiffness: 1, damping: 0.5, initialVelocity: 5))
                                withAnimation(.easeIn(duration: 0.2)) {
                                    self.coinOffset = CGPoint(x: 0, y: y)
                                }
                                
                                
                                
                            }
                        })
                )
            }
            
        }
        
        
    }
    
    private func offsetFromHole(_ holeIndex: Int) -> CGPoint {
        let deltaW = holeFrames[holeIndex].size.width - self.coinRadius
        let deltaH = holeFrames[holeIndex].size.height - self.coinRadius
        return CGPoint(x: holeFrames[holeIndex].origin.x - coinStartingPos.x + deltaW/2,
                       y: holeFrames[holeIndex].origin.y - coinStartingPos.y + deltaH/2)
    }
    
    private func matchHoleIndex(draggingPosition: CGPoint) -> Int?  {
        guard allowHorizontalDrag else {
            return nil
        }
        
        for (index, frame) in holeFrames.enumerated() {
            if frame.contains(draggingPosition) {
                return index
            }
        }
        return nil
    }
}

struct CoinView: View {
    let haloOpacity: Double
    let haloScale: CGFloat
    let showWhiteHalo: Bool
    let whiteHaloAngle: Double
    var body: some View {
        
        Circle()
            .stroke()
            .foregroundColor(.clear)
            .overlay(Image("coin")
                .resizable()
                
                .overlay(
                    Image("halo")
                        .rotationEffect(.degrees(whiteHaloAngle))
                        .opacity(showWhiteHalo ? 1 : 0)
                        .foregroundColor(.white)
            )
                .background(
                    Circle()
                        .foregroundColor(Color.yellow.opacity(haloOpacity))
                        .scaleEffect(haloScale)
                        .zIndex(1)
                )
        ).scaleEffect(0.9)
        
        
    }
}


struct SliderTray: View {
    var body: some View {
        Capsule()
            .foregroundColor( Color.init(.sRGBLinear , red: 1, green: 0, blue: 0, opacity: 0.4))
        
    }
    
}


struct ChoicesView: View {
    let padding: CGFloat = 5
    let indexHighlighted: Int?
    let dragPhase: DragPhase?
    let downSliderHeight = UIScreen.main.bounds.size.height/3.5
    
    var body: some View {
        
        VStack (spacing: 80) {
            HoleView(index: 0, centerText: "2$",  highlighted: 0 == self.indexHighlighted, imgName: "holeBorder")
                .overlay(
                    DescriptionView {
                        VStack(spacing: 0){
                            Text("dslkfj ksdjfld dsflkj sdflkj ")
                                .font(.largeTitle)
                            Text("hello ")
                                .font(.title)
                            Image("downArrow")
                        }
                        .frame(width: UIScreen.main.bounds.size.width)
                    }
                    
            )
            
            HoleView(index: 1, centerText: "",  highlighted: 1 == self.indexHighlighted, imgName: self.dragPhase == .selectedDonate ? "holeBorderHighlighted" : "holeBorder")
                .overlay(
                    DescriptionView {
                        VStack (spacing: 0){
                            Text("second text ")
                                .font(.subheadline)
                                .frame(width: UIScreen.main.bounds.size.width)
                            Image("downArrow")
                        }
                        .frame(width: UIScreen.main.bounds.size.width)
                    }
                    
                    
            )
                .background(
                    Capsule()
                        .frame(width: holeRadius + self.padding , height: self.downSliderHeight + self.padding )
                        .foregroundColor(Color.black.opacity(0.8))
                        .offset(x: 0, y: self.downSliderHeight/2 - holeRadius/2)
                        .overlay(
                            HoleView(index: 2, centerText: "",  highlighted:  false, imgName: "holeBorderHighlighted")
                                .offset(x: 0, y: self.downSliderHeight - holeRadius)
                    )
                        .opacity(self.dragPhase == .selectedDonate ? 1 : 0)
            )
        }
            
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
}

struct DescriptionView<Content: View>: View {
    let content: Content
    @State private var description2Height: CGFloat = 0
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .overlay(
                GeometryReader { description2 in
                    Color(.clear).onAppear(){
                        self.description2Height = description2.size.height
                    }
                    
            })
            .offset(x: 0, y: -holeRadius/2 - self.description2Height/2)
    }
}

struct HoleView: View {
    let index: Int
    let centerText: String
    let highlighted: Bool
    let imgName: String
    let addedArea: CGFloat = 200
    var body: some View {
        Circle()
            .foregroundColor(.clear)
            .frame(width: holeRadius, height: holeRadius)
            .overlay(Image(imgName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(highlighted ? .yellow : .white)
                .overlay(Text(centerText))
        )
            //  .shadow(color: .yellow  , radius:  highlighted ?  300 : 0 )
            //        .padding(addedArea)
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            holeFrames[self.index] = geo.frame(in: .global).inset(by: .init(top: self.addedArea, left: self.addedArea, bottom: self.addedArea, right: self.addedArea))
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
