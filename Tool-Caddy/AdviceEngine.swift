//
//  AdviceEngine.swift
//  Tool-Caddy
//
//  Created by Sohum Mogale on 20/5/2026.
//

import Foundation

enum LieType: String {
    case fairway = "Fairway"
    case rough = "Rough"
    case hardPan = "HardPan"
}

 
struct LiePrediction {
    let lieType: LieType
    //let confidence: Float
}

struct ShotAdvice {
    let title: String
    let detail: String
}

struct AdviceEngine {
    //static let lowConfidenceThreshold : Float = 0.65
    
    static func advice(for prediction: LiePrediction) -> ShotAdvice {
        
        switch prediction.lieType {
            case .fairway:
            return ShotAdvice(title: "Good Shot", detail: "Keep your stance and swing")
        case .rough:
            return ShotAdvice(title: "Take less club", detail: "Slightly back of stance ball first contact")
        case .hardPan:
            return ShotAdvice(title: "punch shot, take more cluyb", detail: "Ensure Ball first contact")
//        case .bunker:
//            return ShotAdvice(title: "Watch the ball", detail: "Keep your stance and swing")

//        case .mulch:
            
        }
    }
    
}


