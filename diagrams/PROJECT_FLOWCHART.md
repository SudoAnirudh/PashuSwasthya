# Project Flowchart

@startuml
skinparam activity {
    BackgroundColor #E3F2FD
    BorderColor #1565C0
    ArrowColor #2C3E50
}

skinparam roundCorner 10

title PashuSwasthya - Complete User Flow

start

:Launch App;

if (First Time?) then (yes)
    :Select Language Screen;
    :View Splash Screen;
else (no)
    :View Splash Screen;
endif

:Go to Home Screen;

fork
    :User Selects\n"Breed & Disease Detection";
    
    partition "Detection Process" {
        :Show Combined Detection Screen;
        
        ' Step 1: Breed
        :Step 1: Upload/Capture Cattle Image;
        
        if (Internet Available?) then (yes)
            :Call Roboflow API (Online);
        else (no)
            :Run MobileNet TFLite (Offline);
        endif
        
        :Display Breed Result;
        
        ' Step 2: Disease
        :User Clicks "Continue";
        :Step 2: Upload/Capture Symptom Image;
        
        if (Internet Available?) then (yes)
            :Call Roboflow API (Online);
        else (no)
            :Run MobileNet TFLite (Offline);
        endif
        
        :Display Disease Result;
        
        :Show Combined Result & Confidence;
        
        :Save to History (SQLite);
        
        if (Disease Detected?) then (yes)
            :Button: View Treatment;
            :Show Treatment Guide;
        endif
    }

fork again
    :User Selects\n"Treatment Guide";
    :Search/Browse Diseases;
    :View Treatment Details;
    
fork again
    :User Selects\n"Settings";
    :Change Language / Theme;

end fork

stop

@enduml
```
