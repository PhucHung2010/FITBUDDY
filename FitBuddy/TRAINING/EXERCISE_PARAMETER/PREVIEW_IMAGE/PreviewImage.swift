//
//  PreviewImage.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 25/06/2025.
//

import SwiftUI

struct PreviewImage: View {
    let category: Category
    var body: some View {
        TabView {
            ForEach(category.images, id: \.0) {image in
                HStack(spacing: 5) {
                    Image(image.0)
                        .resizable()
                        .scaledToFit()
                    Image(image.1)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .frame(width: UIScreen.main.bounds.width - 35,
               height: (UIScreen.main.bounds.width - 40) * 3 / 4)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 4)
    }
}

struct PreviewImage_Previews: PreviewProvider {
    static var previews: some View {
        if let category = ExerciseCategory().categories.first {
            PreviewImage(category: category)
        }
    }
}
