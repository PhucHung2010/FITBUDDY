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

class FitnessExercisePerformance: PoseDetection {
    @Published var modelConfig: QuickPose.ModelConfig
    
    @Published var targetCount: Int?
    @Published var targetTime: Int?
    
    @Published var totalCorrect: Int = 0
    @Published var totalIncorrect: Int = 0
    
    @Published var totalTime: Int = 0
    
    @Published var feedback: Bool
    @Published var feedbackText: [String]? = []
    
    @Published var controller: FitnessExerciseAdjustment?
    @Published var exerciseStatus: exerciseStatus = .setting {
        didSet {
            if exerciseStatus != .traning {
                TextSpeech.stop()
            }
        }
    }
    
    @Published var keepAvailable: Bool = false
    
    init(modelConfig: QuickPose.ModelConfig = QuickPose.ModelConfig(detailedFaceTracking: false, detailedHandTracking: false),
         targetCount: Int? = nil,
         targetTime: Int? = nil,
         feedback: Bool = false,
         controller: FitnessExerciseAdjustment? = nil,
         keepAvailable: Bool = false) {
        self.modelConfig = modelConfig
        self.targetCount = targetCount
        self.targetTime = targetTime
        self.totalCorrect = 0
        self.totalIncorrect = 0
        self.totalTime = 0
        self.feedback = feedback
        self.feedbackText = []
        self.controller = controller
        self.exerciseStatus = .setting
        self.keepAvailable = keepAvailable
    }
    
    private(set) var isRunning: Bool = false
    
    func reinitialize() {
        self.isRunning = false
        self.quickPose.stop()
        TextSpeech.stop()
        self.exerciseStatus = .setting
        self.totalCorrect = 0
        self.totalIncorrect = 0
        self.totalTime = 0
        self.feedbackText = []
        self.overlayImage = nil
    }
    
