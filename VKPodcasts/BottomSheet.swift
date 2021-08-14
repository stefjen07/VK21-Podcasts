//
//  BottomSheet.swift
//  BottomSheet
//
//  Created by Евгений on 14.08.2021.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {
    @Binding var isOpen: Bool
    
    let radius: CGFloat = 30
    let snapRatio: CGFloat = 0.5
    
    let indicatorWidth: CGFloat = 65
    let indicatorHeight: CGFloat = 5

    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content
    
    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }

    private var indicator: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(Color.secondary)
            .frame(
                width: indicatorWidth,
                height: indicatorHeight)
    }

    @GestureState private var translation: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.indicator
                    .padding(15)
                    .preferredColorScheme(.dark)
                self.content
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Blur(effect: UIBlurEffect(style: .dark)))
            .cornerRadius(radius, corners: [.topLeft, .topRight])
            .frame(height: geometry.size.height, alignment: .bottom)
            .shadow(color: .white, radius: 2)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.interactiveSpring(), value: isOpen)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = self.maxHeight * snapRatio
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isOpen = value.translation.height < 0
                }
            )
        }
    }

    init(isOpen: Binding<Bool>, maxHeight: CGFloat, bottomSize: CGFloat, @ViewBuilder content: () -> Content) {
        self.minHeight = 160 + bottomSize
        self.maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
    }
}
