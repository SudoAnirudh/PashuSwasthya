# Use Case Diagram

This diagram illustrates the functional requirements of the system and how the different actors (Farmer, Admin, Veterinary Doctor) interact with it.

```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle
skinparam actorStyle awesome

' Actors
actor "Farmer" as Farmer
actor "Veterinary Doctor" as Vet
actor "Admin" as Admin

package "PashuSwasthya App" {
    
    ' Farmer Use Cases
    usecase "Detect Breed" as UC_Breed
    usecase "Detect Disease" as UC_Disease
    usecase "View History" as UC_History
    usecase "View Treatment Guide" as UC_Treatment
    usecase "Capture/Upload Image" as UC_Image
    
    ' Shared/Common
    usecase "Login / Authenticate" as UC_Login
    usecase "Change Language" as UC_Lang
    
    ' Vet Use Cases
    usecase "Verify Diagnosis" as UC_Verify
    usecase "Provide Expert Advice" as UC_Advice
    
    ' Admin Use Cases
    usecase "Manage Users" as UC_ManageUsers
    usecase "Update App Content" as UC_UpdateContent
    
    ' Relationships - Farmer
    Farmer --> UC_Login
    Farmer --> UC_Breed
    Farmer --> UC_Disease
    Farmer --> UC_History
    Farmer --> UC_Treatment
    Farmer --> UC_Lang
    
    ' Relationships - Vet
    Vet --> UC_Login
    Vet --> UC_Verify
    Vet --> UC_Advice
    Vet --> UC_Disease : (Review)
    
    ' Relationships - Admin
    Admin --> UC_Login
    Admin --> UC_ManageUsers
    Admin --> UC_UpdateContent

    ' Includes & Extends
    UC_Breed ..> UC_Image : <<include>>
    UC_Disease ..> UC_Image : <<include>>
    
    UC_Verify .> UC_History : <<extend>> \n(Review Case)
    
}

note right of Vet
  Can review complex cases
  and provide expert analysis
end note

@enduml
```

## Actor Descriptions

1.  **Farmer**: The primary user who uses the app to identify cattle breeds and diseases in the field.
2.  **Veterinary Doctor**: A specialized user who can review detection results and provide expert medical advice or verify the app's diagnosis.
3.  **Admin**: Responsible for managing user accounts, updating the disease/breed database, and maintaining the application content.
