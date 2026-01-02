//
//  ExerciseCategory.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 18/06/2025.
//

import Foundation
import SwiftUI
import CoreData

struct DescriptionAndInstructionString {
    let description: String
    let instruction: [String]
}
struct ImageAndVideoString {
    let image: [(String, String)]
    let video: [String]
}

struct CompletedExerciseInstruction {
    let dumbbellCurl = DescriptionAndInstructionString(description: "The squat is a powerful lower-body exercise that targets the quadriceps, hamstrings, glutes, and core. It mimics everyday movements like sitting and standing, making it both functional and effective. To perform a squat, stand with feet shoulder-width apart, engage your core, and lower your hips as if sitting back into a chair. Keep your chest up, knees aligned with your toes, and return to standing by pressing through your heels. Squats can be done with body weight or added resistance like dumbbells or barbells. Regular squatting builds strength, improves mobility, and enhances balance and stability.",
                                                       instruction: ["Đứng thẳng, hai chân rộng bằng vai, mũi chân hơi hướng ra ngoài.",
                                                                     "Giữ lưng thẳng, ngực nâng cao và siết cơ bụng.",
                                                                     "Từ từ gập gối và đẩy hông ra sau như ngồi xuống ghế.",
                                                                     "Hạ người đến khi đùi song song mặt đất hoặc mức bạn thấy thoải mái.",
                                                                     "Giữ đầu gối thẳng hàng với mũi chân, không vượt quá.",
                                                                     "Dừng lại ngắn ở đáy, rồi đẩy gót chân để đứng dậy."])
}

struct CompletedExerciseImageVideoInstruction {
    let dumbbellCurl = ImageAndVideoString(image: [("FirstIMG", "SecondIMG"), ("SecondIMG", "FirstIMG")],
                                           video: ["TestingVideo"])
}

struct CompletedExerciseAdjustment {
    let dumbbellCurl = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "ARM",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .arm, .apart),
                      left: MovementTarget(feature: .rangeOfMotion(.elbow(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 150, angleBlur: 20),
                                           peakResult: .init(angleValue: 30, angleBlur: 20),
                                           middleRangeResultBlur: 20,
                                           launchDirection: .increase,
                                           peakDirection: .decrease,
                                           greaterThanStartFeedback: Feedback.show(.move, LR: .left, .arm, .up),
                                           smallerThanEndFeedback: Feedback.show(.move, LR: .left, .arm, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 150, angleBlur: 20),
                                            peakResult: .init(angleValue: 30, angleBlur: 20),
                                            middleRangeResultBlur: 20,
                                            launchDirection: .increase,
                                            peakDirection: .decrease,
                                            greaterThanStartFeedback: Feedback.show(.move, LR: .right, .arm, .up),
                                            smallerThanEndFeedback: Feedback.show(.move, LR: .right, .arm, .down)))
        ],
        guardGroups: nil
    )
    
    let wristCurl = FitnessExerciseAdjustment(
        limbGroups: [LimbGroup(name: "wrist",
                               acceptedAngleValueDifference: 360,
                               angleValueDifferenceFeedback: Feedback.show(.move, .arm, .apart),
                               left: MovementTarget(feature: .measureAngleBody(origin: ., p1: <#T##QuickPose.Landmarks.Body#>, p2: <#T##QuickPose.Landmarks.Body?#>, clockwiseDirection: <#T##Bool#>, style: <#T##QuickPose.Style#>), right: <#T##MovementTarget#>)]
    )
}



struct TargetExerciseParameter: Codable {
    var targetCount: Int?
    var targetTime: Int?
}


struct Category {
    let id: UUID = UUID()
    let name: String
    let description: String
    let instruction: [String]
    let images: [(String, String)]
    let videos: [String]
    let detailedFaceTraking: Bool
    let detailedHandTraking: Bool
    let exerciseAdjustment: FitnessExerciseAdjustment
    
    init(name: String,
         description: String,
         instruction: [String],
         images: [(String, String)],
         videos: [String],
         detailedFaceTraking: Bool = false,
         detailedHandTraking: Bool = false,
         exerciseAdjustment: FitnessExerciseAdjustment) {
        self.name = name
        self.description = description
        self.instruction = instruction
        self.images = images
        self.videos = videos
        self.detailedFaceTraking = detailedFaceTraking
        self.detailedHandTraking = detailedHandTraking
        self.exerciseAdjustment = exerciseAdjustment
    }
}



struct FitnessExerciseCategory {
    let categories: [Category] = [
        Category(name: "Squat",
                 description: CompletedExerciseInstruction().dumbbellCurl.description,
                 instruction: CompletedExerciseInstruction().dumbbellCurl.instruction,
                 images: CompletedExerciseImageVideoInstruction().dumbbellCurl.image,
                 videos: CompletedExerciseImageVideoInstruction().dumbbellCurl.video,
                 exerciseAdjustment: CompletedExerciseAdjustment().dumbbellCurl),
        
        Category(name: "Jumping Jack",
                 description: CompletedExerciseInstruction().dumbbellCurl.description,
                 instruction: CompletedExerciseInstruction().dumbbellCurl.instruction,
                 images: CompletedExerciseImageVideoInstruction().dumbbellCurl.image,
                 videos: CompletedExerciseImageVideoInstruction().dumbbellCurl.video,
                 exerciseAdjustment: CompletedExerciseAdjustment().dumbbellCurl),
        
        Category(name: "walking lunge",
                 description: CompletedExerciseInstruction().dumbbellCurl.description,
                 instruction: CompletedExerciseInstruction().dumbbellCurl.instruction,
                 images: CompletedExerciseImageVideoInstruction().dumbbellCurl.image,
                 videos: CompletedExerciseImageVideoInstruction().dumbbellCurl.video,
                 exerciseAdjustment: CompletedExerciseAdjustment().dumbbellCurl), 
    ]
}


extension FitnessExerciseCategory {
    func imageForExerciseCard(named name: String) -> (String, String) {
        if let matchedCategory = categories.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return matchedCategory.images[0]
        } else {
            return ("ahihi", "ahihi") // hoặc có thể return ["placeholder.png"]
        }
    }
}

