# Data Flow Diagrams (DFD)

## Level 0: Context Diagram

This diagram represents the entire "PashuSwasthya" system as a single process, interacting with external entities.

```plantuml
@startuml
skinparam handwritten false
skinparam componentStyle uml2

actor "User" as User
rectangle "Roboflow Cloud API" as Cloud
rectangle "PashuSwasthya System" as System #E3F2FD

' Data Flows
User -> System : 1. Upload/Capture Image
System -> User : 2. Show Disease/Breed Result

System -> Cloud : 3. Send Image (Online Mode)
Cloud -> System : 4. Return Prediction JSON

@enduml
```

## Level 1: DFD

This diagram breaks down the system into its major sub-processes and data stores, showing how data flows between them.

```plantuml
@startuml
skinparam handwritten false
skinparam packageStyle rectangle
top to bottom direction

' Styling
skinparam process {
    BackgroundColor White
    BorderColor #2C3E50
}
skinparam database {
    BackgroundColor White
    BorderColor #2C3E50
}
skinparam actor {
    BackgroundColor White
    BorderColor #2C3E50
}

' External Entities
actor "User" as User
rectangle "Roboflow API" as API

' Processes
rectangle "1.0 UI / Image Capture" as P1
rectangle "2.0 Detection Manager" as P2
rectangle "3.0 Offline Inference" as P3
rectangle "4.0 Online Inference" as P4
rectangle "5.0 History Management" as P5

' Data Stores
database "D1: Local Models\n(TFLite Files)" as D1
database "D2: SQLite DB\n(Prediction History)" as D2

' Flows

' User Interaction
User --> P1 : Image Input (Camera/Gallery)
P1 --> User : Display Results

' Main Control Flow
P1 --> P2 : Raw Image Data
P2 --> P1 : Final Prediction (Breed/Disease)

' Decision Logic (Online vs Offline)
P2 --> P4 : Image (If Online)
P4 --> API : HTTP Request
API --> P4 : JSON Response
P4 --> P2 : Prediction Result

P2 --> P3 : Image (If Offline/Fallback)
D1 --> P3 : Load Model Weights
P3 --> P2 : Prediction Result

' History Logging
P2 --> P5 : Save Result (PredictionData)
P5 --> D2 : Insert Record
D2 --> P5 : Retrieve History
P5 --> P1 : History List

@enduml
```

### Description of Processes

1.  **UI / Image Capture**: Handles user interaction, camera permissions, and image selection.
2.  **Detection Manager**: The core logic (`BreedDetectionService`, `DiseaseService`) that decides whether to use the online API or the offline model.
3.  **Offline Inference**: Preprocesses the image and runs it through the MobileNet TensorFlow Lite interpreter.
4.  **Online Inference**: Sends the image to the Roboflow API and parses the response.
5.  **History Management**: Handles saving prediction results to the local SQLite database for future reference.
