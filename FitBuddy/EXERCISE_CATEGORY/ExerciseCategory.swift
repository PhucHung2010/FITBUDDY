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
    
    let pushUp = DescriptionAndInstructionString(
        description: "The push-up is a classic bodyweight exercise that targets the chest, shoulders, and triceps, while also engaging the core and lower back for stability.",
        instruction: [
            "Start in a high plank position with your hands slightly wider than shoulder-width apart.",
            "Keep your body in a straight line from head to heels.",
            "Lower your body until your chest is just above the floor by bending your elbows.",
            "Push back up to the starting position.",
            "Keep your core tight and do not let your lower back sag."
        ]
    )
    
    let sitUp = DescriptionAndInstructionString(
        description: "Sit-ups are a fundamental abdominal exercise designed to strengthen and tone the core muscles.",
        instruction: [
            "Lie on your back with your knees bent and feet flat on the floor.",
            "Place your hands lightly behind your head or crossed over your chest.",
            "Engage your core and lift your upper body off the floor, bringing your chest toward your knees.",
            "Lower yourself back down slowly and under control.",
            "Avoid pulling on your neck with your hands."
        ]
    )
    
    let frontRaise = DescriptionAndInstructionString(
        description: "The front raise is a weight training exercise that primarily targets the anterior deltoid muscles of the shoulder.",
        instruction: [
            "Stand with your feet shoulder-width apart, holding a dumbbell in each hand in front of your thighs.",
            "Keep your arms straight with a slight bend in the elbows.",
            "Lift the weights straight up in front of you until they reach shoulder height.",
            "Pause for a moment at the top of the movement.",
            "Slowly lower the weights back to the starting position."
        ]
    )
    
    let swing = DescriptionAndInstructionString(
        description: "The kettlebell swing is a dynamic, explosive exercise that targets the posterior chain, including the glutes, hamstrings, and lower back.",
        instruction: [
            "Stand with your feet slightly wider than shoulder-width apart, holding a kettlebell or dumbbell with both hands.",
            "Hinge at your hips and bend your knees slightly to lower the weight between your legs.",
            "Thrust your hips forward explosively and swing the weight up to shoulder height.",
            "Let the weight swing back down between your legs naturally.",
            "Keep your core tight and your back straight throughout the movement."
        ]
    )
    
    let highKnees = DescriptionAndInstructionString(
        description: "High knees is a cardiovascular exercise that strengthens the core, calves, quads, and hamstrings while elevating your heart rate.",
        instruction: [
            "Stand with your feet hip-width apart and arms at your sides.",
            "Lift your right knee as high as you can toward your chest.",
            "Switch legs quickly, bringing your left knee to your chest as your right leg descends.",
            "Pump your arms to maintain momentum.",
            "Continue alternating legs continuously."
        ]
    )
    
    let deadlift = DescriptionAndInstructionString(
        description: "The deadlift is a weight training exercise in which a loaded barbell or bar is lifted off the ground to the level of the hips.",
        instruction: [
            "Stand with your mid-foot under the barbell.",
            "Bend over and grab the bar with a shoulder-width grip.",
            "Bend your knees until your shins touch the bar.",
            "Lift your chest up and straighten your lower back.",
            "Take a big breath, hold it, and stand up with the weight."
        ]
    )
    
    let pullUp = DescriptionAndInstructionString(
        description: "The pull-up is an upper-body compound pulling exercise that primarily targets the back muscles.",
        instruction: [
            "Grab the pull-up bar with your palms facing outward.",
            "Hang from the bar with your arms fully extended.",
            "Pull yourself up until your chin is above the bar.",
            "Lower yourself back down with control.",
            "Repeat the movement without swinging your body."
        ]
    )
    
    let tricepsExtension = DescriptionAndInstructionString(
        description: "The triceps extension is an isolation exercise that targets the triceps brachii muscle.",
        instruction: [
            "Hold a dumbbell with both hands overhead.",
            "Keep your elbows close to your head and pointing straight up.",
            "Lower the dumbbell behind your head by bending your elbows.",
            "Extend your arms back up to the starting position.",
            "Keep your core tight and avoid arching your lower back."
        ]
    )
    
    let hammerCurl = DescriptionAndInstructionString(
        description: "The hammer curl is a variation of the bicep curl that targets the brachialis and brachioradialis muscles.",
        instruction: [
            "Stand straight with a dumbbell in each hand, palms facing your torso.",
            "Keep your upper arms stationary.",
            "Curl the weights upward while keeping your palms facing inward.",
            "Pause briefly at the top of the movement.",
            "Slowly lower the dumbbells back to the starting position."
        ]
    )
    
    let gluteBridge = DescriptionAndInstructionString(
        description: "The glute bridge is a floor exercise that targets the glutes and hamstrings.",
        instruction: [
            "Lie on your back with your knees bent and feet flat on the floor.",
            "Keep your arms at your sides with your palms facing down.",
            "Squeeze your glutes and lift your hips off the floor until your body forms a straight line from your shoulders to your knees.",
            "Hold the top position for a second or two.",
            "Slowly lower your hips back down to the floor."
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
    
    let highKnees = ImageAndVideoString(image: [("HighKnees_1", "HighKnees_2"), ("HighKnees_3", "HighKnees_4")],
                                        video: ["highKnees"])
                                        
    let deadlift = ImageAndVideoString(image: [("deadlift_1", "deadlift_2"), ("deadlift_3", "deadlift_4")], video: ["deadlift"])
    let pullUp = ImageAndVideoString(image: [("pullUp_1", "pullUp_2"), ("pullUp_3", "pullUp_4")], video: ["pullUp"])
    let tricepsExtension = ImageAndVideoString(image: [("triceps_1", "triceps_2"), ("triceps_3", "triceps_4")], video: ["tricepsExtension"])
    let hammerCurl = ImageAndVideoString(image: [("hammer_1", "hammer_2"), ("hammer_3", "hammer_4")], video: ["hammerCurl"])
    let gluteBridge = ImageAndVideoString(image: [("gluteBridge_1", "gluteBridge_2"), ("gluteBridge_3", "gluteBridge_4")], video: ["gluteBridge"])
}

private var globalBlur: Double {
    let saved = UserDefaults.standard.double(forKey: "globalAngleBlur")
    return saved > 0.0 ? saved : 15.0
}

struct CompletedExerciseAdjustment {
    let dumbbellCurl = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "Elbow",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .arm, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.elbow(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 160, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 20, angleBlur: globalBlur),
                                           launchDirection: .increase,
                                           peakDirection: .decrease,
                                           greaterThanStartFeedback: Feedback.show(.move, LR: .left, .arm, .down),
                                           smallerThanEndFeedback: Feedback.show(.move, LR: .left, .arm, .up)),
                      right: MovementTarget(feature: .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 160, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 20, angleBlur: globalBlur),
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
                                           launchResult: .init(angleValue: 180, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 90, angleBlur: globalBlur),
                                           launchDirection: .increase,
                                           peakDirection: .decrease,
                                           greaterThanStartFeedback: Feedback.show(.straighten, LR: .left, .leg),
                                           smallerThanEndFeedback: Feedback.show(.lower, .knee, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.knee(side: .right, clockwiseDirection: false)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 180, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 90, angleBlur: globalBlur),
                                            launchDirection: .increase,
                                            peakDirection: .decrease,
                                            greaterThanStartFeedback: Feedback.show(.straighten, LR: .right, .leg),
                                            smallerThanEndFeedback: Feedback.show(.lower, .knee, .down)))
        ],
        guardGroups: []
    )
    
    
    let lateralRaise = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "ShoulderAbduction",
                      acceptedAngleValueDifference: 20,
                      angleValueDifferenceFeedback: Feedback.show(.raise, .arm, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 20, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 90, angleBlur: globalBlur),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.lower, LR: .left, .arm, .down),
                                           smallerThanEndFeedback: Feedback.show(.raise, LR: .left, .arm, .up)),
                      right: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 20, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 90, angleBlur: globalBlur),
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
                                           launchResult: .init(angleValue: 40, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 120, angleBlur: globalBlur),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.lower, LR: .left, .arm, .down),
                                           smallerThanEndFeedback: Feedback.show(.raise, LR: .left, .arm, .up)),
                      right: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 40, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 120, angleBlur: globalBlur),
                                            launchDirection: .decrease,
                                            peakDirection: .increase,
                                            greaterThanStartFeedback: Feedback.show(.lower, LR: .right, .arm, .down),
                                            smallerThanEndFeedback: Feedback.show(.raise, LR: .right, .arm, .up))),
            LimbGroup(name: "Elbow",
                      acceptedAngleValueDifference: 20,
                      angleValueDifferenceFeedback: Feedback.show(.raise, .arm, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.elbow(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 20, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 100, angleBlur: globalBlur),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.lower, LR: .left, .arm, .down),
                                           smallerThanEndFeedback: Feedback.show(.raise, LR: .left, .arm, .up)),
                      right: MovementTarget(feature: .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 20, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 100, angleBlur: globalBlur),
                                            launchDirection: .decrease,
                                            peakDirection: .increase,
                                            greaterThanStartFeedback: Feedback.show(.lower, LR: .right, .arm, .down),
                                            smallerThanEndFeedback: Feedback.show(.raise, LR: .right, .arm, .up)))
        ],
        guardGroups: []
    )
    
    let jumpingJack = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "shoulder",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .arm, .apart),
                      left: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false)),
                                           launchResult: .init(angleValue: 20, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 130, angleBlur: globalBlur),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.move, LR: .left, .arm, .up),
                                           smallerThanEndFeedback: Feedback.show(.move, LR: .left, .arm, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true)),
                                            launchResult: .init(angleValue: 20, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 130, angleBlur: globalBlur),
                                            launchDirection: .decrease,
                                            peakDirection: .increase,
                                            greaterThanStartFeedback: Feedback.show(.move, LR: .left, .arm, .up),
                                            smallerThanEndFeedback: Feedback.show(.move, LR: .left, .arm, .down))),
            LimbGroup(name: "hip",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .arm, .apart),
                      left: MovementTarget(feature: .rangeOfMotion(.hip(side: .left, clockwiseDirection: false)),
                                           launchResult: .init(angleValue: 175, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 155, angleBlur: globalBlur),
                                           launchDirection: .increase,
                                           peakDirection: .decrease,
                                           greaterThanStartFeedback: Feedback.show(.move, LR: .left, .leg, .up),
                                           smallerThanEndFeedback: Feedback.show(.move, LR: .left, .leg, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.hip(side: .right, clockwiseDirection: true)),
                                            launchResult: .init(angleValue: 175, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 155, angleBlur: globalBlur),
                                            launchDirection: .increase,
                                            peakDirection: .decrease,
                                            greaterThanStartFeedback: Feedback.show(.move, LR: .right, .leg, .up),
                                            smallerThanEndFeedback: Feedback.show(.move, LR: .right, .leg, .down)))
        ],
        guardGroups: [],
        startAcceptedPeakDuration: 0,
        endAcceptedPeakDuration: 0.5,
        peakDurationFeedback: "Move body more stable"
        
    )
    
    let frontRaise = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "ShoulderFlexion",
                      acceptedAngleValueDifference: 20,
                      angleValueDifferenceFeedback: Feedback.show(.raise, .arm, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .left, clockwiseDirection: true)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 20, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 90, angleBlur: globalBlur),
                                           launchDirection: .increase,
                                           peakDirection: .decrease,
                                           greaterThanStartFeedback: Feedback.show(.lower, LR: .left, .arm, .down),
                                           smallerThanEndFeedback: Feedback.show(.raise, LR: .left, .arm, .up)),
                      right: MovementTarget(feature: .rangeOfMotion(.shoulder(side: .right, clockwiseDirection: false)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 20, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 90, angleBlur: globalBlur),
                                            launchDirection: .increase,
                                            peakDirection: .decrease,
                                            greaterThanStartFeedback: Feedback.show(.lower, LR: .right, .arm, .down),
                                            smallerThanEndFeedback: Feedback.show(.raise, LR: .right, .arm, .up)))
        ],
        guardGroups: []
    )
    
    let pushUp = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "Elbow",
                      acceptedAngleValueDifference: 45,
                      angleValueDifferenceFeedback: Feedback.show(.move, .arm, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.elbow(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 160, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 90, angleBlur: globalBlur),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.raise, LR: .left, .arm, .up),
                                           smallerThanEndFeedback: Feedback.show(.lower, LR: .left, .arm, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 160, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 90, angleBlur: globalBlur),
                                            launchDirection: .decrease,
                                            peakDirection: .increase,
                                            greaterThanStartFeedback: Feedback.show(.raise, LR: .right, .arm, .up),
                                            smallerThanEndFeedback: Feedback.show(.lower, LR: .right, .arm, .down)))
        ],
        guardGroups: []
    )
    
    let sitUp = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "Hip",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .leg, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.hip(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 150, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 60, angleBlur: globalBlur),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.move, LR: .left, .leg, .down),
                                           smallerThanEndFeedback: Feedback.show(.raise, LR: .left, .leg, .up)),
                      right: MovementTarget(feature: .rangeOfMotion(.hip(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 150, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 60, angleBlur: globalBlur),
                                            launchDirection: .decrease,
                                            peakDirection: .increase,
                                            greaterThanStartFeedback: Feedback.show(.move, LR: .right, .leg, .down),
                                            smallerThanEndFeedback: Feedback.show(.raise, LR: .right, .leg, .up)))
        ],
        guardGroups: []
    )
    
    let swing = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "HipSwing",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .leg, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.hip(side: .left, clockwiseDirection: true)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 110, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 170, angleBlur: globalBlur),
                                           launchDirection: .increase,
                                           peakDirection: .decrease,
                                           greaterThanStartFeedback: Feedback.show(.lower, LR: .left, .leg, .up),
                                           smallerThanEndFeedback: Feedback.show(.move, LR: .left, .leg, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.hip(side: .right, clockwiseDirection: false)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 110, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 170, angleBlur: globalBlur),
                                            launchDirection: .increase,
                                            peakDirection: .decrease,
                                            greaterThanStartFeedback: Feedback.show(.lower, LR: .right, .leg, .up),
                                            smallerThanEndFeedback: Feedback.show(.move, LR: .right, .leg, .down)))
        ],
        guardGroups: []
    )
    
    let highKnees = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "LegLift",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .leg, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.hip(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 170, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 90, angleBlur: globalBlur),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.lower, LR: .left, .leg, .down),
                                           smallerThanEndFeedback: Feedback.show(.raise, LR: .left, .leg, .up)),
                      right: MovementTarget(feature: .rangeOfMotion(.hip(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 170, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 90, angleBlur: globalBlur),
                                            launchDirection: .decrease,
                                            peakDirection: .increase,
                                            greaterThanStartFeedback: Feedback.show(.lower, LR: .right, .leg, .down),
                                            smallerThanEndFeedback: Feedback.show(.raise, LR: .right, .leg, .up)))
        ],
        guardGroups: []
    )
    
    let deadlift = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "Hip",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .leg, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.hip(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 70, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 170, angleBlur: globalBlur),
                                           launchDirection: .increase,
                                           peakDirection: .decrease,
                                           greaterThanStartFeedback: Feedback.show(.raise, LR: .left, .leg, .up),
                                           smallerThanEndFeedback: Feedback.show(.lower, LR: .left, .leg, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.hip(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 70, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 170, angleBlur: globalBlur),
                                            launchDirection: .increase,
                                            peakDirection: .decrease,
                                            greaterThanStartFeedback: Feedback.show(.raise, LR: .right, .leg, .up),
                                            smallerThanEndFeedback: Feedback.show(.lower, LR: .right, .leg, .down)))
        ],
        guardGroups: []
    )
    
    let pullUp = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "Elbow",
                      acceptedAngleValueDifference: 45,
                      angleValueDifferenceFeedback: Feedback.show(.move, .arm, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.elbow(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 160, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 45, angleBlur: globalBlur),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.raise, LR: .left, .arm, .up),
                                           smallerThanEndFeedback: Feedback.show(.lower, LR: .left, .arm, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 160, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 45, angleBlur: globalBlur),
                                            launchDirection: .decrease,
                                            peakDirection: .increase,
                                            greaterThanStartFeedback: Feedback.show(.raise, LR: .right, .arm, .up),
                                            smallerThanEndFeedback: Feedback.show(.lower, LR: .right, .arm, .down)))
        ],
        guardGroups: []
    )
    
    let tricepsExtension = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "Elbow",
                      acceptedAngleValueDifference: 45,
                      angleValueDifferenceFeedback: Feedback.show(.move, .arm, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.elbow(side: .left, clockwiseDirection: true)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 45, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 160, angleBlur: globalBlur),
                                           launchDirection: .increase,
                                           peakDirection: .decrease,
                                           greaterThanStartFeedback: Feedback.show(.raise, LR: .left, .arm, .up),
                                           smallerThanEndFeedback: Feedback.show(.lower, LR: .left, .arm, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.elbow(side: .right, clockwiseDirection: false)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 45, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 160, angleBlur: globalBlur),
                                            launchDirection: .increase,
                                            peakDirection: .decrease,
                                            greaterThanStartFeedback: Feedback.show(.raise, LR: .right, .arm, .up),
                                            smallerThanEndFeedback: Feedback.show(.lower, LR: .right, .arm, .down)))
        ],
        guardGroups: []
    )
    
    let hammerCurl = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "Elbow",
                      acceptedAngleValueDifference: 45,
                      angleValueDifferenceFeedback: Feedback.show(.move, .arm, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.elbow(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 160, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 45, angleBlur: globalBlur),
                                           launchDirection: .decrease,
                                           peakDirection: .increase,
                                           greaterThanStartFeedback: Feedback.show(.raise, LR: .left, .arm, .up),
                                           smallerThanEndFeedback: Feedback.show(.lower, LR: .left, .arm, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 160, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 45, angleBlur: globalBlur),
                                            launchDirection: .decrease,
                                            peakDirection: .increase,
                                            greaterThanStartFeedback: Feedback.show(.raise, LR: .right, .arm, .up),
                                            smallerThanEndFeedback: Feedback.show(.lower, LR: .right, .arm, .down)))
        ],
        guardGroups: []
    )
    
    let gluteBridge = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "Hip",
                      acceptedAngleValueDifference: 360,
                      angleValueDifferenceFeedback: Feedback.show(.move, .leg, .moreStable),
                      left: MovementTarget(feature: .rangeOfMotion(.hip(side: .left, clockwiseDirection: true)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 110, angleBlur: globalBlur),
                                           peakResult: .init(angleValue: 180, angleBlur: globalBlur),
                                           launchDirection: .increase,
                                           peakDirection: .decrease,
                                           greaterThanStartFeedback: Feedback.show(.raise, LR: .left, .leg, .up),
                                           smallerThanEndFeedback: Feedback.show(.lower, LR: .left, .leg, .down)),
                      right: MovementTarget(feature: .rangeOfMotion(.hip(side: .right, clockwiseDirection: false)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 110, angleBlur: globalBlur),
                                            peakResult: .init(angleValue: 180, angleBlur: globalBlur),
                                            launchDirection: .increase,
                                            peakDirection: .decrease,
                                            greaterThanStartFeedback: Feedback.show(.raise, LR: .right, .leg, .up),
                                            smallerThanEndFeedback: Feedback.show(.lower, LR: .right, .leg, .down)))
        ],
        guardGroups: []
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
            name: "Push-Up",
            muscleGroup: .chest,
            description: CompletedExerciseInstruction().pushUp.description,
            instruction: CompletedExerciseInstruction().pushUp.instruction,
            images: CompletedExerciseImageVideoInstruction().pushUp.image,
            videos: CompletedExerciseImageVideoInstruction().pushUp.video,
            exerciseAdjustment: CompletedExerciseAdjustment().pushUp
        ),
        
        Category(
            name: "Sit-Up",
            muscleGroup: .abs,
            description: CompletedExerciseInstruction().sitUp.description,
            instruction: CompletedExerciseInstruction().sitUp.instruction,
            images: CompletedExerciseImageVideoInstruction().sitUp.image,
            videos: CompletedExerciseImageVideoInstruction().sitUp.video,
            exerciseAdjustment: CompletedExerciseAdjustment().sitUp
        ),
        
        Category(
            name: "Front Raise",
            muscleGroup: .shoulders,
            description: CompletedExerciseInstruction().frontRaise.description,
            instruction: CompletedExerciseInstruction().frontRaise.instruction,
            images: CompletedExerciseImageVideoInstruction().frontRaise.image,
            videos: CompletedExerciseImageVideoInstruction().frontRaise.video,
            exerciseAdjustment: CompletedExerciseAdjustment().frontRaise
        ),
        
        Category(
            name: "Kettlebell Swing",
            muscleGroup: .fullBody,
            description: CompletedExerciseInstruction().swing.description,
            instruction: CompletedExerciseInstruction().swing.instruction,
            images: CompletedExerciseImageVideoInstruction().swing.image,
            videos: CompletedExerciseImageVideoInstruction().swing.video,
            exerciseAdjustment: CompletedExerciseAdjustment().swing
        ),
        
        Category(
            name: "High Knees",
            muscleGroup: .cardio,
            description: CompletedExerciseInstruction().highKnees.description,
            instruction: CompletedExerciseInstruction().highKnees.instruction,
            images: CompletedExerciseImageVideoInstruction().highKnees.image,
            videos: CompletedExerciseImageVideoInstruction().highKnees.video,
            exerciseAdjustment: CompletedExerciseAdjustment().highKnees
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

