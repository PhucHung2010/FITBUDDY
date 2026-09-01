//
//  Feedback.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/4/25.
//

import SwiftUI
import AVFoundation
import QuickPoseCore
import QuickPoseSwiftUI
import AVFoundation
import AudioToolbox
import Foundation

class TextSpeech: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = TextSpeech()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var lastSpeechEndTime: Date = Date.distantPast
    private let cooldownAfterSpeech: TimeInterval = 0.5 // 0.5s delay after each feedback finishes
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    
    /// Speaks the feedback text with 0.5s delay.
    /// If synthesizer is currently speaking or within 0.5s cooldown, skips overlapping feedback.
    func say(text: String, isExerciseActive: Bool = true) {
        guard isExerciseActive else { return }
        
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Skip if synthesizer is already speaking (prevents overlapping queue buildup)
        if synthesizer.isSpeaking {
            return
        }
        
        // Enforce 0.5s delay after previous feedback finishes
        let timeSinceLastSpeech = Date().timeIntervalSince(lastSpeechEndTime)
        if timeSinceLastSpeech < cooldownAfterSpeech {
            return
        }
        
        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.55
        utterance.postUtteranceDelay = 0.5 // 0.5s pause after speech
        
        synthesizer.speak(utterance)
    }
    
    /// Instantly cuts off ongoing speech and clears queue when user stops or finishes exercise
    static func stop() {
        shared.stopSpeaking()
    }
    
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        lastSpeechEndTime = Date.distantPast
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        lastSpeechEndTime = Date()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        lastSpeechEndTime = Date.distantPast
    }
}

class Feedback {
    @frozen public enum ActionChange: String {
        case move = "move"
        case lean = "lean"
        case straighten = "straighten"
        case lower = "lower"
        case place = "place"
        case bend = "bend"
        case rotate = "rotate"
        case lift = "lift"
        case raise = "raise"
        case stretch = "stretch"
        case twist = "twist"
        case pull = "pull"
        case push = "push"
        case spread = "spread"
    }

    // MARK: ‑ Hướng di chuyển
    @frozen public enum DirectionChange: String {
        case up       = "up"
        case down     = "down"
        case forward  = "forward"
        case back     = "back"
        case apart    = "apart"
        case intoView = "into view"
        case onFloor  = "on floor"
        
        // Trạng thái vị trí/tương đối
        case higher   = "higher"
        case lower    = "lower"
        case closer   = "closer"
        case farther  = "farther"
        case wider    = "wider"
        case narrower = "narrower"
        
        // Trạng thái chất lượng / đồng đều
        case moreEven     = "more even"
        case moreAligned  = "more aligned"
        case moreBalanced = "more balanced"
        case moreStable   = "more stable"
        case smoother     = "smoother"
    }

    // MARK: ‑ Bộ phận cơ thể
    @frozen public enum Limb: String {
        case arm   = "arm"
        case hand  = "hand"
        case leg   = "leg"
        case knee  = "knee"
        case back  = "back"
        case torso = "torso"
        case head  = "head"
        case shoulder = "shoulder"
        case foot  = "foot"
        case ankle = "ankle"
        case wrist = "wrist"
        case hip   = "hip"
    }
    
    @frozen public enum LimbDirection: String {
        case left = "left"
        case right = "right"
    }

    
    static func show(_ action: ActionChange, LR limbDirection: LimbDirection? = nil, _ limb: Limb? = nil, _ direction: DirectionChange? = nil) -> String {
        let limbDirectionDefault = limbDirection?.rawValue ?? ""
        let directionChange = direction?.rawValue ?? ""
        let limb = limb?.rawValue ?? ""
        return "\(action) \(limbDirectionDefault) \(limb) \(directionChange)"
    }
}

