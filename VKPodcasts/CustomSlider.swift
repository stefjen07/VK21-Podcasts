//
//  CustomSlider.swift
//  CustomSlider
//
//  Created by Евгений on 14.08.2021.
//

import SwiftUI

struct CustomSlider: View {
    @Binding var offset: CGFloat
    @Binding var hasUpdates: Bool
    let thumbRadius: CGFloat = 5
    let trackHeight: CGFloat = 5
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                Capsule()
                    .fill(Color("VKColor").opacity(0.2))
                    .frame(height: trackHeight)
                Capsule()
                    .fill(Color("VKColor"))
                    .frame(width: offset * size.width + thumbRadius, height: trackHeight)
                Circle()
                    .fill(Color("VKColor"))
                    .frame(width: thumbRadius * 2, height: thumbRadius * 2)
                    .offset(x: offset * size.width)
                    .gesture(DragGesture().onChanged({ value in
                        if value.location.x >= thumbRadius && value.location.x <= size.width - thumbRadius {
                            offset = (value.location.x - thumbRadius) / size.width
                            hasUpdates = true
                        }
                    }))
            }
        }.frame(height: thumbRadius * 2)
    }
}

struct CustomSliderPreviews: PreviewProvider {
    static var previews: some View {
        CustomSlider(offset: .constant(0.5), hasUpdates: .constant(false))
    }
}
