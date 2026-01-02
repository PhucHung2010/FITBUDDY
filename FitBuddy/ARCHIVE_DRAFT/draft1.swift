//////
//////  FitnessExerciesPerformance.swift
//////  FitBuddy
//////
//////  Created by Hung Nguyen on 15/06/2025.
//////
////
//
//
//
//
//

import SwiftUI
import AVFoundation
import QuickPoseCore
import QuickPoseSwiftUI
import AVFoundation
import AudioToolbox
import Foundation



extension FitnessExercisePerformance {
    func performHUMAN() {
        var features: [QuickPose.Feature] = []
        // Set style for guard group
        if let guardGroups = controller!.guardGroups {
            features = guardGroups.map { $0.group.feature.restyled($0.group.acceptanceStyle) }
        }
        // Set style for limb group
        features += controller!.limbGroups.flatMap{[$0.left.feature.restyled($0.left.correctionStyle), $0.right.feature.restyled($0.right.correctionStyle)]}
        // overlay feature
        var overlayFeatures: [QuickPose.Feature] = features

        self.quickPose.start(features: features, modelConfig: self.modelConfig) {[self] status, outputImage, result, feedback, _ in
            // Guard group checking
            if let guardGroups = controller!.guardGroups {
                guard guardGroups.allSatisfy({
                    if let angle = result[$0.group.feature]?.value {
                        /// start angle value is the smallest angle in range of motion
                        if angle < $0.group.guardResult.startAngleValue {
                            self.updateFeedback(newFeedback: $0.smallerThanLimitFeedback)
                            
                        }
                        /// end angle value is the greatest angle in range of motion
                        else if angle > $0.group.guardResult.endAngleValue {
                            self.updateFeedback(newFeedback: $0.greaterThanLimitFeedback)
                        }
                        return angle >= $0.group.guardResult.startAngleValue &&
                        angle <= $0.group.guardResult.endAngleValue
                    } else {
                        return false
                    }
                }) else {
                    return
                }
            }
            
            // limb group checking
            for index in controller!.limbGroups.indices {
                var group = controller!.limbGroups[index]
                
                guard let leftVal = result[group.left.feature]?.value,
                      let rightVal = result[group.right.feature]?.value else {
                    return
                }

                group.left.currentAngle = leftVal
                group.right.currentAngle = rightVal

                
                /// angle value acceptance checking
                if abs(group.left.currentAngle - group.right.currentAngle) <= group.acceptedAngleValueDifference {
                    /// tracking movement
                    self.processMovementTarget(&group.left, overlayFeatures: &overlayFeatures)
                    self.processMovementTarget(&group.right, overlayFeatures: &overlayFeatures)
                    
                    if (group.left.totalCycle == group.left.targetCycle)
                        && (group.right.totalCycle == group.right.targetCycle)
                        && !group.left.beingIllegal
                        && !group.right.beingIllegal {
                        
                        /// mark accepted
                        group.isAccepted = true
                        /// mark mutated
                        DispatchQueue.main.async {
                            if self.controller?.isMutated == false {
                                self.controller!.isMutated = true
                            }
                            if self.controller!.mutationDate == nil {
                                /// start counting mutation date
                                self.controller!.mutationDate = Date()
                            }
                        }
                        
                        /// reset limb group cycle
                        group.left.totalCycle = 0
                        group.right.totalCycle = 0
                    }
                    else if group.left.beingIllegal || group.right.beingIllegal {
                        group.left.totalCycle = 0
                        group.right.totalCycle = 0
                        group.left.beingIllegal = false
                        group.right.beingIllegal = false
                        
                        group.beingIllegal = true
                    }
                }
                else {
                    /// mark limb group being illegal
                    if !group.beingIllegal {
                        updateIllegalFeature(target: group.left, overlayFeatures: &overlayFeatures)
                        updateIllegalFeature(target: group.right, overlayFeatures: &overlayFeatures)
                        DispatchQueue.main.async {
                            self.updateFeedback(newFeedback: group.angleValueDifferenceFeedback)
                        }
                        group.beingIllegal = true
                    }
                }
                
                /// update controller
                DispatchQueue.main.async {
                    self.controller!.limbGroups[index] = group
                }
            }
           
           if theresGroupBeingIllegal(target: controller!.limbGroups) {
               DispatchQueue.main.async {
                   self.totalIncorrect += 1
                   for index in self.controller!.limbGroups.indices {
                       self.controller!.limbGroups[index].beingIllegal = false
                   }
                   self.restartControllerCounting()
               }
           }
            
            if controller!.isMutated {
                if let date = controller!.mutationDate {
                    let currentTime = Date()
                    let timeDifference = currentTime.timeIntervalSince(date)
                    
                    if timeDifference <= controller!.endAcceptedPeakDuration  {
                        /// i don't check endAcceptedPeakDuration along with startAcceptedPeakDuration because we cannot know if all the limb group are done
                        if isAllAccepted(target: controller!.limbGroups)  {
                            if controller!.startAcceptedPeakDuration <= timeDifference {
                                DispatchQueue.main.async {
                                    self.totalCorrect += 1
                                    AudioServicesPlaySystemSound(1113)
                                    self.updateFeedback(newFeedback: "")
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.totalIncorrect += 1
                                    self.updateFeedback(newFeedback: self.controller?.launchDurationFeedback)
                                }
                            }
                            restartControllerCounting()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.totalIncorrect += 1
                            self.updateFeedback(newFeedback: self.controller?.peakDurationFeedback)
                        }
                        restartControllerCounting()
                    }
                }
            }
            quickPose.update(features: overlayFeatures)
           
           DispatchQueue.main.async {
               self.overlayImage = outputImage
           }
        }
    }
}






