//
//  FitnessExerciesAdjustment.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 15/06/2025.
//

import Foundation
import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI

enum ROMDirection {
    case increase
    case decrease
    case unchanged
}

enum ROMState {
    case peak
    case launch
    func switchTargetRom(currentRom: ROMState) -> ROMState {
        switch currentRom {
        case .launch: return .peak
        case .peak: return .launch
        }
    }
}

struct ROMRangeStartEndResult {
    var startAngleValue: Double
    var endAngleValue: Double
}

struct ROMRangeBlurResult {
    var angleValue: Double
    var angleBlur: Double
}

extension QuickPose.Style {
    /// Default correction style with arc visible
    static func normal(correctionRanges: [QuickPose.Style.ConditionalColor]) -> QuickPose.Style {
        return QuickPose.Style(
            relativeFontSize: 0.9,
            relativeArcSize: 0.4,
            relativeLineWidth: 1.3,
            conditionalColors: correctionRanges
        )
    }
    
    /// Same correction style but arc hidden
    static func hideArc(correctionRanges: [QuickPose.Style.ConditionalColor]) -> QuickPose.Style {
        return QuickPose.Style(
            relativeFontSize: 0,
            relativeArcSize: 0,
            relativeLineWidth: 1.3,
            conditionalColors: correctionRanges
        )
    }
    
    /// A simple illegal style (visible arc)
    static var illegal: QuickPose.Style {
        return QuickPose.Style(
            relativeFontSize: 0.9,
            relativeArcSize: 0.4,
            relativeLineWidth: 1.3,
            color: UIColor.red
        )
    }
    
    /// Illegal style but arc hidden
    static var illegalHideArc: QuickPose.Style {
        return QuickPose.Style(
            relativeFontSize: 0,
            relativeArcSize: 0,
            relativeLineWidth: 1.3,
            color: UIColor.red
        )
    }
}


struct MovementTarget {
    var feature: QuickPose.Feature
    
    var currentCorrectionStyle: QuickPose.Style?
    var currentIllegalStyle: QuickPose.Style?
    var correctionStyle: QuickPose.Style
    var illegalStyle: QuickPose.Style
    var correctionStyle_HideArc: QuickPose.Style
    var illegalStyle_HideArc: QuickPose.Style
    
    var totalCycle: Int
    var targetCycle: Int
    var beingIllegal: Bool
    
    var currentAngle: Double

    var peakedFlag: Bool
    var launchedFlag: Bool
    
    var launchResult: ROMRangeBlurResult
    var peakResult: ROMRangeBlurResult
    
    var wentThroughMiddlePeakToLaunch: Bool
    var wentThroughMiddleLaunchToPeak: Bool

    var currentRomState: ROMState
    
    var currentDirection: ROMDirection
    var launchDirection: ROMDirection
    var peakDirection: ROMDirection
    
    var greaterThanStartFeedback: String
    var smallerThanEndFeedback: String

    
    
