//
//  CustomSheet.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 19/06/2025.
//


import SwiftUI
import UIKit
import Foundation


extension View {
    func customHeightSheet<SheetView: View>(showSheet: Binding<Bool>, sheetHeight: Double = 400, @ViewBuilder sheetView: @escaping () -> SheetView, onEnd: @escaping ()->()) -> some View {
        return self
            .background (
                customHeightSheetHelper(sheetView: sheetView(), sheetHeight: sheetHeight, showSheet: showSheet, onEnd: onEnd)
            )
    }
}

struct customHeightSheetHelper<SheetView: View>: UIViewControllerRepresentable {
    var sheetView: SheetView
    var sheetHeight: Double
    @Binding var showSheet: Bool
    var onEnd: () -> ()

    let controller = UIViewController()

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

        if showSheet {
            let sheetController = CustomHostingControllerSize(rootView: sheetView, sheetHeight: sheetHeight)
            sheetController.presentationController?.delegate = context.coordinator
            uiViewController.present(sheetController, animated: true)
        }
        else {uiViewController.dismiss(animated: true)}
    }

    // On dismiss
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {

        var parent: customHeightSheetHelper

        init(parent: customHeightSheetHelper) {
            self.parent = parent
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
            parent.onEnd()
        }
    }
}

class CustomHostingControllerSize<Content: View>: UIHostingController<Content> {
    let sheetHeight: Double

    init(rootView: Content, sheetHeight: Double) {
        self.sheetHeight = sheetHeight
        super.init(rootView: rootView)
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [
                .custom(identifier: .init("customHeight")) { _ in
                    return self.sheetHeight
                }
            ]
            presentationController.selectedDetentIdentifier = .init("customHeight")
//            presentationController.largestUndimmedDetentIdentifier = .init("customHeight")
            presentationController.prefersGrabberVisible = false
            presentationController.preferredCornerRadius = 0
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        }
    }
}



