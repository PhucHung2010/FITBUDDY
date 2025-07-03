//
//  healthInsuranceView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 02/06/2025.
//

import SwiftUI

struct HealthInsuranceView: View {
    var body: some View {
        ZStack {
            AppBackground()
            Image(systemName: "heart.fill")
                .font(.system(size: 200))
        }
    }
}

struct healthInsuranceView_Previews: PreviewProvider {
    static var previews: some View {
        HealthInsuranceView()
    }
}