    init(feature: QuickPose.Feature,
         correctionStyle: QuickPose.Style? = nil,
         illegalStyle: QuickPose.Style? = nil,
         correctionStyle_HideArc: QuickPose.Style? = nil,
         illegalStyle_HideArc: QuickPose.Style? = nil,
         totalCycle: Int = 0,
         targetCycle: Int = 1,
         
         launchResult: ROMRangeBlurResult,
         peakResult: ROMRangeBlurResult,
         
         currentRomState: ROMState = .peak,
         
         currentDirection: ROMDirection = .unchanged,
         launchDirection: ROMDirection,
         peakDirection: ROMDirection,
         
         greaterThanStartFeedback: String,
         smallerThanEndFeedback: String) {
        
        self.feature = feature
        
        self.totalCycle = totalCycle
        self.targetCycle = targetCycle
        
        self.beingIllegal = false
        self.currentAngle = 0
        
        self.peakedFlag = false
        self.launchedFlag = false
        
        self.launchResult = launchResult
        self.peakResult = peakResult

        self.currentRomState = currentRomState
        
        self.currentDirection = .unchanged
        self.launchDirection = launchDirection
        self.peakDirection = peakDirection
        
        self.wentThroughMiddlePeakToLaunch = false
        self.wentThroughMiddleLaunchToPeak = false
        
        self.correctionStyle = correctionStyle ?? .normal(correctionRanges: [
            QuickPose.Style.ConditionalColor(min: launchResult.angleValue - launchResult.angleBlur,
                                              max: launchResult.angleValue + launchResult.angleBlur, color: UIColor.green),
            QuickPose.Style.ConditionalColor(min: peakResult.angleValue - peakResult.angleBlur,
                                              max: peakResult.angleValue + peakResult.angleBlur, color: UIColor.green)
        ])
        
        self.correctionStyle_HideArc = correctionStyle_HideArc ?? .hideArc(correctionRanges: [
            QuickPose.Style.ConditionalColor(min: launchResult.angleValue - launchResult.angleBlur,
                                              max: launchResult.angleValue + launchResult.angleBlur, color: UIColor.green),
            QuickPose.Style.ConditionalColor(min: peakResult.angleValue - peakResult.angleBlur,
                                              max: peakResult.angleValue + peakResult.angleBlur, color: UIColor.green)
        ])
        
        self.illegalStyle = illegalStyle ?? QuickPose.Style(relativeFontSize: 0.9, relativeArcSize: 0.4, relativeLineWidth: 1.3, color: UIColor.red)
        self.illegalStyle_HideArc = illegalStyle_HideArc ?? QuickPose.Style(relativeFontSize: 0, relativeArcSize: 0, relativeLineWidth: 1.3, color: UIColor.red)
        
        self.greaterThanStartFeedback = greaterThanStartFeedback
        self.smallerThanEndFeedback = smallerThanEndFeedback
    }
    
    mutating func updateCurrentStyles(showArc: Bool) {
        self.currentCorrectionStyle = showArc ? correctionStyle : correctionStyle_HideArc
        self.currentIllegalStyle = showArc ? illegalStyle : illegalStyle_HideArc
    }

    
    static func calculateMiddleAngle(from start: Double, to end: Double, direction: ROMDirection) -> Int {
        switch direction {
        case .increase:
            if end >= start {
                return Int((start + end) / 2)
            } else {
                let wrappedEnd = end + 360
                return Int(((start + wrappedEnd) / 2).truncatingRemainder(dividingBy: 360))
            }
        case .decrease:
            if start >= end {
                return Int((start + end) / 2)
            } else {
                let wrappedEnd = end - 360
                var middle = (start + wrappedEnd) / 2
                if middle < 0 { middle += 360 }
                return Int(middle)
            }
        case .unchanged:
            return Int(start) // hoặc throw error, hoặc quyết định cách xử lý
        }
    }
}

struct LimbGroup {
    var name: String
    var acceptedAngleValueDifference: Double
    var angleValueDifferenceFeedback: String
    var isAccepted: Bool = false
    var beingIllegal: Bool = false
    var left: MovementTarget
    var right: MovementTarget
}


struct GuardTarget {
    var feature: QuickPose.Feature
    var acceptanceStyle: QuickPose.Style
    var currentAngle: Double
    var guardResult: ROMRangeStartEndResult
    
    init(feature: QuickPose.Feature,
         acceptanceStyle: QuickPose.Style? = nil,
         hiddenStyle: Bool = true,
         guardResult: ROMRangeStartEndResult) {
        self.feature = feature
        self.currentAngle = 0
        self.guardResult = guardResult
        
        if let acceptanceStyle = acceptanceStyle {
            self.acceptanceStyle = acceptanceStyle
        } else {
            if hiddenStyle {
                self.acceptanceStyle = QuickPose.Style(hidden: true)
            } else {
                self.acceptanceStyle = QuickPose.Style(relativeFontSize: 0, relativeArcSize: 0, relativeLineWidth: 1.3, color: UIColor.red, conditionalColors: [QuickPose.Style.ConditionalColor(min: guardResult.startAngleValue, max: guardResult.endAngleValue, color: UIColor.white)])
            }
        }
    }
}

struct GuardGroup {
    var name: String
    var group: GuardTarget
    var greaterThanLimitFeedback: String?
    var smallerThanLimitFeedback: String?
}


struct FitnessExerciseAdjustment {
    var limbGroups: [LimbGroup]
    var guardGroups: [GuardGroup]?
    var isMutated: Bool = false
    var mutationDate: Date? = nil
    var startAcceptedPeakDuration: Double = 0
    var endAcceptedPeakDuration: Double = 2
    var peakDurationFeedback: String?
    var launchDurationFeedback: String?
}





