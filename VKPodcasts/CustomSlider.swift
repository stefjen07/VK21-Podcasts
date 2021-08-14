//
//  CustomSlider.swift
//  CustomSlider
//
//  Created by Евгений on 14.08.2021.
//

import SwiftUI

class CustomSlider: UISlider {
    @IBInspectable var trackHeight: CGFloat = 3
    @IBInspectable var thumbRadius: CGFloat = 20

    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = UIColor(named: "VKColor")
        return thumb
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        let thumb = thumbImage(radius: thumbRadius)
        setThumbImage(thumb, for: .normal)
    }

    private func thumbImage(radius: CGFloat) -> UIImage {
        thumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        thumbView.layer.cornerRadius = radius / 2

        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }

}

struct SliderRepresentable: UIViewRepresentable {
    @Binding var value: Float
    
    func updateUIView(_ uiView: CustomSlider, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> CustomSlider {
        let slider = CustomSlider()
        slider.observe(\.value, changeHandler: { slider, _ in
            self.value = slider.value
        })
        slider.thumbRadius = 15
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.awakeFromNib()
        slider.minimumTrackTintColor = .init(named: "VKColor")
        slider.maximumTrackTintColor = .init(Color("VKColor").opacity(0.2))
        return slider
    }
}
