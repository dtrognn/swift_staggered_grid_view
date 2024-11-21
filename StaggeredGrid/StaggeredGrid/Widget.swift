//
//  Widget.swift
//  StaggeredGrid
//
//  Created by dtrognn on 21/11/24.
//

import UIKit

class WidgetItem: Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var w: Double
    var h: Double
    var color: UIColor

    init(title: String, w: Double, h: Double, color: UIColor = .random) {
        self.title = title
        self.w = w
        self.h = h
        self.color = color
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
