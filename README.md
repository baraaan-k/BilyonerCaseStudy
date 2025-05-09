Bilyoner iOS Case Study
A lightweight, fully programmatic sports betting app built for the Bilyoner iOS job case. Built with UIKit, MVVM, RxSwift, Firebase, and The Odds API.
Features
Main Functions
* List matches with real-time odds (MS 1, MS X, MS 2)
* Select/deselect odds and build your bet slip
* Auto-calculation: total odds, stake (misli), potential win
* Match detail screen with updated odds
* All logic follows MVVM architecture
UI & Navigation
* Coordinator handles screen flow
* No Storyboards — only UIKit code
* RxSwift used for all data bindings
Bet Slip
* Add/remove selections in real time
* Stake control with UIStepper
* Live updates for total amount and win
* Deletion animations
Search
* Toggle search bar with animation
* Cancels via button or keyboard tap
Popular & Upcoming Matches
* Horizontal collection view for “Popular Matches”
* Table view section with header for “Upcoming Matches”
* Both keep selection state synced
Visual Details
* Right arrow icon for navigation clarity
* Localized text (English): Match Time, Odds, Prediction, etc.
Backend
* Firebase Auth (anonymous login)
* GoogleService-Info.plist required
* Odds fetched from The Odds API
Tech Stack
* UIKit (Programmatic UI)
* MVVM
* RxSwift / RxCocoa
* Firebase (Auth)
* Custom Views for all match and bet displays
Project Structure
* Coordinators
* ViewControllers
* ViewModels
* Views / Cells
* Models
* Networking
Setup
1. Clone the repo
2. Run pod install
3. Add your GoogleService-Info.plist
4. Set your API key in OddsService
5. Run in Xcode (iOS 15+)

Built for Bilyoner Case Study
