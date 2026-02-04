# WorkoutTracker

**WorkoutTracker** is an iOS fitness application built with **Xcode (Swift / SwiftUI)** that allows users to log workouts by exercise and repetitions, track progress over 
time, earn awards, and receive guided exercise suggestions with visual aids. The app is designed as a complete, connected fitness workflow suitable for a senior capstone 
project.

---

## Table of Contents

1. Overview
2. Key Features
3. System Architecture
4. Installation & Setup
5. How to Use the App
6. Example Workflows
7. Awards & Progress Tracking
8. Suggestions & Visual Aids
9. Data Flow (Fitness App Integration)
10. Technologies Used
11. Future Enhancements

---

## 1. Overview

WorkoutTracker focuses on **simple, structured workout logging** without requiring duration, intensity levels, or custom goal creation. Users log workouts by selecting an 
exercise and entering repetitions and weight. All components are connected in a single fitness app flow called **WorkoutTracker**, ensuring consistency from input to analytics.

The application is intended for:

* Users who want fast, repeatable workout logging
* Demonstrating mobile app development best practices in iOS
* Users looking for feedback and evaluation 

---

## 2. Key Features

### User Inputs

* Enter what exercise was completed
* Select what muscle group was used during the exercise 
* Enter number of repetitions and weight
* Save workout entry

### Workout Log

* Chronological list of completed workouts
* Displays exercise name, repetitions, and date
* Deletable entries

### Progress Tracking

* Visual summary of repetitions and weight over time
* Exercise frequency tracking
* Weekly and monthly trends

### Awards

* Award unlocking system
* Award tracking history
* Visual badges for milestones

### Suggestions

* Exercise ideas
* Embedded video links for visual guidance
* Beginner-friendly recommendations

---

## 3. System Architecture

The app is organized into modular components:

* **UI Layer (SwiftUI Views)**
  Handles user interaction and navigation

* **Workout Manager**
  Stores and retrieves workout entries

* **Progress Engine**
  Aggregates workout data for analytics

* **Awards Engine**
  Evaluates milestones and unlocks awards

* **Suggestion Engine**
  Recommends exercises and videos

All components connect through the **WorkoutTracker** flowchart, ensuring consistent data movement from input to feedback.

---

## 4. Installation & Setup

1. Clone the repository:

   ```
   git clone https://github.com/yourusername/WorkoutTracker.git
   ```
2. Open the project in Xcode:

   ```
   open WorkoutTracker.xcodeproj
   ```
3. Select an iOS Simulator or connected device
4. Build and run the application

---

## 5. How to Use the App

1. Launch WorkoutTracker
2. Navigate to **Add Workout**
3. Enter in the exercise completed and select what muscle group this exercise focused on 
4. Enter repetitions
5. Save workout
6. View updates in **Workout Log**, **Progress**, and **Awards**

---

## 6. Example Workflows

### Example 1: Logging a Workout

* User selects *Squats*
* Enters *30 repetitions*
* Saves entry
* Workout appears in log with today’s date

### Example 2: Viewing Progress

* User opens **Progress** tab
* Sees total repetitions and weight per exercise
* Reviews weekly improvement trends

### Example 3: Earning an Award

* User logs workouts 20 days in a single month 
* "Gym Rat" award unlocks
* Award badge appears in Awards section

---

## 7. Awards & Progress Tracking

### Awards

* First Workout Completed
* 5 different exercises logged 
* 10-Day Consistency Streak

Each award is tracked with:

* Unlock date
* Description
* Visual badge

### Progress

* Aggregate repetition counts
* Exercise frequency analysis
* Long-term performance trends

---

## 8. Suggestions & Visual Aids

The Suggestions section provides:

* Specific exercise ideas (e.g., Lunges, Planks)
* Short descriptions of proper form
* Linked videos for visual demonstration

---

## 9. Data Flow (Fitness App Integration)

1. User logs workout
2. Data stored locally
3. Entry displays within history page 
4. Progress Engine updates analytics
5. Awards Engine checks history to update award progress 

This unified flow defines the **WorkoutTracker Fitness App Flowchart**.

---

## 10. Technologies Used

* Swift
* SwiftUI
* Xcode
* iOS SDK

---

## 11. Future Enhancements

* Apple Watch integration
* Personalized AI-based suggestions
* Exportable workout reports

---

## Author

Senior Capstone Project – Evan Nelson
