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
    
    var text: String = ""
    
    convenience init(text: String) {
        self.init()
        self.text = text
    }
    
    func say() {
        say(text: self.text)
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
        
        var vi: String {
            switch self {
            case .move:       return "Di chuyển"
            case .lean:       return "Nghiêng"
            case .straighten: return "Duỗi thẳng"
            case .lower:      return "Hạ"
            case .place:      return "Đặt"
            case .bend:       return "Gập"
            case .rotate:     return "Xoay"
            case .lift:       return "Nâng"
            case .raise:      return "Giơ lên"
            case .stretch:    return "Kéo giãn"
            case .twist:      return "Vặn"
            case .pull:       return "Kéo"
            case .push:       return "Đẩy"
            case .spread:     return "dãn"
            }
        }
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
        
        var vi: String {
            switch self {
            case .up:       return "lên trên"
            case .down:     return "xuống dưới"
            case .forward:  return "về phía trước"
            case .back:     return "ra sau"
            case .apart:    return "ra ngoài"
            case .intoView: return "vào khung hình"
            case .onFloor:  return "xuống sàn"
                
            case .higher:   return "cao hơn"
            case .lower:    return "thấp hơn"
            case .closer:   return "gần hơn"
            case .farther:  return "xa hơn"
            case .wider:    return "rộng hơn"
            case .narrower: return "hẹp hơn"
                
            case .moreEven:     return "đồng đều hơn"
            case .moreAligned:  return "thẳng hàng hơn"
            case .moreBalanced: return "cân bằng hơn"
            case .moreStable:   return "ổn định hơn"
            case .smoother:     return "mượt"
            }
        }
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
        
        var vi: String {
            switch self {
            case .arm:      return "tay"
            case .hand:     return "bàn tay"
            case .leg:      return "chân"
            case .knee:     return "đầu gối"
            case .back:     return "lưng"
            case .torso:    return "thân người"
            case .head:     return "đầu"
            case .shoulder: return "vai"
            case .foot:     return "bàn chân"
            case .ankle:    return "mắt cá"
            case .wrist:    return "cổ tay"
            case .hip:      return "hông"
            }
        }
    }

    
    @frozen public enum LimbDirection: String {
        case left = "left"
        case right = "right"
        
        var vi: String {
            switch self {
            case .left: return "trái"
            case .right: return "phải"
            }
        }
    }

    
    static func show(_ action: ActionChange, LR limbDirection: LimbDirection? = nil, _ limb: Limb? = nil, _ direction: DirectionChange? = nil) -> String {
        let limbDirectionDefault = limbDirection?.rawValue ?? ""
        let directionChange = direction?.rawValue ?? ""
        let limb = limb?.rawValue ?? ""
        return "\(action) \(limbDirectionDefault) \(limb) \(directionChange)"
    }
}

