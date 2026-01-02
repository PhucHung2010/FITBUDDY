//
//  ExerciseCategory.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 18/06/2025.
//

import Foundation
import SwiftUI
import CoreData
import QuickPoseCore
import QuickPoseSwiftUI


enum MuscleGroup: String, CaseIterable, Identifiable {
    case chest
    case back
    case shoulders
    case biceps
    case triceps
    case forearms
    case abs
    case glutes
    case quads
    case hamstrings
    case calves
    case fullBody
    case cardio
    case stretching
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .chest: return "Chest"
        case .back: return "Back"
        case .shoulders: return "Shoulders"
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .forearms: return "Forearms"
        case .abs: return "Abs"
        case .glutes: return "Glutes"
        case .quads: return "Quads"
        case .hamstrings: return "Hamstrings"
        case .calves: return "Calves"
        case .fullBody: return "Full Body"
        case .cardio: return "Cardio"
        case .stretching: return "Stretching"
        }
    }
}


struct DescriptionAndInstructionString {
    let description: String
    let instruction: [String]
}
struct ImageAndVideoString {
    let image: [(String, String)]
    let video: [String]
}

struct CompletedExerciseInstruction {
    let dumbbellCurl = DescriptionAndInstructionString(
        description: "The dumbbell curl is a classic biceps exercise that isolates and strengthens the front of your arms. It is excellent for building arm size and improving grip strength. To perform it, hold a dumbbell in each hand with your palms facing forward and your arms fully extended. Bend your elbows to lift the dumbbells toward your shoulders, keeping your upper arms stationary. Slowly lower the weights back to the starting position. Focus on controlled movement rather than swinging the weights. Regular practice helps build stronger and more defined biceps.",
        instruction: [
            "Stand upright with a dumbbell in each hand, arms fully extended, palms facing forward.",
            "Keep your elbows close to your torso and avoid swinging.",
            "Slowly curl the dumbbells upward by bending your elbows.",
            "Pause briefly when the dumbbells reach shoulder level.",
            "Lower the dumbbells back to the starting position with control.",
            "Repeat for the desired number of repetitions."
        ]
    )
    
    let squat = DescriptionAndInstructionString(
        description: "The squat is a powerful lower-body exercise that targets the quadriceps, hamstrings, glutes, and core. It mimics everyday movements like sitting and standing, making it both functional and effective. To perform a squat, stand with feet shoulder-width apart, engage your core, and lower your hips as if sitting back into a chair. Keep your chest up, knees aligned with your toes, and return to standing by pressing through your heels. Squats can be done with body weight or added resistance like dumbbells or barbells. Regular squatting builds strength, improves mobility, and enhances balance and stability.",
        instruction: [
            "Stand tall with your feet shoulder-width apart and toes slightly pointed outward.",
            "Keep your chest lifted and engage your core.",
            "Bend your knees and push your hips back as if sitting into a chair.",
            "Lower yourself until your thighs are parallel to the floor or as far as comfortable.",
            "Ensure your knees stay aligned with your toes and do not cave inward.",
            "Press through your heels to return to standing position."
        ]
    )
    
    let lateralRaise = DescriptionAndInstructionString(
        description: "The lateral raise is a shoulder isolation exercise that targets the lateral deltoids, helping to build width and improve shoulder definition. It is excellent for creating balanced upper-body strength and aesthetics. To perform it, hold a dumbbell in each hand by your sides with palms facing inward. Keeping a slight bend in your elbows, raise your arms out to the sides until they are parallel to the floor. Lower them slowly back to your sides. Avoid swinging or using momentum to lift the weights.",
        instruction: [
            "Stand upright with a dumbbell in each hand, arms resting at your sides, palms facing inward.",
            "Maintain a slight bend in your elbows throughout the movement.",
            "Lift your arms out to the sides until they reach shoulder height.",
            "Pause briefly at the top while keeping your shoulders relaxed.",
            "Lower the dumbbells back down slowly and with control.",
            "Repeat for the desired number of repetitions."
        ]
    )
    
    let dumbbellPress = DescriptionAndInstructionString(
        description: "The dumbbell press, also known as the overhead press, primarily strengthens the shoulders and triceps while also engaging the upper chest and core. It improves overhead strength and posture. To perform it, hold a dumbbell in each hand at shoulder height with palms facing forward. Press the dumbbells upward until your arms are fully extended overhead. Slowly lower the weights back down to shoulder level. Keep your core engaged and avoid arching your lower back.",
        instruction: [
            "Stand tall or sit on a bench with a dumbbell in each hand at shoulder height, palms facing forward.",
            "Engage your core and keep your back straight.",
            "Press the dumbbells upward until your arms are fully extended overhead.",
            "Pause briefly at the top with your arms straight.",
            "Lower the dumbbells back down to shoulder height with control.",
            "Repeat for the desired number of repetitions."
        ]
    )
    
