//
//  ExerciseCategory.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 18/06/2025.
//

import Foundation




struct CompletedExerciseAdjustment {
    let dumbbellCurl = FitnessExerciseAdjustment(
        limbGroups: [
            LimbGroup(name: "ARM",
                      acceptedAngleValueDifference: 50,
                      left: MovementTarget(feature: .rangeOfMotion(.elbow(side: .left, clockwiseDirection: false)),
                                           correctionStyle: nil,
                                           launchResult: .init(angleValue: 150, angleBlur: 20),
                                           peakResult: .init(angleValue: 30, angleBlur: 20),
                                           middleRangeResultBlur: 20,
                                           launchDirection: .increase,
                                           peakDirection: .decrease),
                      right: MovementTarget(feature: .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true)),
                                            correctionStyle: nil,
                                            launchResult: .init(angleValue: 150, angleBlur: 20),
                                            peakResult: .init(angleValue: 30, angleBlur: 20),
                                            middleRangeResultBlur: 20,
                                            launchDirection: .increase,
                                            peakDirection: .decrease))
        ],
        guardGroups: nil
    )
}




struct Category {
    let id: UUID = UUID()
    let name: String
    let description: String
    let instruction: [String] = [
        "Đứng thẳng, hai chân rộng bằng vai, mũi chân hơi hướng ra ngoài.",
        "Giữ lưng thẳng, ngực nâng cao và siết cơ bụng.",
        "Từ từ gập gối và đẩy hông ra sau như ngồi xuống ghế.",
        "Hạ người đến khi đùi song song mặt đất hoặc mức bạn thấy thoải mái.",
        "Giữ đầu gối thẳng hàng với mũi chân, không vượt quá.",
        "Dừng lại ngắn ở đáy, rồi đẩy gót chân để đứng dậy."
    ]
    let images: [(String, String)]
    let videos: [String]
    let detailedFaceTraking: Bool
    let detailedHandTraking: Bool
    var exerciseAdjustment: FitnessExerciseAdjustment
    
    init(name: String,
         description: String,
         images: [(String, String)],
         videos: [String],
         detailedFaceTraking: Bool = false,
         detailedHandTraking: Bool = false,
         exerciseAdjustment: FitnessExerciseAdjustment) {
        self.name = name
        self.description = description
        self.images = images
        self.videos = videos
        self.detailedFaceTraking = detailedFaceTraking
        self.detailedHandTraking = detailedHandTraking
        self.exerciseAdjustment = exerciseAdjustment
    }
}


