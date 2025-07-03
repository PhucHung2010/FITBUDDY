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

struct MovementTarget {
    var feature: QuickPose.Feature
    var correctionStyle: QuickPose.Style
    var illegalStyle: QuickPose.Style
    
    var cycle: Int
    var targetCycle: Int
    var beingIllegal: Bool
    
    var currentAngle: Double

    var launchResult: ROMRangeBlurResult
    var peakResult: ROMRangeBlurResult
    
    var launchToPeakMiddleRangeResult: Int
    var peakToLaunchMiddleRangeResult: Int
    var middleRangeResultBlur: Int
    
    var wentThroughMiddlePeakToLaunch: Bool
    var wentThroughMiddleLaunchToPeak: Bool

    var currentRomState: ROMState

    var angleHistories: [QuickPose.Feature: [Double]]
    var historyLength: Int
    var currentDirection: ROMDirection
    var launchDirection: ROMDirection
    var peakDirection: ROMDirection

    init(feature: QuickPose.Feature,
         correctionStyle: QuickPose.Style?,
         illegalStyle: QuickPose.Style = QuickPose.Style(relativeFontSize: 1, relativeArcSize: 0.4, relativeLineWidth: 1.3, color: UIColor.red),
         cycle: Int = 0,
         targetCycle: Int = 1,
         beingIllegal: Bool = false,
         
         currentAngle: Double = 0,
         
         launchResult: ROMRangeBlurResult,
         peakResult: ROMRangeBlurResult,
         launchToPeakMiddleRangeResult: Int = 0,
         peakToLaunchMiddleRangeResult: Int = 0,
         
         wentThroughMiddlePeakToLaunch: Bool = false,
         wentThroughMiddleLaunchToPeak: Bool = false,
         middleRangeResultBlur: Int,
         
         currentRomState: ROMState = .peak,
         
         angleHistories: [QuickPose.Feature: [Double]] = [:],
         historyLength: Int = 8,
         
         currentDirection: ROMDirection = .unchanged,
         launchDirection: ROMDirection,
         peakDirection: ROMDirection) {
        self.feature = feature
        self.cycle = cycle
        self.targetCycle = targetCycle
        self.beingIllegal = beingIllegal
        self.currentAngle = currentAngle
        
        self.launchResult = launchResult
        self.peakResult = peakResult

        self.currentRomState = currentRomState

        self.angleHistories = angleHistories
        self.historyLength = historyLength
        self.currentDirection = currentDirection
        self.launchDirection = launchDirection
        self.peakDirection = peakDirection
        
        self.launchToPeakMiddleRangeResult = MovementTarget.calculateMiddleAngle(
            from: launchResult.angleValue,
            to: peakResult.angleValue,
            direction: peakDirection
        )
        self.peakToLaunchMiddleRangeResult = MovementTarget.calculateMiddleAngle(
            from: peakResult.angleValue,
            to: launchResult.angleValue,
            direction: launchDirection
        )
        self.middleRangeResultBlur = middleRangeResultBlur
        self.wentThroughMiddlePeakToLaunch = wentThroughMiddlePeakToLaunch
        self.wentThroughMiddleLaunchToPeak = wentThroughMiddleLaunchToPeak
        
        let minAngle = min(peakResult.angleValue, launchResult.angleValue)
        let maxAngle = max(peakResult.angleValue, launchResult.angleValue)
        if let correctionStyle = correctionStyle {
            self.correctionStyle = correctionStyle
        } else {
            self.correctionStyle = QuickPose.Style(relativeFontSize: 1, relativeArcSize: 0.4, relativeLineWidth: 1.3, conditionalColors: [QuickPose.Style.ConditionalColor(min: minAngle, max: maxAngle, color: UIColor.green)])
        }
        self.illegalStyle = illegalStyle
    }
    
    
    func setMiddleRangeResult(launchDirection: ROMDirection, peakDirection: ROMDirection) -> (launchToPeakMiddle: Int, peakToLaunchMiddle: Int) {
        let launchAngle = launchResult.angleValue
        let peakAngle = peakResult.angleValue

        let launchToPeak = MovementTarget.calculateMiddleAngle(from: launchAngle, to: peakAngle, direction: launchDirection)
        let peakToLaunch = MovementTarget.calculateMiddleAngle(from: peakAngle, to: launchAngle, direction: peakDirection)

        return (launchToPeak, peakToLaunch)
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
    var acceptedPeakDuration: Double = 2
    var isMutated: Bool = false
    var left: MovementTarget
    var right: MovementTarget
}


struct GuardTarget {
    var feature: QuickPose.Feature
    var acceptanceStyle: QuickPose.Style
    var currentAngle: Double
    var guardResult: ROMRangeStartEndResult
    
    init(feature: QuickPose.Feature,
         acceptanceStyle: QuickPose.Style?,
         currentAngle: Double = 0,
         guardResult: ROMRangeStartEndResult) {
        self.feature = feature
        self.currentAngle = currentAngle
        self.guardResult = guardResult
        
        if let acceptanceStyle = acceptanceStyle {
            self.acceptanceStyle = acceptanceStyle
        } else {
            self.acceptanceStyle = QuickPose.Style(relativeFontSize: 1, relativeArcSize: 0.4, relativeLineWidth: 1.3, color: UIColor.red, conditionalColors: [QuickPose.Style.ConditionalColor(min: guardResult.startAngleValue, max: guardResult.endAngleValue, color: UIColor.white)])
        }
    }
}

struct GuardGroup {
    var name: String
    var group: GuardTarget
    var feedback: String
}


struct FitnessExerciseAdjustment {
    var limbGroups: [LimbGroup]
    var guardGroups: [GuardGroup]?
    var isMutated: Bool = false
    var mutationDate: Date? = nil
    var startAcceptedPeakDuration: Double = 0
    var endAcceptedPeakDuration: Double = 2
}