    let jumpingJack = DescriptionAndInstructionString(
        description: "Jumping jacks are a simple but effective full-body cardio exercise that increases heart rate, warms up muscles, and improves coordination. They are excellent for boosting endurance, burning calories, and preparing the body for more intense workouts. The movement involves jumping into a wide stance while raising your arms overhead, then returning to the starting position in a rhythmic manner.",
        instruction: [
            "Stand upright with your feet together and arms at your sides.",
            "Jump up, spreading your legs shoulder-width apart while raising your arms overhead.",
            "Jump again to return to the starting position.",
            "Maintain a steady pace and controlled breathing.",
            "Repeat for the desired duration or number of repetitions."
        ]
    )
    
    let walkingLunge = DescriptionAndInstructionString(
        description: "The walking lunge is a dynamic lower-body exercise that strengthens the quadriceps, hamstrings, and glutes while also improving balance and coordination. Unlike stationary lunges, this variation involves stepping forward into consecutive lunges, making it more functional and challenging. It also engages the core for stability and control.",
        instruction: [
            "Stand upright with feet hip-width apart and hands at your sides or on your hips.",
            "Step forward with your right leg and lower your hips until both knees are bent at about 90 degrees.",
            "Push through your right heel to bring your left leg forward into the next lunge.",
            "Continue alternating legs as you move forward.",
            "Keep your torso upright and avoid letting your front knee go past your toes.",
            "Repeat for the desired number of steps or distance."
        ]
    )
}



struct CompletedExerciseImageVideoInstruction {
    let dumbbellCurl = ImageAndVideoString(image: [("curl1", "curl2"), ("curl3", "curl4")],
                                               video: ["dumbbellCurl"])
    let frontRaise = ImageAndVideoString(image: [("FrontRaise_1", "FrontRaise_2"), ("FrontRaise_3", "FrontRaise_4")],
                                         video: ["frontRaise"])
    let jumpingJack = ImageAndVideoString(image: [("JumpingJack_1", "JumpingJack_2"), ("JumpingJack_3", "JumpingJack_4")],
                                          video: ["jumpingJack"])
    let pushUp = ImageAndVideoString(image: [("PushUp_1", "PushUp_2"), ("PushUp_3", "PushUp_4")],
                                     video: ["pushUp"])
    let sitUp = ImageAndVideoString(image: [("SitUp_1", "SitUp_2"), ("SitUp_3", "SitUp_4")],
                                    video: ["sitUps"])
    let swing = ImageAndVideoString(image: [("Swing_1", "Swing_2"), ("Swing_3", "Swing_4")],
                                    video: ["swing"])
    
    let squat = ImageAndVideoString(image: [("demoImage1", "demoImage2"), ("demoImage3", "demoImage4")],
                                    video: ["squat"])
    
    
}