//
//extension FitnessExercisePerformance {
//    func performAI() {
//        var features: [QuickPose.Feature] = []
//        // Set style for guard group
//        if let guardGroups = controller!.guardGroups {
//            features = guardGroups.flatMap{[$0.group.feature.restyled($0.group.acceptanceStyle)]} as! [QuickPose.Feature]
//        }
//        // Set style for limb group
//        features += controller!.limbGroups.flatMap{[$0.left.feature.restyled($0.left.correctionStyle), $0.right.feature.restyled($0.right.correctionStyle)]}
//        // overlay feature
////        var overlayFeatures: [QuickPose.Feature] = features
//            
//        self.quickPose.start(features: features, modelConfig: self.modelConfig) { [self] status, outputImage, result, feedback, _ in
//            
//            // Make a copy of the limbGroups to work with off the main thread
//            var updatedLimbGroups = controller!.limbGroups
//            var newIsMutated = controller!.isMutated
//            var newMutationDate = controller!.mutationDate
//            var newTotalCorrect = self.totalCorrect
//            var newTotalIncorrect = self.totalIncorrect
//            var newFeedback: String? = nil
//            var newOverlayImage: UIImage? = nil
//            
//            var overlayFeatures = features // Copy overlay features for this frame
//            
//            // ---------- PROCESSING ----------
//            // Guard group checking
//            if let guardGroups = controller!.guardGroups {
//                guard guardGroups.allSatisfy({
//                    if let angle = result[$0.group.feature]?.value {
//                        if angle < $0.group.guardResult.startAngleValue {
//                            newFeedback = $0.smallerThanLimitFeedback
//                        } else if angle > $0.group.guardResult.endAngleValue {
//                            newFeedback = $0.greaterThanLimitFeedback
//                        }
//                        return angle >= $0.group.guardResult.startAngleValue &&
//                               angle <= $0.group.guardResult.endAngleValue
//                    }
//                    return false
//                }) else {
//                    return
//                }
//            }
//            
//            // Limb group checking
//            for index in updatedLimbGroups.indices {
//                var group = updatedLimbGroups[index]
//                
//                group.left.currentAngle = result[group.left.feature]?.value ?? 0
//                group.right.currentAngle = result[group.right.feature]?.value ?? 0
//                
//                if abs(group.left.currentAngle - group.right.currentAngle) <= group.acceptedAngleValueDifference {
//                    if group.beingIllegal {
//                        print("Update group being illegal into legal")
//                        group.beingIllegal = false
//                    }
//                    processMovementTarget(&group.left, overlayFeatures: &overlayFeatures)
//                    processMovementTarget(&group.right, overlayFeatures: &overlayFeatures)
//                    
//                    if (group.left.totalCycle == group.left.targetCycle)
//                        && (group.right.totalCycle == group.right.targetCycle)
//                        && !group.left.beingIllegal
//                        && !group.right.beingIllegal {
//                        
//                        group.isAccepted = true
//                        newIsMutated = true
//                        if newMutationDate == nil {
//                            newMutationDate = Date()
//                        }
//                        group.left.totalCycle = 0
//                        group.right.totalCycle = 0
//                    }
//                    else if group.left.beingIllegal || group.right.beingIllegal {
//                        group.left.totalCycle = 0
//                        group.right.totalCycle = 0
//                        group.left.beingIllegal = false
//                        group.right.beingIllegal = false
//                        newTotalIncorrect += 1
//                    }
//                }
//                else {
//                    if !group.beingIllegal {
//                        updateIllegalFeature(target: group.left, overlayFeatures: &overlayFeatures)
//                        updateIllegalFeature(target: group.right, overlayFeatures: &overlayFeatures)
//                        newFeedback = group.angleValueDifferenceFeedback
//                        newTotalIncorrect += 1
//                        group.beingIllegal = true
//                    }
//                }
//                
//                updatedLimbGroups[index] = group
//            }
//            
//            // Mutation timing check
//            // Mutation timing check
//            if newIsMutated, let date = newMutationDate {
//                let timeDifference = Date().timeIntervalSince(date)
//                if timeDifference <= controller!.endAcceptedPeakDuration {
//                    if isAllAccepted(target: updatedLimbGroups) {
//                        if controller!.startAcceptedPeakDuration <= timeDifference {
//                            newTotalCorrect += 1
//                            newFeedback = ""
//                            AudioServicesPlaySystemSound(1113)
//                        } else {
//                            newTotalIncorrect += 1
//                        }
//                        // Reset after counting to prevent continuous increment
//                        newIsMutated = false
//                        newMutationDate = nil
//                        for i in updatedLimbGroups.indices {
//                            updatedLimbGroups[i].isAccepted = false
//                        }
//                    }
//                } else {
//                    newTotalIncorrect += 1
//                    // Reset after counting
//                    newIsMutated = false
//                    newMutationDate = nil
//                    for i in updatedLimbGroups.indices {
//                        updatedLimbGroups[i].isAccepted = false
//                    }
//                }
//            }
//
//            
//            // Update overlay image
//            quickPose.update(features: overlayFeatures)
//            newOverlayImage = outputImage
//            
//            // ---------- MAIN THREAD UPDATE ----------
//            DispatchQueue.main.async {
//                self.controller!.limbGroups = updatedLimbGroups
//                self.controller!.isMutated = newIsMutated
//                self.controller!.mutationDate = newMutationDate
//                self.totalCorrect = newTotalCorrect
//                self.totalIncorrect = newTotalIncorrect
//                if let fb = newFeedback {
//                    self.updateFeedback(newFeedback: fb)
//                }
//                self.overlayImage = newOverlayImage
//            }
//        }
//    }
//}
//
//
//
//
//extension FitnessExercisePerformance {
//    func performOLD() {
//        var features: [QuickPose.Feature] = []
//        // Set style for guard group
//        if let guardGroups = controller!.guardGroups {
//            features = guardGroups.flatMap{[$0.group.feature.restyled($0.group.acceptanceStyle)]} as! [QuickPose.Feature]
//        }
//        // Set style for limb group
//        features += controller!.limbGroups.flatMap{[$0.left.feature.restyled($0.left.correctionStyle), $0.right.feature.restyled($0.right.correctionStyle)]}
//        // overlay feature
//        var overlayFeatures: [QuickPose.Feature] = features
//
//       self.quickPose.start(features: features, modelConfig: self.modelConfig) {[self] status, outputImage, result, feedback, _ in
//            // Set overlay image in every frames
//            // Guard group checking
//            if let guardGroups = controller!.guardGroups {
//                guard guardGroups.allSatisfy({
//                    if let angle = result[$0.group.feature]?.value {
//                        /// start angle value is the smallest angle in range of motion
//                        if angle < $0.group.guardResult.startAngleValue {
//                            self.updateFeedback(newFeedback: $0.smallerThanLimitFeedback)
//                        }
//                        /// end angle value is the greatest angle in range of motion
//                        else if angle > $0.group.guardResult.endAngleValue {
//                            self.updateFeedback(newFeedback: $0.greaterThanLimitFeedback)
//                        }
//                        return angle >= $0.group.guardResult.startAngleValue &&
//                        angle <= $0.group.guardResult.endAngleValue
//                    } else {
//                        return false
//                    }
//                }) else {
//                    return
//                }
//            }
//            
//            // limb group checking
//            for index in controller!.limbGroups.indices {
//                var group = controller!.limbGroups[index]
//                
//                /// collect angle value
//                group.left.currentAngle = result[group.left.feature]?.value ?? 0
//                group.right.currentAngle = result[group.right.feature]?.value ?? 0
//                
//                /// angle value acceptance checking
//                if abs(group.left.currentAngle - group.right.currentAngle) <= group.acceptedAngleValueDifference {
//                    if group.beingIllegal {
//                        group.beingIllegal = false
//                    }
//                    
//                    /// tracking movement
//                    self.processMovementTarget(&group.left, overlayFeatures: &overlayFeatures)
//                    self.processMovementTarget(&group.right, overlayFeatures: &overlayFeatures)
//                    
//                    
//                    
//                    if (group.left.totalCycle == group.left.targetCycle)
//                        && (group.right.totalCycle == group.right.targetCycle)
//                        && !group.left.beingIllegal
//                        && !group.right.beingIllegal {
//                        
//                        /// mark accepted
//                        group.isAccepted = true
//                        /// mark mutated
//                        DispatchQueue.main.async {
//                            self.controller!.isMutated = true
//                            if self.controller!.mutationDate == nil {
//                                /// start counting mutation date
//                                self.controller!.mutationDate = Date()
//                            }
//                        }
//                        
//                        /// reset limb group cycle
//                        group.left.totalCycle = 0
//                        group.right.totalCycle = 0
//                    }
//                    else if group.left.beingIllegal || group.right.beingIllegal {
//                        group.left.totalCycle = 0
//                        group.right.totalCycle = 0
//                        group.left.beingIllegal = false
//                        group.right.beingIllegal = false
//                        
//                        DispatchQueue.main.async {
//                            self.totalIncorrect += 1
//                        }
//                    }
//                }
//                else {
//                    /// mark limb group being illegal
//                    if !group.beingIllegal {
//                        updateIllegalFeature(target: group.left, overlayFeatures: &overlayFeatures)
//                        updateIllegalFeature(target: group.right, overlayFeatures: &overlayFeatures)
//                        
//                        DispatchQueue.main.async {
//                            self.updateFeedback(newFeedback: group.angleValueDifferenceFeedback)
//                            self.totalIncorrect += 1
//                        }
//                        
//                        group.beingIllegal = true
//                    }
//                }
//                
//                /// update controller
//                DispatchQueue.main.async {
//                    self.controller!.limbGroups[index] = group
//                }
//            }
//            
//            if controller!.isMutated {
//                if let date = controller!.mutationDate {
//                    let currentTime = Date()
//                    let timeDifference = currentTime.timeIntervalSince(date)
//                    
//                    if timeDifference <= controller!.endAcceptedPeakDuration  {
//                        /// i don't check endAcceptedPeakDuration along with startAcceptedPeakDuration because we cannot know if all the limb group are done
//                        if isAllAccepted(target: controller!.limbGroups)  {
//                            if controller!.startAcceptedPeakDuration <= timeDifference {
//                                DispatchQueue.main.async {
//                                    self.totalCorrect += 1
//                                    AudioServicesPlaySystemSound(1113)
//                                    self.updateFeedback(newFeedback: "")
//                                }
//                            } else {
//                                DispatchQueue.main.async {
//                                    self.totalIncorrect += 1
////                                    self.updateFeedback(newFeedback: self.controller?.launchDurationFeedback)
//                                }
//                            }
//                            restartControllerCounting()
//                        }
//                    } else {
//                        DispatchQueue.main.async {
//                            self.totalIncorrect += 1
////                            self.updateFeedback(newFeedback: self.controller?.peakDurationFeedback)
//                        }
//                        restartControllerCounting()
//                    }
//                }
//            }
//            quickPose.update(features: overlayFeatures)
//           
//           DispatchQueue.main.async {
//               self.overlayImage = outputImage
//           }
//        }
//    }
//}
//
//
//
//
//
//
//// MARK: middle range result checking
//
////        if !target.wentThroughMiddlePeakToLaunch && target.currentRomState == .launch {
////            if target.launchDirection == .increase {
////                if isInRange(target.currentAngle,
////                             between: target.peakResult.angleValue + target.peakResult.angleBlur,
////                             and: target.launchResult.angleValue - target.launchResult.angleBlur,
////                             direction: target.launchDirection) {
////                    target.wentThroughMiddlePeakToLaunch = true
////                }
////            } else {
////                if isInRange(target.currentAngle,
////                             between: target.peakResult.angleValue - target.peakResult.angleBlur,
////                             and: target.launchResult.angleValue + target.launchResult.angleBlur,
////                             direction: target.launchDirection) {
////                    target.wentThroughMiddlePeakToLaunch = true
////                }
////            }
////        }
////
////        if !target.wentThroughMiddleLaunchToPeak && target.currentRomState == .peak {
////            if target.peakDirection == .increase {
////                if isInRange(target.currentAngle,
////                             between: target.launchResult.angleValue + target.launchResult.angleBlur,
////                             and: target.peakResult.angleValue - target.peakResult.angleBlur,
////                             direction: target.peakDirection) {
////                    target.wentThroughMiddleLaunchToPeak = true
////                }
////            } else {
////                if isInRange(target.currentAngle,
////                             between: target.launchResult.angleValue - target.launchResult.angleBlur,
////                             and: target.peakResult.angleValue + target.peakResult.angleBlur,
////                             direction: target.peakDirection) {
////                    target.wentThroughMiddleLaunchToPeak = true
////                }
////            }
////        }
//        
//        
////        if !target.wentThroughMiddlePeakToLaunch
////            && isROMSatisfied(current: target.currentAngle,
////                           angleValue: Double(target.peakToLaunchMiddleRangeResult),
////                           angleBlur: Double(target.middleRangeResultBlur))
////            && target.currentRomState == .launch {
////            target.wentThroughMiddlePeakToLaunch = true
////        }
////        if !target.wentThroughMiddleLaunchToPeak
////            && isROMSatisfied(current: target.currentAngle,
////                           angleValue: Double(target.launchToPeakMiddleRangeResult),
////                           angleBlur: Double(target.middleRangeResultBlur))
////            && target.currentRomState == .peak {
////            target.wentThroughMiddleLaunchToPeak = true
////        }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
////import SwiftUI
////import AVFoundation
////import QuickPoseCore
////import QuickPoseSwiftUI
////import AVFoundation
////import AudioToolbox
////import Foundation
////
////// MARK: EXERCIES ADJUSTMENT
////class FitnessExercisePerformance: PoseDetection {
////    
////    override init(targetCount: Int? = nil,
////                  targetTime: Int? = nil,
////                  feedback: Bool = false,
////                  controller: FitnessExerciseAdjustment? = nil,
////                  modelConfig: QuickPose.ModelConfig = QuickPose.ModelConfig(
////                    detailedFaceTracking: false,
////                    detailedHandTracking: false)
////    ) {
////        super.init(targetCount: targetCount,
////                   targetTime: targetTime,
////                   feedback: feedback,
////                   controller: controller,
////                   modelConfig: modelConfig)
////    }
////    
////    func perform() {
////        var features: [QuickPose.Feature] = []
////        if let guardGroups = controller!.guardGroups {
////            features = guardGroups.flatMap{[$0.group.feature.restyled($0.group.acceptanceStyle)]} as! [QuickPose.Feature]
////        }
////        features += controller!.limbGroups.flatMap{[$0.left.feature.restyled($0.left.correctionStyle), $0.right.feature.restyled($0.right.correctionStyle)]}
////        var overlayFeatures: [QuickPose.Feature] = features
////        
////        self.quickPose.start(features: features, modelConfig: modelConfig) {[weak self] status, outputImage, result, feedback, _ in
////            self?.overlayImage = outputImage
////
////            if let guardGroups = self!.controller!.guardGroups {
////                guard guardGroups.allSatisfy({
////                    if let angle = result[$0.group.feature]?.value {
////                        if angle < $0.group.guardResult.startAngleValue {
////                            self?.updateFeedback(newFeedback: $0.smallerThanLimitFeedback)
////                        }
////                        else if angle > $0.group.guardResult.endAngleValue {
////                            self?.updateFeedback(newFeedback: $0.greaterThanLimitFeedback)
////                        }
////                        return angle >= $0.group.guardResult.startAngleValue &&
////                               angle <= $0.group.guardResult.endAngleValue
////                    } else {
////                        return false
////                    }
////                }) else {
////                    return
////                }
////            }
////
////            for index in self!.controller!.limbGroups.indices {
////                var group = self?.controller!.limbGroups[index]
////                group!.left.currentAngle = result[(group?.left.feature)!]?.value ?? 0
////                group!.right.currentAngle = result[group!.right.feature]?.value ?? 0
////                
////                if abs((group?.left.currentAngle)! - (group?.right.currentAngle)!) <= group!.acceptedAngleValueDifference {
////                    if ((group?.beingIllegal) != nil) {
////                        group?.beingIllegal = false
////                    }
////                    self?.processMovementTarget(&group!.left, overlayFeatures: &overlayFeatures)
////                    self?.processMovementTarget(&group!.right, overlayFeatures: &overlayFeatures)
////                    
////                    if group?.left.totalCycle == group?.left.targetCycle && group?.right.totalCycle == group?.right.targetCycle
////                        && !(group?.left.beingIllegal)! && !(group?.right.beingIllegal)! {
////                        group?.isMutated = true
////                        self?.controller!.isMutated = true
////                        if self?.controller!.mutationDate == nil {
////                            self?.controller!.mutationDate = Date()
////                        }
////                        group?.left.totalCycle = 0
////                        group?.right.totalCycle = 0
////                    }
////                    if (group?.left.beingIllegal)! || ((group?.right.beingIllegal) != nil) {
////                        group?.left.totalCycle = 0
////                        group?.right.totalCycle = 0
////                        group?.left.beingIllegal = false
////                        group?.right.beingIllegal = false
////                    }
////                }
////                else {
////                    if !group!.beingIllegal {
////                        self?.updateIllegalFeature(target: group!.left, overlayFeatures: &overlayFeatures)
////                        self?.updateIllegalFeature(target: group!.right, overlayFeatures: &overlayFeatures)
////                        self?.updateFeedback(newFeedback: group!.angleValueDifferenceFeedback)
////                        group!.beingIllegal = true
////                        self.totalIncorrect += 1
////                    }
////                }
////                self?.controller!.limbGroups[index] = group!
////            }
////            
////            
////            if ((self?.controller!.isMutated) != nil) {
////                if let date = self?.controller!.mutationDate {
////                    let currentTime = Date()
////                    let timeDifference = currentTime.timeIntervalSince(date)
////                    if timeDifference <= (self?.controller!.endAcceptedPeakDuration)!  {
////                        if ((self?.isAllMutated(target: (self?.controller!.limbGroups)!)) != nil)  {
////                            if (self?.controller!.startAcceptedPeakDuration)! <= timeDifference {
////                                self?.totalCorrect += 1
////                            } else {
////                                self?.totalIncorrect += 1
////                            }
////                            self?.restartControllerCounting()
////                        } else {
////                            self?.totalIncorrect += 1
////                        }
////                    } else {
////                        self?.totalIncorrect += 1
////                        self?.updateFeedback(newFeedback: self?.controller?.peakDurationFeedback)
////                        self?.restartControllerCounting()
////                    }
////                }
////            }
////            self?.quickPose.update(features: overlayFeatures)
////        }
////    }
////    
////    
////    func restartControllerCounting() -> Void {
////        if controller != nil {
////            for index in controller!.limbGroups.indices {
////                controller!.limbGroups[index].isMutated = false
////            }
////            controller!.isMutated = false
////            controller!.mutationDate = nil
////        }
////    }
////    
////    
////    func isAllMutated(target: [LimbGroup]) -> Bool {
////        for group in target {
////            if !group.isMutated {return false}
////        }
////        return true
////    }
////    
////    
////    func updateIllegalFeature(target: MovementTarget, overlayFeatures: inout [QuickPose.Feature]) -> Void {
////        if let arrIndex = overlayFeatures.firstIndex(of: target.feature) {
////            overlayFeatures[arrIndex] = target.feature.restyled(target.illegalStyle)
////        }
////    }
////    
////    func updateCorrectionFeature(target: MovementTarget, overlayFeatures: inout [QuickPose.Feature]) -> Void {
////        if let arrIndex = overlayFeatures.firstIndex(of: target.feature) {
////            overlayFeatures[arrIndex] = target.feature.restyled(target.correctionStyle)
////        }
////    }
////    
////    func processMovementTarget(_ target: inout MovementTarget, overlayFeatures: inout [QuickPose.Feature]) {
////        
////        func resetFlags() -> Void {
////            target.wentThroughMiddleLaunchToPeak = false
////            target.wentThroughMiddlePeakToLaunch = false
////        }
////        
////        if !target.wentThroughMiddlePeakToLaunch &&
////            isROMSatisfied(current: target.currentAngle,
////                           angleValue: Double(target.peakToLaunchMiddleRangeResult),
////                           angleBlur: Double(target.middleRangeResultBlur)) {
////            target.wentThroughMiddlePeakToLaunch = true
////        }
////        if !target.wentThroughMiddleLaunchToPeak &&
////            isROMSatisfied(current: target.currentAngle,
////                           angleValue: Double(target.launchToPeakMiddleRangeResult),
////                           angleBlur: Double(target.middleRangeResultBlur)) {
////            target.wentThroughMiddleLaunchToPeak = true
////        }
////        
////        guard let index = overlayFeatures.firstIndex(of: target.feature) else { return }
////        
////
////        if isROMSatisfied(current: target.currentAngle,
////                         angleValue: target.launchResult.angleValue,
////                         angleBlur: target.launchResult.angleBlur) {
////            if target.currentRomState == .launch {
////                if target.wentThroughMiddlePeakToLaunch{
////                    playTing()
////                    target.currentRomState = .peak
////                    resetFlags()
////                    overlayFeatures[index] = target.feature.restyled(target.correctionStyle)
////                }
////            } else {
////                if target.wentThroughMiddleLaunchToPeak {
////                    target.beingIllegal = true
////                    resetFlags()
////                    overlayFeatures[index] = target.feature.restyled(target.illegalStyle)
////                    updateFeedback(newFeedback: target.greaterThanStartFeedback)
////                }
////            }
////        }
////        else if isROMSatisfied(current: target.currentAngle,
////                                 angleValue: target.peakResult.angleValue,
////                                 angleBlur: target.peakResult.angleBlur) {
////            if target.currentRomState == .peak {
////                if target.wentThroughMiddleLaunchToPeak {
////                    playTing2()
////                    target.currentRomState = .launch
////                    resetFlags()
////                    overlayFeatures[index] = target.feature.restyled(target.correctionStyle)
////                    
////                    if target.totalCycle >= target.targetCycle {target.totalCycle = target.targetCycle}
////                    else {target.totalCycle += 1}
////                }
////            } else {
////                if target.wentThroughMiddlePeakToLaunch {
////                    target.beingIllegal = true
////                    resetFlags()
////                    overlayFeatures[index] = target.feature.restyled(target.illegalStyle)
////                    updateFeedback(newFeedback: target.smallerThanEndFeedback)
////                }
////            }
////        }
////    }
////
////    
////    // testing
////    func updateHistoryAndDetectDirection(feature: QuickPose.Feature, group: inout MovementTarget) -> ROMDirection {
////        var history = group.angleHistories[feature] ?? []
////        history.append(group.currentAngle)
////        if history.count > group.historyLength {
////            history.removeFirst()
////        }
////        group.angleHistories[feature] = history
////
////        // Dự đoán hướng bằng cách so sánh trung bình nửa đầu với nửa sau
////        guard history.count >= 2 else {
////            return .unchanged
////        }
////
////        let mid = history.count / 2
////        let startAvg = history.prefix(mid).reduce(0, +) / Double(mid)
////        let endAvg = history.suffix(from: mid).reduce(0, +) / Double(history.count - mid)
////
////        if endAvg - startAvg > 1 {
////            return .increase
////        } else if startAvg - endAvg > 1 {
////            return .decrease
////        } else {
////            return .unchanged
////        }
////    }
////
////    func isROMSatisfied(current: Double, angleValue: Double, angleBlur: Double) -> Bool {
////        return angleValue - angleBlur <= current && current <= angleValue + angleBlur
////    }
////}
