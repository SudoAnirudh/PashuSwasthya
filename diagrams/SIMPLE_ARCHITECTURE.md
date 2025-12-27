
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

title Simplified MobileNet Inference Process

actor "User" as User

package "App" {
    component "Camera / Gallery" as Camera
    component "Detection Service" as Service
}

package "AI Engine (Offline)" {
    component "Image Processing" as Processor
    component "MobileNet Model" as AI_Model
}

' Flow
User -> Camera : 1. Take Photo
Camera -> Service : 2. Send Image
Service -> Processor : 3. Prepare Image
Processor -> AI_Model : 4. Run Analysis
AI_Model -> Service : 5. Return Prediction (e.g., "Jersey Cow: 95%")
Service -> User : 6. Show Result

note right of AI_Model
  Uses on-device
  MobileNet V2
  (No Internet needed)
end note

@enduml