    func updateFeedback(newFeedback: String?) {
        guard feedback, exerciseStatus == .traning, let feedback = newFeedback else { return }
        let trimmed = feedback.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.exerciseStatus == .traning else {
                TextSpeech.stop()
                return
            }
            if self.feedbackText?.last != trimmed {
                self.feedbackText?.append(trimmed)
            }
            TextSpeech.shared.say(text: trimmed, isExerciseActive: self.exerciseStatus == .traning)
        }
    }
    
    
    func perform() {
        guard !isRunning else {
            print("[FitnessExercisePerformance] QuickPose is already running, skipping redundant start.")
            return
        }
        isRunning = true
        performHUMANAllInOnePlaceUpdate()
    }
    
    func performHUMANAllInOnePlaceUpdate() {
        guard self.controller != nil else { return }
        
        // Set style for limb group
        if let indices = self.controller?.limbGroups.indices {
            for index in indices {
                self.controller?.limbGroups[index].left.updateCurrentStyles(showArc: self.showArc)
                self.controller?.limbGroups[index].right.updateCurrentStyles(showArc: self.showArc)
            }
        }
        
        guard let activeController = self.controller else { return }
        
        var features: [QuickPose.Feature] = []
        // Set style for guard group
        if let guardGroups = activeController.guardGroups {
            features = guardGroups.map { $0.group.feature.restyled($0.group.acceptanceStyle) }
        }
        
        features += activeController.limbGroups.flatMap {
            [$0.left.feature.restyled($0.left.currentCorrectionStyle ?? $0.left.correctionStyle),
             $0.right.feature.restyled($0.right.currentCorrectionStyle ?? $0.right.correctionStyle)]
        }
        
        // overlay feature
        var overlayFeatures: [QuickPose.Feature] = features
        
        var controllerLimbGroups = activeController.limbGroups
        var controllerIsMutated = activeController.isMutated
        var controllerMutationDate = activeController.mutationDate
        var newTotalCorrect = self.totalCorrect
        var newTotalIncorrect = self.totalIncorrect
        
        self.quickPose.start(features: features, modelConfig: self.modelConfig) { [weak self] status, outputImage, result, _, _ in
            guard let self = self, let currentCtrl = self.controller else { return }
            
            // Mark model as ready on first successful callback
            if !self.isModelReady {
                DispatchQueue.main.async {
                    self.isModelReady = true
                }
            }
            
            DispatchQueue.main.async {
                self.overlayImage = outputImage
            }
            
            controllerLimbGroups = currentCtrl.limbGroups
            controllerIsMutated = currentCtrl.isMutated
            controllerMutationDate = currentCtrl.mutationDate
            newTotalCorrect = self.totalCorrect
            newTotalIncorrect = self.totalIncorrect
            
            // Guard group checking
            if let guardGroups = currentCtrl.guardGroups {
                guard guardGroups.allSatisfy({
                    if let angle = result[$0.group.feature]?.value {
                        /// start angle value is the smallest angle in range of motion
                        if angle < $0.group.guardResult.startAngleValue {
                            self.updateFeedback(newFeedback: $0.smallerThanLimitFeedback)
                            return false
                        }
                        /// end angle value is the greatest angle in range of motion
                        else if angle > $0.group.guardResult.endAngleValue {
                            self.updateFeedback(newFeedback: $0.greaterThanLimitFeedback)
                            return false
                        }
                        return true
                    } else {
                        return true
                    }
                }) else {
                    return
                }
            }
            
            // limb group checking
            for index in currentCtrl.limbGroups.indices {
                var group = currentCtrl.limbGroups[index]
                
                guard let leftVal = result[group.left.feature]?.value,
                      let rightVal = result[group.right.feature]?.value else {
                    continue
                }

                group.left.currentAngle = leftVal
                group.right.currentAngle = rightVal

                /// angle value acceptance checking
                if abs(group.left.currentAngle - group.right.currentAngle) <= group.acceptedAngleValueDifference {
                    /// tracking movement
                    let groupStatusBeforeChecking = (!group.left.beingIllegal && !group.right.beingIllegal) ? true : false
                    self.processMovementTarget(&group.left, overlayFeatures: &overlayFeatures)
                    self.processMovementTarget(&group.right, overlayFeatures: &overlayFeatures)
                    
                    if (group.left.totalCycle == group.left.targetCycle)
                        && (group.right.totalCycle == group.right.targetCycle)
                        && !group.left.beingIllegal
                        && !group.right.beingIllegal {
                        
                        /// mark accepted
                        group.isAccepted = true
                        /// mark mutated
                        if currentCtrl.isMutated == false {
                            controllerIsMutated = true
                        }
                        if currentCtrl.mutationDate == nil {
                            controllerMutationDate = Date()
                        }
                        
                        /// reset limb group cycle
                        group.left.totalCycle = 0
                        group.right.totalCycle = 0
                    }
                    else if (group.left.beingIllegal || group.right.beingIllegal) && groupStatusBeforeChecking {
                        group.left.totalCycle = 0
                        group.right.totalCycle = 0
                        group.beingIllegal = true
                    }
                }
                else {
                    self.updateFeedback(newFeedback: group.angleValueDifferenceFeedback)
                }
                
                controllerLimbGroups[index] = group
            }
           
            if self.theresGroupBeingIllegal(target: currentCtrl.limbGroups) {
                newTotalIncorrect += 1
                for index in currentCtrl.limbGroups.indices {
                    controllerLimbGroups[index].beingIllegal = false
                }
                for index in currentCtrl.limbGroups.indices {
                    controllerLimbGroups[index].isAccepted = false
                    controllerLimbGroups[index].left.totalCycle = 0
                    controllerLimbGroups[index].right.totalCycle = 0
                }
                controllerIsMutated = false
                controllerMutationDate = nil
            }
            
            if currentCtrl.isMutated {
                if let date = currentCtrl.mutationDate {
                    let currentTime = Date()
                    let timeDifference = currentTime.timeIntervalSince(date)
                    
                    if timeDifference <= currentCtrl.endAcceptedPeakDuration {
                        if self.isAllAccepted(target: currentCtrl.limbGroups) {
                            if currentCtrl.startAcceptedPeakDuration <= timeDifference {
                                newTotalCorrect += 1
                                if let target = self.targetCount, target > 0, newTotalCorrect >= target {
                                    AudioServicesPlaySystemSound(1114)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                                        self?.isRunning = false
                                        self?.quickPose.stop()
                                        self?.exerciseStatus = .summary
                                    }
                                } else {
                                    AudioServicesPlaySystemSound(1113)
                                }
                                self.updateFeedback(newFeedback: "")
                            } else {
                                newTotalIncorrect += 1
                                self.updateFeedback(newFeedback: currentCtrl.launchDurationFeedback)
                            }
                            for index in currentCtrl.limbGroups.indices {
                                controllerLimbGroups[index].isAccepted = false
                                controllerLimbGroups[index].left.totalCycle = 0
                                controllerLimbGroups[index].right.totalCycle = 0
                            }
                            controllerIsMutated = false
                            controllerMutationDate = nil
                        }
                    } else {
                        newTotalIncorrect += 1
                        self.updateFeedback(newFeedback: currentCtrl.peakDurationFeedback)
                        for index in currentCtrl.limbGroups.indices {
                            controllerLimbGroups[index].isAccepted = false
                            controllerLimbGroups[index].left.totalCycle = 0
                            controllerLimbGroups[index].right.totalCycle = 0
                        }
                        controllerIsMutated = false
                        controllerMutationDate = nil
                    }
                }
            }
            self.quickPose.update(features: overlayFeatures)
           
            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.controller != nil else { return }
                self.controller?.limbGroups = controllerLimbGroups
                self.controller?.isMutated = controllerIsMutated
                self.controller?.mutationDate = controllerMutationDate
                self.totalCorrect = newTotalCorrect
                self.totalIncorrect = newTotalIncorrect
            }
        }
    }
    
    func restartControllerCounting() -> Void {
        guard let count = self.controller?.limbGroups.count else { return }
        for index in 0..<count {
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let currentCount = self.controller?.limbGroups.count, index < currentCount else { return }
                self.controller?.limbGroups[index].isAccepted = false
                self.controller?.limbGroups[index].left.totalCycle = 0
                self.controller?.limbGroups[index].right.totalCycle = 0
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.controller?.isMutated = false
            self?.controller?.mutationDate = nil
        }
    }
    
    
    func isAllAccepted(target: [LimbGroup]) -> Bool {
        target.allSatisfy { $0.isAccepted }
    }
    
    func theresGroupBeingIllegal(target: [LimbGroup]) -> Bool {
        target.contains { $0.beingIllegal }
    }
    
    
    func processMovementTarget(_ target: inout MovementTarget, overlayFeatures: inout [QuickPose.Feature]) {
        func resetFlags() -> Void {
            target.wentThroughMiddleLaunchToPeak = false
            target.wentThroughMiddlePeakToLaunch = false
        }
        
        func checkMiddlePass(current: Double,
                             state: ROMState,
                             from: (value: Double, blur: Double),
                             to: (value: Double, blur: Double),
                             direction: ROMDirection) -> Bool {
            let start: Double
            let end: Double
            
            if direction == .increase {
                start = from.value + from.blur
                end   = to.value - to.blur
            } else {
                start = from.value - from.blur
                end   = to.value + to.blur
            }
            return isInRange(current, between: start, and: end, direction: direction)
        }
        
        if !target.wentThroughMiddlePeakToLaunch && target.currentRomState == .launch {
            if checkMiddlePass(current: target.currentAngle,
                               state: .launch,
                               from: (target.peakResult.angleValue, target.peakResult.angleBlur),
                               to: (target.launchResult.angleValue, target.launchResult.angleBlur),
                               direction: target.launchDirection) {
                target.wentThroughMiddlePeakToLaunch = true
            }
        }

        if !target.wentThroughMiddleLaunchToPeak && target.currentRomState == .peak {
            if checkMiddlePass(current: target.currentAngle,
                               state: .peak,
                               from: (target.launchResult.angleValue, target.launchResult.angleBlur),
                               to: (target.peakResult.angleValue, target.peakResult.angleBlur),
                               direction: target.peakDirection) {
                target.wentThroughMiddleLaunchToPeak = true
            }
        }
        
        guard let index = overlayFeatures.firstIndex(of: target.feature) else { return }
        

        if isROMSatisfied(current: target.currentAngle,
                         angleValue: target.launchResult.angleValue,
                         angleBlur: target.launchResult.angleBlur) {
            if target.currentRomState == .launch {
                if target.wentThroughMiddlePeakToLaunch{
                    target.currentRomState = .peak
                    resetFlags()
                    if target.beingIllegal { target.beingIllegal = false }
                    
                    overlayFeatures[index] = target.feature.restyled(target.currentCorrectionStyle ?? target.correctionStyle)
                }
            } else {
                if target.wentThroughMiddleLaunchToPeak {
                    if !target.beingIllegal { target.beingIllegal = true }
                    resetFlags()
                    overlayFeatures[index] = target.feature.restyled(target.currentIllegalStyle ?? target.illegalStyle)
                    
                    updateFeedback(newFeedback: target.smallerThanEndFeedback)
                }
            }
        }
        else if isROMSatisfied(current: target.currentAngle,
                                 angleValue: target.peakResult.angleValue,
                                 angleBlur: target.peakResult.angleBlur) {
            if target.currentRomState == .peak {
                if target.wentThroughMiddleLaunchToPeak {
                    target.currentRomState = .launch
                    resetFlags()
                    if target.beingIllegal { target.beingIllegal = false }
                    
                    overlayFeatures[index] = target.feature.restyled(target.currentCorrectionStyle ?? target.correctionStyle)
                    
                    if target.totalCycle >= target.targetCycle {target.totalCycle = target.targetCycle}
                    else {target.totalCycle += 1}
                }
            } else {
                if target.wentThroughMiddlePeakToLaunch {
                    if !target.beingIllegal { target.beingIllegal = true }
                    resetFlags()
                    
                    overlayFeatures[index] = target.feature.restyled(target.currentIllegalStyle ?? target.illegalStyle)
                    updateFeedback(newFeedback: target.greaterThanStartFeedback)
                }
            }
        }
    }

    func isROMSatisfied(current: Double, angleValue: Double, angleBlur: Double) -> Bool {
        return isInRange(current, between: angleValue - angleBlur, and: angleValue + angleBlur, direction: .increase)
    }
    
    func isInRange(_ angle: Double,
                 between start: Double,
                 and end: Double,
                 direction: ROMDirection = .increase) -> Bool {
        func norm(_ a: Double) -> Double {
            let r = a.truncatingRemainder(dividingBy: 360)
            return r >= 0 ? r : r + 360
        }
        let a = norm(angle)
        let s = norm(start)
        let e = norm(end)
        switch direction {
        case .increase:
            if s <= e {
                return (s <= a && a <= e)
            } else {
                return (a >= s || a <= e)
            }
            
        case .decrease:
            if e <= s {
                return (e <= a && a <= s)
            } else {
                return (a >= e || a <= s)
            }
        case .unchanged:
            return false
        }
    }
}