struct CompletedExerciseAdjustment {
    let dumbbellCurl = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "Elbow",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .arm, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.elbow(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 160, angleBlur: 10),
                                           peakResult: .init(angleValue: 20, angleBlur: 10),
                                           launchDirection: .increase,
                                           peakDirection: .decrease,
                                           greaterThanStartFeedback: Feedback.show(.move, LR: .left, .arm, .down),
                                           smallerThanEndFeedback: Feedback.show(.move, LR: .left, .arm, .up)),
                      right: MovementTarget(feature: .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 160, angleBlur: 10),
                                            peakResult: .init(angleValue: 20, angleBlur: 10),
                                            launchDirection: .increase,
                                            peakDirection: .decrease,
                                            greaterThanStartFeedback: Feedback.show(.move, LR: .right, .arm, .down),
                                            smallerThanEndFeedback: Feedback.show(.move, LR: .right, .arm, .up)))
        ],
        guardGroups: [
            GuardGroup(name: "leftShoulder",
                       group: GuardTarget(feature: .rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false)),
                                          guardResult: .init(startAngleValue: 0, endAngleValue: 50)),
                       greaterThanLimitFeedback: Feedback.show(.lower, LR: .left, .arm),
                       smallerThanLimitFeedback: Feedback.show(.lower, LR: .left, .arm)),
            GuardGroup(name: "leftShoulder",
                       group: GuardTarget(feature: .rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true)),
                                          guardResult: .init(startAngleValue: 0, endAngleValue: 50)),
                       greaterThanLimitFeedback: Feedback.show(.lower, LR: .right, .arm),
                       smallerThanLimitFeedback: Feedback.show(.lower, LR: .right, .arm))
        ]
    )

    
    
    
    let squat = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "Knee",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .knee, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.knee(side: .left, clockwiseDirection: true)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 180, angleBlur: 15),
                                           peakResult: .init(angleValue: 90, angleBlur: 20),
                                           launchDirection: .increase,
                                           peakDirection: .decrease,
                                           greaterThanStartFeedback: Feedback.show(.straighten, LR: .left, .leg),
                                           smallerThanEndFeedback: Feedback.show(.lower, .knee, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.knee(side: .right, clockwiseDirection: false)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 180, angleBlur: 15),
                                            peakResult: .init(angleValue: 90, angleBlur: 20),
                                            launchDirection: .increase,
                                            peakDirection: .decrease,
                                            greaterThanStartFeedback: Feedback.show(.straighten, LR: .right, .leg),
                                            smallerThanEndFeedback: Feedback.show(.lower, .knee, .down)))
        ],
        guardGroups: nil
    )
    
    
    let lateralRaise = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "ShoulderAbduction",
                      acceptedAngleValueDifference: 20,
                      angleValueDifferenceFeedback: Feedback.show(.raise, .arm, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 20, angleBlur: 10),
                                           peakResult: .init(angleValue: 90, angleBlur: 10),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.lower, LR: .left, .arm, .down),
                                           smallerThanEndFeedback: Feedback.show(.raise, LR: .left, .arm, .up)),
                      right: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 20, angleBlur: 10),
                                            peakResult: .init(angleValue: 90, angleBlur: 10),
                                            launchDirection: .decrease,
                                            peakDirection: .increase,
                                            greaterThanStartFeedback: Feedback.show(.lower, LR: .right, .arm, .down),
                                            smallerThanEndFeedback: Feedback.show(.raise, LR: .right, .arm, .up)))
        ],
        guardGroups: [
            GuardGroup(name: "Mid shoulder",
                       group: GuardTarget(feature: .measureAngleBody(origin: .nose,
                                                                     p1: .wrist(side: .left),
                                                                     p2: .wrist(side: .right),
                                                                     clockwiseDirection: false),
                                          guardResult: .init(startAngleValue: 40, endAngleValue: 200)),
                       greaterThanLimitFeedback: Feedback.show(.move, .arm, .apart),
                       smallerThanLimitFeedback: Feedback.show(.move, .arm, .apart))
        ]
    )

    let dumbbellPress = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "Shoulder",
                      acceptedAngleValueDifference: 20,
                      angleValueDifferenceFeedback: Feedback.show(.raise, .arm, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 40, angleBlur: 10),
                                           peakResult: .init(angleValue: 120, angleBlur: 10),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.lower, LR: .left, .arm, .down),
                                           smallerThanEndFeedback: Feedback.show(.raise, LR: .left, .arm, .up)),
                      right: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 40, angleBlur: 10),
                                            peakResult: .init(angleValue: 120, angleBlur: 10),
                                            launchDirection: .decrease,
                                            peakDirection: .increase,
                                            greaterThanStartFeedback: Feedback.show(.lower, LR: .right, .arm, .down),
                                            smallerThanEndFeedback: Feedback.show(.raise, LR: .right, .arm, .up))),
            LimbGroup(name: "Elbow",
                      acceptedAngleValueDifference: 20,
                      angleValueDifferenceFeedback: Feedback.show(.raise, .arm, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.elbow(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 20, angleBlur: 10),
                                           peakResult: .init(angleValue: 100, angleBlur: 10),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.lower, LR: .left, .arm, .down),
                                           smallerThanEndFeedback: Feedback.show(.raise, LR: .left, .arm, .up)),
                      right: MovementTarget(feature: .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 20, angleBlur: 10),
                                            peakResult: .init(angleValue: 100, angleBlur: 10),
                                            launchDirection: .decrease,
                                            peakDirection: .increase,
                                            greaterThanStartFeedback: Feedback.show(.lower, LR: .right, .arm, .down),
                                            smallerThanEndFeedback: Feedback.show(.raise, LR: .right, .arm, .up)))
        ],
        guardGroups: nil
    )
    
    let jumpingJack = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "shoulder",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .arm, .apart),
                      left: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false)),
                                           launchResult: .init(angleValue: 20, angleBlur: 20),
                                           peakResult: .init(angleValue: 130, angleBlur: 20),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.move, LR: .left, .arm, .up),
                                           smallerThanEndFeedback: Feedback.show(.move, LR: .left, .arm, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true)),
                                            launchResult: .init(angleValue: 20, angleBlur: 20),
                                            peakResult: .init(angleValue: 130, angleBlur: 20),
                                            launchDirection: .decrease,
                                            peakDirection: .increase,
                                            greaterThanStartFeedback: Feedback.show(.move, LR: .left, .arm, .up),
                                            smallerThanEndFeedback: Feedback.show(.move, LR: .left, .arm, .down))),
            LimbGroup(name: "hip",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .arm, .apart),
                      left: MovementTarget(feature: .rangeOfMotion(.hip(side: .left, clockwiseDirection: false)),
                                           launchResult: .init(angleValue: 175, angleBlur: 5),
                                           peakResult: .init(angleValue: 155, angleBlur: 5),
                                           launchDirection: .increase,
                                           peakDirection: .decrease,
                                           greaterThanStartFeedback: Feedback.show(.move, LR: .left, .leg, .up),
                                           smallerThanEndFeedback: Feedback.show(.move, LR: .left, .leg, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.hip(side: .right, clockwiseDirection: true)),
                                            launchResult: .init(angleValue: 175, angleBlur: 5),
                                            peakResult: .init(angleValue: 155, angleBlur: 5),
                                            launchDirection: .increase,
                                            peakDirection: .decrease,
                                            greaterThanStartFeedback: Feedback.show(.move, LR: .right, .leg, .up),
                                            smallerThanEndFeedback: Feedback.show(.move, LR: .right, .leg, .down)))
        ],
        guardGroups: nil,
        startAcceptedPeakDuration: 0,
        endAcceptedPeakDuration: 0.5,
        peakDurationFeedback: "Move body more stable"
        
    )
}



