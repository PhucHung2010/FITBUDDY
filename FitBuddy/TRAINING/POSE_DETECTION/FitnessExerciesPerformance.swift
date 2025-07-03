//
//  FitnessExerciesPerformance.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 15/06/2025.
//

import SwiftUI
import AVFoundation
import QuickPoseCore
import QuickPoseSwiftUI
import AVFoundation
import AudioToolbox
import Foundation

// MARK: EXERCIES ADJUSTMENT
class FitnessExercisePerformance: PoseDetection {
    
    override init(targetCount: Int? = nil,
                  targetTime: Int? = nil,
                  feedback: Bool = true,
                  controller: FitnessExerciseAdjustment? = nil,
                  modelConfig: QuickPose.ModelConfig = QuickPose.ModelConfig(
                    detailedFaceTracking: false,
                    detailedHandTracking: false)
    ) {
        super.init(targetCount: targetCount,
                   targetTime: targetTime,
                   feedback: feedback,
                   controller: controller,
                   modelConfig: modelConfig)
    }
    
    func Performance() {
        // MARK: CHUA KIEM CHUNG, CO THE BI LOI CONTROLLER DO KHONG PHAI MUTATE TREN BIEN CONTROLLER
        if controller != nil {
            var features: [QuickPose.Feature] = []
            if let guardGroups = controller!.guardGroups {
                features = guardGroups.flatMap{[$0.group.feature.restyled($0.group.acceptanceStyle)]} as! [QuickPose.Feature]
            }
            features += controller!.limbGroups.flatMap{[$0.left.feature.restyled($0.left.correctionStyle), $0.right.feature.restyled($0.right.correctionStyle)]}
            var overlayFeatures: [QuickPose.Feature] = features
            
            self.quickPose.start(features: features, modelConfig: modelConfig) {[self] status, outputImage, result, feedback, _ in
                self.overlayImage = outputImage

                if let guardGroups = controller!.guardGroups {
                    guard guardGroups.allSatisfy({
                        let angle = result[$0.group.feature]?.value ?? 0
                        return angle >= $0.group.guardResult.startAngleValue &&
                               angle <= $0.group.guardResult.endAngleValue
                    }) else {
                        return
                    }
                }

                    for index in controller!.limbGroups.indices {
                        var group = controller!.limbGroups[index]
                        group.left.currentAngle = result[group.left.feature]?.value ?? 0
                        group.right.currentAngle = result[group.right.feature]?.value ?? 0
                        
                        if abs(group.left.currentAngle - group.right.currentAngle) <= group.acceptedAngleValueDifference {
                            processMovementTarget(&group.left, overlayFeatures: &overlayFeatures)
                            processMovementTarget(&group.right, overlayFeatures: &overlayFeatures)
                            
                            if group.left.cycle == group.left.targetCycle && group.right.cycle == group.right.targetCycle
                                && !group.left.beingIllegal && !group.right.beingIllegal {
                                group.isMutated = true
                                controller!.isMutated = true
                                if controller!.mutationDate == nil {
                                    controller!.mutationDate = Date()
                                }
                                group.left.cycle = 0
                                group.right.cycle = 0
                            }
                            if group.left.beingIllegal || group.right.beingIllegal {
                                group.left.cycle = 0
                                group.right.cycle = 0
                                group.left.beingIllegal = false
                                group.right.beingIllegal = false
                            }
                            controller!.limbGroups[index] = group
                        }
                        else {
                            updateIllegalFeature(target: group.left, overlayFeatures: &overlayFeatures)
                            updateIllegalFeature(target: group.right, overlayFeatures: &overlayFeatures)
                        }
                    }
                
                
                if controller!.isMutated {
                    if let date = controller!.mutationDate {
                        let currentTime = Date()
                        let timeDifference = currentTime.timeIntervalSince(date)
                        if timeDifference <= controller!.endAcceptedPeakDuration  {
                            if isAllMutated(target: controller!.limbGroups)  {
                                if controller!.startAcceptedPeakDuration <= timeDifference {
                                    totalCorrect += 1
                                }
                                restartControllerCounting()
                            }
                        } else {
                            restartControllerCounting()
                        }
                    }
                }
                quickPose.update(features: overlayFeatures)
            }
        }
    }
    
    
    func restartControllerCounting() -> Void {
        if controller != nil {
            for index in controller!.limbGroups.indices {
                controller!.limbGroups[index].isMutated = false
            }
            controller!.isMutated = false
            controller!.mutationDate = nil
        }
    }
    
    
    func isAllMutated(target: [LimbGroup]) -> Bool {
        for group in target {
            if !group.isMutated {return false}
        }
        return true
    }
    
    
    func updateIllegalFeature(target: MovementTarget, overlayFeatures: inout [QuickPose.Feature]) -> Void {
        if let arrIndex = overlayFeatures.firstIndex(of: target.feature) {
            overlayFeatures[arrIndex] = target.feature.restyled(target.illegalStyle)
        }
    }
    
