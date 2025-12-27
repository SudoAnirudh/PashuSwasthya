# PashuSwasthya System Architecture

## 1. High-Level System Architecture

The application follows a **Layered Architecture** typical for Flutter applications, featuring a **Hybrid AI Strategy** that falls back to offline MobileNet models when internet connectivity is unavailable.

```plantuml
@startuml
skinparam handwritten false
skinparam componentStyle uml2
skinparam roundCorner 15
skinparam shadowKey true

' Graph Direction
top to bottom direction

' Scale for visibility
scale 1.2

' Styling
skinparam package {
    BackgroundColor White
    BorderColor #455A64
    FontColor #455A64
    FontStyle bold
}

skinparam component {
    BackgroundColor #E3F2FD
    BorderColor #1565C0
    ArrowColor #1565C0
    FontColor Black
    FontSize 14
}

skinparam interface {
    BackgroundColor #FFF9C4
    BorderColor #FBC02D
}

skinparam database {
    BackgroundColor #F3E5F5
    BorderColor #8E24AA
}

title "PashuSwasthya - High Level Architecture"

package "Presentation Layer (Flutter UI)" {
    component [Main Dashboard\n(Home Screen)] as Home
    component [Detection Interface\n(Combined Screen)] as UI_Detect
    component [Treatment Guide Access] as UI_Guide
}

package "Business Logic Layer (Services)" {
    interface "Detection Contract" as IDetection
    
    component [Breed Detection Service] as Svc_Breed
    component [Disease Prediction Service] as Svc_Disease
    component [Treatment Service] as Svc_Treat
    component [Localization Service] as Svc_Local
    
    note right of Svc_Breed
        **Hybrid Strategy**:
        Checks connectivity.
        Uses Online API if available,
        falls back to Offline Model.
    end note
}

package "Data & Infrastructure Layer" {
    component [Roboflow Client\n(Online API)] as Infra_Cloud
    component [TFLite Model Engine\n(Offline Inference)] as Infra_LocalAI
    component [Storage Service\n(History & Prefs)] as Infra_Storage
    
    database "SQLite DB" as DB
    database "TFLite Files" as Assets
}

' Relationships

' UI to Logic
Home -d-> UI_Detect : Navigates
Home -d-> UI_Guide : Navigates
UI_Detect -d-> Svc_Breed : Requests
UI_Detect -d-> Svc_Disease : Requests
UI_Detect -d-> Svc_Treat : Fetches Info
UI_Detect -d-> Infra_Storage : Saves History

Svc_Breed .u.|> IDetection
Svc_Disease .u.|> IDetection

' Logic to Infra
Svc_Breed -d-> Infra_Cloud : 1. Try Online
Svc_Breed -d-> Infra_LocalAI : 2. Fallback Offline

Svc_Disease -d-> Infra_Cloud : 1. Try Online
Svc_Disease -d-> Infra_LocalAI : 2. Fallback Offline

Svc_Treat -d-> Svc_Local : Translates

' Infra to Raw Data
Infra_Storage -d-> DB : Read/Write
Infra_LocalAI -l-> Assets : Load Models

center footer "Layered Hybrid AI Architecture"

@enduml
```

## 2. MobileNet Inference Pipeline (Offline Mode)

This section details the on-device inference pipeline using **MobileNet V2** via TensorFlow Lite. This pipeline is activated when the app is offline or the Roboflow API is unreachable.

```plantuml
@startuml
skinparam componentStyle uml2
skinparam packageStyle rectangle
skinparam roundCorner 10
skinparam handwritten false

' Simplified Styling
skinparam component {
    BackgroundColor #E3F2FD
    BorderColor #1565C0
    ArrowColor #1565C0
}

title MobileNet Inference (Simplified)

actor "User" as User

package "PashuSwasthya App" {
    component "1. Capture Image" as Camera
    component "2. Process Image" as Preprocessor
    component "MobileNet AI\n(Offline Model)" as AI
    component "3. Display Result" as Result
}

' Flow
User -> Camera
Camera -> Preprocessor : Raw Image
Preprocessor -> AI : Optimized Input
AI -> Result : Prediction (e.g. Jersey Cow)
Result -> User

note right of AI
  Runs locally on phone.
  No internet needed.
end note

@enduml
```

### Inference Sequence Diagram

The data flow during an offline prediction request:

```plantuml
@startuml
skinparam sequenceMessageAlign center
autoactivate on

participant "User" as User
participant "App (UI)" as App
participant "OfflineService" as Service
participant "ImageProcessor" as Img
participant "MobileNet (TFLite)" as Model

User -> App : Captures Image
App -> Service : detectBreed(File image)

group Preprocessing [MobileNet Requirements]
    Service -> Img : decodeImage(bytes)
    return Bitmap
    
    Service -> Img : copyResize(224, 224)
    return Resized Bitmap (224x224)
    
    Service -> Service : Normalize Pixel Values
    note right
        Convert ints [0..255]
        to floats [0.0..1.0]
        Input Shape: [1, 224, 224, 3]
    end note
end

group Inference
    Service -> Model : run(inputBuffer, outputBuffer)
    note right
        **MobileNet Layers**:
        1. Conv2d
        2. Depthwise Conv
        3. Pointwise Conv
        ...
        4. Global Avg Pooling
        5. Dense (Softmax)
    end note
    return outputBuffer [Probabilities]
end

group Post-Processing
    Service -> Service : Get Top K Predictions
    note right
        Map output indices to Labels
        Example:
        Index 0 -> "Holstein" (0.85)
        Index 1 -> "Jersey" (0.10)
    end note
end

Service -> App : return OfflinePrediction
App -> User : Show "Holstein Friesian (85%)"

@enduml
```