struct TargetExerciseParameter: Codable {
    var targetCount: Int?
    var targetTime: Int?
}


struct Category: Equatable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID = UUID()
    let name: String
    let muscleGroup: MuscleGroup
    let description: String
    let instruction: [String]
    let images: [(String, String)]
    let videos: [String]
    let detailedFaceTraking: Bool
    let detailedHandTraking: Bool
    let exerciseAdjustment: FitnessExerciseAdjustment
    
    init(name: String,
         muscleGroup: MuscleGroup,
         description: String,
         instruction: [String],
         images: [(String, String)],
         videos: [String],
         detailedFaceTraking: Bool = false,
         detailedHandTraking: Bool = false,
         exerciseAdjustment: FitnessExerciseAdjustment) {
        self.name = name
        self.muscleGroup = muscleGroup
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
        Category(
            name: "Squat",
            muscleGroup: .quads,
            description: CompletedExerciseInstruction().squat.description,
            instruction: CompletedExerciseInstruction().squat.instruction,
            images: CompletedExerciseImageVideoInstruction().squat.image, // giữ nguyên
            videos: CompletedExerciseImageVideoInstruction().squat.video,
            exerciseAdjustment: CompletedExerciseAdjustment().squat
        ),
        
        Category(
            name: "Dumbbell Curl",
            muscleGroup: .biceps,
            description: CompletedExerciseInstruction().dumbbellCurl.description,
            instruction: CompletedExerciseInstruction().dumbbellCurl.instruction,
            images: CompletedExerciseImageVideoInstruction().dumbbellCurl.image,
            videos: CompletedExerciseImageVideoInstruction().dumbbellCurl.video,
            exerciseAdjustment: CompletedExerciseAdjustment().dumbbellCurl
        ),
        
        Category(
            name: "Lateral Raise",
            muscleGroup: .shoulders,
            description: CompletedExerciseInstruction().lateralRaise.description,
            instruction: CompletedExerciseInstruction().lateralRaise.instruction,
            images: CompletedExerciseImageVideoInstruction().swing.image,
            videos: CompletedExerciseImageVideoInstruction().swing.video,
            exerciseAdjustment: CompletedExerciseAdjustment().lateralRaise
        ),
        
        Category(
            name: "Dumbbell Press",
            muscleGroup: .shoulders,
            description: CompletedExerciseInstruction().dumbbellPress.description,
            instruction: CompletedExerciseInstruction().dumbbellPress.instruction,
            images: CompletedExerciseImageVideoInstruction().sitUp.image,
            videos: CompletedExerciseImageVideoInstruction().sitUp.video,
            exerciseAdjustment: CompletedExerciseAdjustment().dumbbellPress
        ),
        
        Category(
            name: "Jumping Jack",
            muscleGroup: .cardio,
            description: CompletedExerciseInstruction().jumpingJack.description,
            instruction: CompletedExerciseInstruction().jumpingJack.instruction,
            images: CompletedExerciseImageVideoInstruction().jumpingJack.image,
            videos: CompletedExerciseImageVideoInstruction().jumpingJack.video,
            exerciseAdjustment: CompletedExerciseAdjustment().jumpingJack
        ),
        
        Category(
            name: "Walking Lunge",
            muscleGroup: .quads,
            description: CompletedExerciseInstruction().walkingLunge.description,
            instruction: CompletedExerciseInstruction().walkingLunge.instruction,
            images: CompletedExerciseImageVideoInstruction().jumpingJack.image,
            videos: CompletedExerciseImageVideoInstruction().jumpingJack.video,
            exerciseAdjustment: CompletedExerciseAdjustment().dumbbellCurl
        )
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
    
    
    func loadCategory(named name: String) -> Category? {
        if let matchedCategory = categories.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return matchedCategory
        }
        return nil
    }
    
}