    func updateCorrectionFeature(target: MovementTarget, overlayFeatures: inout [QuickPose.Feature]) -> Void {
        if let arrIndex = overlayFeatures.firstIndex(of: target.feature) {
            overlayFeatures[arrIndex] = target.feature.restyled(target.correctionStyle)
        }
    }
    
    func processMovementTarget(_ target: inout MovementTarget, overlayFeatures: inout [QuickPose.Feature]) {
        
        func resetFlags() -> Void {
            target.wentThroughMiddleLaunchToPeak = false
            target.wentThroughMiddlePeakToLaunch = false
        }
        
        if !target.wentThroughMiddlePeakToLaunch &&
            isROMSatisfied(current: target.currentAngle,
                           angleValue: Double(target.peakToLaunchMiddleRangeResult),
                           angleBlur: Double(target.middleRangeResultBlur)) {
            target.wentThroughMiddlePeakToLaunch = true
        }
        if !target.wentThroughMiddleLaunchToPeak &&
            isROMSatisfied(current: target.currentAngle,
                           angleValue: Double(target.launchToPeakMiddleRangeResult),
                           angleBlur: Double(target.middleRangeResultBlur)) {
            target.wentThroughMiddleLaunchToPeak = true
        }
        
        guard let index = overlayFeatures.firstIndex(of: target.feature) else { return }
        

        if isROMSatisfied(current: target.currentAngle,
                         angleValue: target.launchResult.angleValue,
                         angleBlur: target.launchResult.angleBlur) {
            if target.currentRomState == .launch {
                if target.wentThroughMiddlePeakToLaunch{
                    playTing()
                    target.currentRomState = .peak
                    resetFlags()
                    overlayFeatures[index] = target.feature.restyled(target.correctionStyle)
                }
            } else {
                if target.wentThroughMiddleLaunchToPeak {
                    target.beingIllegal = true
                    target.currentRomState = .peak
                    resetFlags()
                    overlayFeatures[index] = target.feature.restyled(target.illegalStyle)
                }
            }
        } else if isROMSatisfied(current: target.currentAngle,
                                 angleValue: target.peakResult.angleValue,
                                 angleBlur: target.peakResult.angleBlur) {
            if target.currentRomState == .peak {
                if target.wentThroughMiddleLaunchToPeak {
                    playTing2()
                    target.currentRomState = .launch
                    resetFlags()
                    overlayFeatures[index] = target.feature.restyled(target.correctionStyle)
                    
                    if target.cycle >= target.targetCycle {target.cycle = target.targetCycle}
                    else {target.cycle += 1}
                }
            } else {
                if target.wentThroughMiddlePeakToLaunch {
                    target.beingIllegal = true
                    target.currentRomState = .launch
                    resetFlags()
                    overlayFeatures[index] = target.feature.restyled(target.illegalStyle)
                }
            }
        }
    }

    func updateHistoryAndDetectDirection(feature: QuickPose.Feature, group: inout MovementTarget) -> ROMDirection {
        var history = group.angleHistories[feature] ?? []
        history.append(group.currentAngle)
        if history.count > group.historyLength {
            history.removeFirst()
        }
        group.angleHistories[feature] = history

        // Dự đoán hướng bằng cách so sánh trung bình nửa đầu với nửa sau
        guard history.count >= 2 else {
            return .unchanged
        }

        let mid = history.count / 2
        let startAvg = history.prefix(mid).reduce(0, +) / Double(mid)
        let endAvg = history.suffix(from: mid).reduce(0, +) / Double(history.count - mid)

        if endAvg - startAvg > 1 {
            return .increase
        } else if startAvg - endAvg > 1 {
            return .decrease
        } else {
            return .unchanged
        }
    }

    func isROMSatisfied(current: Double, angleValue: Double, angleBlur: Double) -> Bool {
        return angleValue - angleBlur <= current && current <= angleValue + angleBlur
    }
}
