# Code Walkthrough Quick Checklist

## Before You Start (30 seconds)

- [ ] Open the project in Xcode/editor
- [ ] Have the file structure visible
- [ ] Take a deep breath - you've got this!

---

## Opening Statement (30 seconds)

**Say:**
> "I've built a cryptocurrency market app using SwiftUI and MVVM. The architecture has three layers: Models, Services, and Views/ViewModels. I've used dependency injection for testability and focused on defensive coding. Should I start with the architecture or dive into a specific component?"

---

## Walkthrough Order (15 minutes total)

### 1. Architecture Overview (2 min)
- [ ] Show folder structure
- [ ] Explain MVVM pattern
- [ ] Point out separation of concerns

### 2. Model Layer - Coin.swift (2 min)
- [ ] Show optional fields - explain why
- [ ] Show `isValid` validation
- [ ] Show safe accessors (safePriceChangePercent24H)
- [ ] **Key point**: "Defensive coding - validate at model level"

### 3. Service Layer - CoinService.swift (2 min)
- [ ] Show `CoinServiceProtocol` - explain dependency injection
- [ ] Walk through `fetchCoins()` method
- [ ] Show error handling (status codes, data validation)
- [ ] Show `coins.filter { $0.isValid }` - validation
- [ ] **Key point**: "Protocol enables testing, comprehensive error handling"

### 4. ViewModel - CoinsViewModel.swift (2 min)
- [ ] Show dependency injection: `init(service: CoinServiceProtocol)`
- [ ] Show `@Observable` for state management
- [ ] Show `fetchCoins()` - MainActor, error handling, guard for loading
- [ ] Show `getTrendingCoins()` - business logic in ViewModel
- [ ] **Key point**: "State management and business logic, not in views"

### 5. View Layer - ContentView.swift (2 min)
- [ ] Show ViewModel usage: `@State private var viewModel`
- [ ] Show computed property: `trendingCoins` delegates to ViewModel
- [ ] Show error handling UI (if/else for error state)
- [ ] Show reusable components: `CoinImageView`, `PriceFormatter`
- [ ] **Key point**: "Views are declarative, no business logic"

### 6. Reusable Components (1 min)
- [ ] Show `CoinImageView` - handles all image edge cases
- [ ] Show `PriceFormatter` - centralized formatting
- [ ] **Key point**: "DRY principle, consistency"

### 7. Key Decisions (2 min)
- [ ] **Dependency Injection**: "Makes code testable"
- [ ] **Protocol-Oriented**: "Abstraction, follows SOLID principles"
- [ ] **Defensive Coding**: "Validation at multiple layers"
- [ ] **Error Handling**: "Typed errors with user-friendly messages"

### 8. Areas for Improvement (2 min)
- [ ] Unit tests (now possible with DI)
- [ ] Retry logic with exponential backoff
- [ ] Image caching
- [ ] Localization

---

## Key Phrases to Use

### When showing architecture:
- "I organized this using MVVM for clear separation of concerns"
- "This separation makes the codebase maintainable and testable"

### When showing dependency injection:
- "The ViewModel accepts a service via its initializer - this is dependency injection"
- "This makes testing possible - we can inject a mock service"

### When showing validation:
- "This is defensive programming - we validate at the model level"
- "Safe accessors ensure the UI never deals with optionals directly"

### When showing error handling:
- "I created a custom NetworkError enum with user-friendly messages"
- "Errors are typed, so we can handle them specifically"

### When showing business logic:
- "Business logic lives in the ViewModel, not the view - this maintains separation of concerns"

### When showing reusable components:
- "I extracted this to avoid code duplication - follows DRY principles"
- "Centralized formatting ensures consistency"

---

## Common Questions & Answers

### Q: "Why MVVM?"
**A:** "MVVM fits SwiftUI well. ViewModels manage state and business logic, while views are declarative. It's testable and scales well."

### Q: "Why optionals in Coin model?"
**A:** "The API might not always return complete data. Optionals prevent crashes. Safe accessors keep views clean."

### Q: "Why a protocol?"
**A:** "Protocols enable dependency injection and testing. We depend on abstractions, not concretions - follows SOLID principles."

### Q: "What about testing?"
**A:** "The architecture is set up for testing. With dependency injection, we can mock the service. Given more time, I'd add unit tests for error scenarios and edge cases."

---

## Red Flags to Avoid

❌ **Don't say:**
- "I know this is bad, but..."
- "This probably isn't right..."
- "I'm not sure why I did this..."

✅ **Do say:**
- "I chose X because Y..."
- "This follows the [pattern name] pattern..."
- "Given more time, I'd add..."

---

## Time Checkpoints

- **0:00** - Start with architecture overview
- **2:00** - Finish architecture, start Model
- **4:00** - Finish Model, start Service
- **6:00** - Finish Service, start ViewModel
- **8:00** - Finish ViewModel, start View
- **10:00** - Finish View, show components
- **12:00** - Explain key decisions
- **14:00** - Areas for improvement
- **15:00** - Wrap up, Q&A

---

## Confidence Boosters

Remember:
- ✅ You have dependency injection
- ✅ You have proper error handling
- ✅ You have defensive coding
- ✅ You have separation of concerns
- ✅ You have reusable components

**You've built solid code. Now show them why it's solid!**

---

## Final Tips

1. **Pause for questions** - Don't rush through
2. **Ask if they want detail** - "Should I dive deeper into X?"
3. **Be enthusiastic** - Show you're proud of your work
4. **Explain the 'why'** - Not just the 'what'
5. **Acknowledge trade-offs** - Shows maturity

---

## If You Get Stuck

**If you forget something:**
> "Let me think about that for a moment..." (pause, then continue)

**If you don't know:**
> "That's a great question. I haven't implemented that yet, but given more time I would [explain approach]."

**If they point out an issue:**
> "You're right - that's something I'd improve. I'd [explain fix] because [reason]."

---

## Closing Statement

**End with:**
> "That's the core architecture. The key strengths are dependency injection for testability, defensive coding for reliability, and clear separation of concerns for maintainability. Are there any specific areas you'd like me to dive deeper into?"

---

**You've got this! 🚀**