struct ExerciseCategory {
    let categories: [Category] = [
        Category(name: "Squat",
                 description: "The squat is a powerful lower-body exercise that targets the quadriceps, hamstrings, glutes, and core. It mimics everyday movements like sitting and standing, making it both functional and effective. To perform a squat, stand with feet shoulder-width apart, engage your core, and lower your hips as if sitting back into a chair. Keep your chest up, knees aligned with your toes, and return to standing by pressing through your heels. Squats can be done with body weight or added resistance like dumbbells or barbells. Regular squatting builds strength, improves mobility, and enhances balance and stability.",
                 images: [("FirstIMG", "SecondIMG"), ("SecondIMG", "FirstIMG")],
                 videos: ["TestingVideo"],
                 exerciseAdjustment: CompletedExerciseAdjustment().dumbbellCurl),
        
        Category(name: "Jumping Jack",
                 description: "The squat is a powerful lower-body exercise that targets the quadriceps, hamstrings, glutes, and core. It mimics everyday movements like sitting and standing, making it both functional and effective. To perform a squat, stand with feet shoulder-width apart, engage your core, and lower your hips as if sitting back into a chair. Keep your chest up, knees aligned with your toes, and return to standing by pressing through your heels. Squats can be done with body weight or added resistance like dumbbells or barbells. Regular squatting builds strength, improves mobility, and enhances balance and stability.",
                 images: [("FirstIMG", "SecondIMG"), ("SecondIMG", "FirstIMG")],
                 videos: ["TestingVideo"],
                 exerciseAdjustment: CompletedExerciseAdjustment().dumbbellCurl),
        
        Category(name: "walking lunge",
                 description: "The squat is a powerful lower-body exercise that targets the quadriceps, hamstrings, glutes, and core. It mimics everyday movements like sitting and standing, making it both functional and effective. To perform a squat, stand with feet shoulder-width apart, engage your core, and lower your hips as if sitting back into a chair. Keep your chest up, knees aligned with your toes, and return to standing by pressing through your heels. Squats can be done with body weight or added resistance like dumbbells or barbells. Regular squatting builds strength, improves mobility, and enhances balance and stability.",
                 images: [("FirstIMG", "SecondIMG"), ("SecondIMG", "FirstIMG")],
                 videos: ["TestingVideo"],
                 exerciseAdjustment: CompletedExerciseAdjustment().dumbbellCurl),
        
        Category(name: "lateral raise",
                 description: "The squat is a powerful lower-body exercise that targets the quadriceps, hamstrings, glutes, and core. It mimics everyday movements like sitting and standing, making it both functional and effective. To perform a squat, stand with feet shoulder-width apart, engage your core, and lower your hips as if sitting back into a chair. Keep your chest up, knees aligned with your toes, and return to standing by pressing through your heels. Squats can be done with body weight or added resistance like dumbbells or barbells. Regular squatting builds strength, improves mobility, and enhances balance and stability.",
                 images: [("FirstIMG", "SecondIMG"), ("SecondIMG", "FirstIMG")],
                 videos: ["TestingVideo"],
                 exerciseAdjustment: CompletedExerciseAdjustment().dumbbellCurl),
        
        Category(name: "overhead dubbell press",
                 description: "The squat is a powerful lower-body exercise that targets the quadriceps, hamstrings, glutes, and core. It mimics everyday movements like sitting and standing, making it both functional and effective. To perform a squat, stand with feet shoulder-width apart, engage your core, and lower your hips as if sitting back into a chair. Keep your chest up, knees aligned with your toes, and return to standing by pressing through your heels. Squats can be done with body weight or added resistance like dumbbells or barbells. Regular squatting builds strength, improves mobility, and enhances balance and stability.",
                 images: [("FirstIMG", "SecondIMG"), ("SecondIMG", "FirstIMG")],
                 videos: ["TestingVideo"],
                 exerciseAdjustment: CompletedExerciseAdjustment().dumbbellCurl),
        
        Category(name: "push up",
                 description: "The squat is a powerful lower-body exercise that targets the quadriceps, hamstrings, glutes, and core. It mimics everyday movements like sitting and standing, making it both functional and effective. To perform a squat, stand with feet shoulder-width apart, engage your core, and lower your hips as if sitting back into a chair. Keep your chest up, knees aligned with your toes, and return to standing by pressing through your heels. Squats can be done with body weight or added resistance like dumbbells or barbells. Regular squatting builds strength, improves mobility, and enhances balance and stability.",
                 images: [("FirstIMG", "SecondIMG"), ("SecondIMG", "FirstIMG")],
                 videos: ["TestingVideo"],
                 exerciseAdjustment: CompletedExerciseAdjustment().dumbbellCurl),
        
        Category(name: "sit up",
                 description: "The squat is a powerful lower-body exercise that targets the quadriceps, hamstrings, glutes, and core. It mimics everyday movements like sitting and standing, making it both functional and effective. To perform a squat, stand with feet shoulder-width apart, engage your core, and lower your hips as if sitting back into a chair. Keep your chest up, knees aligned with your toes, and return to standing by pressing through your heels. Squats can be done with body weight or added resistance like dumbbells or barbells. Regular squatting builds strength, improves mobility, and enhances balance and stability.",
                 images: [("FirstIMG", "SecondIMG"), ("SecondIMG", "FirstIMG")],
                 videos: ["TestingVideo"],
                 exerciseAdjustment: CompletedExerciseAdjustment().dumbbellCurl),
    ]
}
