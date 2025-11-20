//
//  ExercisesData.swift
//  WorkoutTracker
//
//  Created by Evan Nelson on 11/20/25.
//

import Foundation

let exercises: [String : [Exercise]] = [
    "Biceps": [
        Exercise(
            name: "Dumbbell Curl",
            videoName: "dumbbell_curl",
            tips: [
                "Keep elbows tight to your sides",
                "Control the lowering motion",
                "Avoid swinging your body"
            ]
        ),
        Exercise(
            name: "Hammer Curl",
            videoName: "hammer_curl",
            tips: [
                "Keep neutral grip the entire movement",
                "Lift with control",
                "Squeeze at the top"
            ]
        )
    ],
    
    "Triceps": [
        Exercise(
            name: "Tricep Rope Pushdown",
            videoName: "rope_pushdown",
            tips: [
                "Keep elbows tucked",
                "Push the rope apart at the bottom",
                "Control the return"
            ]
        )
    ]
]
