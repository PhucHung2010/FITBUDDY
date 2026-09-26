# FitBuddy: AI-Driven Physical Rehabilitation & Motion Tracking Assistant

 

https://github.com/user-attachments/assets/93232178-133e-40b9-8b90-101326f4d293



https://github.com/user-attachments/assets/1b9f2adf-8f9c-40ba-abe2-611d4ec78236





> **An assistive on-device computer vision iOS application engineered to deliver real-time posture correction, rep counting, and clinical exercise tracking for rehabilitation and home wellness.**

[![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-SwiftUI%20%7C%20SwiftData-orange.svg)](https://swift.org)
[![Computer Vision](https://img.shields.io/badge/AI-Google%20ML%20Kit%20Pose%20Detection-green.svg)](https://developers.google.com/ml-kit/vision/pose-detection)
[![Status](https://img.shields.io/badge/Build-Working%20Prototype-brightgreen.svg)]()

---

## 🎥 Live Product Demo

<!-- Kéo thả file video trực tiếp vào đây hoặc thay thế bằng đường dẫn assets/demo.gif -->
<p align="center">
  <img src="assets/demo_curl.gif" width="45%" alt="Dumbbell Curl Joint Angle Tracking & Rep Counter" />
  <img src="assets/demo_jumping_jack.gif" width="45%" alt="Jumping Jack Form Deviation Feedback" />
</p>

---

## 📌 Problem & Motivation
Many individuals undergoing post-surgery recovery or managing musculoskeletal conditions perform home rehabilitation exercises incorrectly without professional supervision. Unsupervised training frequently leads to secondary trauma, extended recovery timelines, and muscle strain.

**FitBuddy** serves as an intelligent on-device virtual physiotherapist. Using only the smartphone's camera without any specialized external sensors, it analyzes body kinematics, computes joint angles, and provides instant audio-visual corrective cues to guarantee safe and effective form.

---

## 🚀 Key Features

* **Real-Time Skeletal Keypoint Tracking:** Integrates Google ML Kit Pose Detection on-device to track 33 skeletal landmarks at 30+ FPS directly from live camera feeds.
* **Vector-Based Biomechanical Engine:** Computes joint angles using vector dot-product formulas across anatomical keypoints (shoulder, elbow, wrist, hip, knee, ankle) to evaluate range of motion (ROM) against clinical standards.
* **Instant Dynamic Feedback (<100ms):** Automatically detects posture deviations (e.g., *lower right arm*, improper knee flexion) and triggers immediate on-screen textual alerts and audio cues before injury occurs.
* **Automated Repetition Counter:** Tracks movement phases (flexion/extension cycles) across exercises (Dumbbell Curls, Jumping Jacks, Squats) to reliably log completed reps.
* **Neuromuscular Hand Tracking:** Employs hand sign detection to monitor extended finger counts for fine motor control and neurological reflex recovery exercises.
* **On-Device Data Persistence:** Built with **SwiftData** to locally store workout schedules, accuracy history, and telemetry logs without mandatory network connectivity.

---

## 📊 Experimental Results & Validation

The application was benchmarked across simulated environments and physical iOS hardware (iPhone X to iPhone 15), alongside usability testing with **30+ human participants** (students, fitness practitioners, and individuals in home physical therapy):

* **Joint Landmark Precision:** Average coordinate error remained **under 5%** across major joints (shoulders, elbows, hips, knees) compared to ground-truth reference motions.
* **Corrective Accuracy:** **88%** of test participants reported that the real-time posture correction cues were precise, timely, and actionable.
* **Usability & UX:** **92%** positive usability rating for intuitive exercise navigation, calendar planning, and workflow simplicity.
* **Rehabilitation Adherence:** **85%** of participants demonstrated noticeable improvements in exercise technique and posture consistency within 1 week of testing.

---

## 📱 System Pipeline

```text
[iPhone Camera Feed]
         │
         ▼
[On-Device AI Engine] (Google ML Kit extracts 33 Skeletal Keypoints)
         │
         ▼
[Vector Calculation Engine] (Joint angles computed via cos θ = a·b / |a||b|)
         │
         ▼
[Biomechanical Evaluation] 
         │
         ├─── Correct Form ──────► Auto Increment Rep Counter
         │
         └─── Posture Deviation ─► Instant Text/Audio Alert (<100ms)
         │
         ▼
[SwiftData Local Store] (Session History, Completion Rate & Daily Logs)

