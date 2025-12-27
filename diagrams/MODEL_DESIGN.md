# Model Design

This document covers the **Data Model** (Software Entities & Schema) and the **Neural Network Architecture** (AI Model) used in the PashuSwasthya project.

## 1. Data Model & Services (Class Diagram)

This diagram represents the core data entities, including persistent database models (`PredictionHistory`, `UserSession`) and domain logic models (`TreatmentGuide`, `OfflinePrediction`).

```plantuml
@startuml
skinparam class {
    BackgroundColor White
    ArrowColor #2C3E50
    BorderColor #2C3E50
}
skinparam roundCorner 10

title Data Entities & Services Class Diagram

package "Persistent Models (Database)" {
    class PredictionHistory {
        + String id
        + String type
        + String result
        + double confidence
        + DateTime timestamp
        + String? imagePath
        + String? notes
        --
        + toMap(): Map<String, dynamic>
        + {static} fromMap(Map): PredictionHistory
    }

    class UserSession {
        + int id
        + String mobileNumber
        + String? userName
        + String? userPlace
        + bool isLoggedIn
    }
}

package "Domain Models (Logic)" {
    class TreatmentGuide {
        + String diseaseName
        + String code
        + List<String> symptoms
        + List<String> treatmentSteps
        + List<String> precautions
        + List<String> firstAid
        + bool isSevere
        + List<String> emergencyContacts
        + String description
    }

    class OfflinePrediction {
        + String primaryClass
        + double confidence
        + List<PredictionItem> topPredictions
        --
        + formattedResult: String
    }
    
    class PredictionItem {
        + String label
        + double confidence
    }
}

package "Services" {
    class DatabaseHelper {
        - {static} DatabaseHelper _instance
        + {static} get instance(): DatabaseHelper
        + insertPrediction(PredictionHistory): Future<int>
        + getPredictionHistory(): Future<List<PredictionHistory>>
        + loginUser(String mobile, ...): Future<int>
        + getUserDetails(): Future<Map>
    }
    
    class OfflineModelService {
        - Interpreter? _breedInterpreter
        - Interpreter? _diseaseInterpreter
        + initializeBreedModel(): Future<bool>
        + initializeDiseaseModel(): Future<bool>
        + detectBreed(File): Future<OfflinePrediction>
        + classifyDisease(File): Future<OfflinePrediction>
    }
}

' Relationships
DatabaseHelper ..> PredictionHistory : manages >
DatabaseHelper ..> UserSession : manages >
OfflineModelService ..> OfflinePrediction : returns >
OfflinePrediction *-- PredictionItem : contains >

@enduml
```

## 2. Neural Network Architecture (MobileNet V2)

The application uses **MobileNet V2** optimized for mobile devices via SQLite/TFLite. The models are quantized and run offline.

**Model Specifications:**
- **Input:** 224 x 224 x 3 (RGB)
- **Framework:** TensorFlow Lite
- **Task:** Multi-class Classification (Breed & Disease)

```plantuml
@startuml
skinparam handwritten false
skinparam componentStyle uml2

' Styling
skinparam component {
    BackgroundColor #FFF9C4
    BorderColor #FBC02D
    ArrowColor #F57F17
}

title MobileNet V2 Architecture (TFLite Inference)

component "Input Image\n(224 x 224 x 3)" as Input

package "Preprocessing" {
    component "Resize \n(1024 -> 224)" as Resize
    component "Normalize \n(0-255 -> 0.0-1.0)" as Normalize
}

package "Feature Extraction Layers" {
    component "Conv2D\n(32 Filters, Stride 2)" as L1
    
    component "Bottleneck 1\n(Inverted Residual)" as B1
    component "Bottleneck 2\n(Inverted Residual)" as B2
    component "..." as B_More
    component "Bottleneck 16\n(Inverted Residual)" as B16
    
    component "Conv2D\n(1280 Filters, 1x1)" as L_LastConv
}

package "Classification Head" {
    component "Global Avg Pooling\n(7 x 7 -> 1 x 1)" as GAP
    component "Fully Connected\n(Dense Layer)" as FC
    component "Softmax\n(Probability Distribution)" as Softmax
}

component "Output Prediction\n(Top N Classes)" as Output

' Connections
Input --> Resize
Resize --> Normalize
Normalize --> L1
L1 --> B1
B1 --> B2
B2 --> B_More
B_More --> B16
B16 --> L_LastConv
L_LastConv --> GAP
GAP --> FC
FC --> Softmax
Softmax --> Output

note right of B1
  **Inverted Residual Block**:
  1. Expansion (1x1 Conv)
  2. Depthwise Conv (3x3)
  3. Projection (1x1 Conv)
end note

@enduml
```
