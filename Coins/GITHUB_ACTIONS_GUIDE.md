# GitHub Actions Setup Guide for Coins App

## What is GitHub Actions?

GitHub Actions is a CI/CD (Continuous Integration/Continuous Deployment) platform that allows you to automate workflows directly in your GitHub repository. It can run tests, build your app, deploy to App Store, and more - all automatically when you push code or create pull requests.

---

## What GitHub Actions Can Do For Your Project

### 1. **Automated Testing**
- Run all your unit tests on every push/PR
- Test on multiple iOS versions (iOS 13, 14, 15, etc.)
- Test on different simulators (iPhone, iPad)
- Get immediate feedback if tests fail

### 2. **Code Quality Checks**
- Run SwiftLint to enforce code style
- Check for code coverage
- Validate that code compiles

### 3. **Build Verification**
- Ensure your app builds successfully
- Test on different Xcode versions
- Catch build errors before merging

### 4. **Automated Deployment** (Advanced)
- Build and upload to TestFlight automatically
- Deploy to App Store when you tag a release
- Create beta builds for testers

### 5. **Pull Request Checks**
- Automatically run tests when PRs are created
- Block merging if tests fail
- Show test results directly in PR comments

---

## Setup Steps

### Step 1: Create the Workflow Directory

GitHub Actions workflows are stored in `.github/workflows/` directory in your repository root.

**Create the directory structure:**
```bash
mkdir -p .github/workflows
```

### Step 2: Create a Basic Workflow File

Create a file called `.github/workflows/ci.yml` (or any name ending in `.yml` or `.yaml`)

### Step 3: Choose Your Workflow

Below are example workflows you can use. Start with the **Basic CI** workflow, then add others as needed.

---

## Example Workflows

### Workflow 1: Basic CI (Run Tests)

This is the most important workflow - it runs your tests on every push and pull request.

**File:** `.github/workflows/ci.yml`

```yaml
name: CI

# When to run this workflow
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  # Job: Run Tests
  test:
    name: Run Tests
    runs-on: macos-14  # or macos-13, macos-15 (latest)
    
    strategy:
      matrix:
        # Test on multiple iOS versions
        destination: 
          - 'platform=iOS Simulator,name=iPhone 15,OS=latest'
          - 'platform=iOS Simulator,name=iPhone SE (3rd generation),OS=latest'
          - 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation),OS=latest'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_15.2.app
        # Or use: xcode-version: '15.2' action
      
      - name: Show Xcode version
        run: xcodebuild -version
      
      - name: Show Swift version
        run: swift --version
      
      - name: List available simulators
        run: xcrun simctl list devices available
      
      - name: Run tests
        run: |
          xcodebuild test \
            -scheme Coins \
            -destination "${{ matrix.destination }}" \
            -enableCodeCoverage YES \
            -quiet
      
      - name: Generate code coverage report
        run: |
          xcrun xccov view --report --only-targets DerivedData/Build/Logs/Test/*.xcresult
```

### Workflow 2: Build Verification

Ensures your app builds successfully without running tests.

**File:** `.github/workflows/build.yml`

```yaml
name: Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    name: Build App
    runs-on: macos-14
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app
      
      - name: Build for iOS Simulator
        run: |
          xcodebuild build \
            -scheme Coins \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -quiet
      
      - name: Build for iOS Device (Release)
        run: |
          xcodebuild build \
            -scheme Coins \
            -configuration Release \
            -destination 'generic/platform=iOS' \
            -quiet
```

### Workflow 3: SwiftLint (Code Quality)

Runs SwiftLint to check code style (if you're using SwiftLint).

**File:** `.github/workflows/swiftlint.yml`

```yaml
name: SwiftLint

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  lint:
    name: Run SwiftLint
    runs-on: macos-14
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: SwiftLint
        uses: norio-nomura/action-swiftlint@3.2.1
        with:
          args: --strict
```

### Workflow 4: TestFlight Deployment (Advanced)

Automatically builds and uploads to TestFlight when you create a release.

**File:** `.github/workflows/deploy.yml`

```yaml
name: Deploy to TestFlight

on:
  release:
    types: [created]

jobs:
  deploy:
    name: Build and Deploy
    runs-on: macos-14
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app
      
      - name: Install certificates
        # You'll need to set up certificates and provisioning profiles
        # This is a simplified example
        run: |
          # Add your certificate installation steps here
          echo "Install certificates"
      
      - name: Build archive
        run: |
          xcodebuild archive \
            -scheme Coins \
            -configuration Release \
            -archivePath ./build/Coins.xcarchive \
            -destination 'generic/platform=iOS'
      
      - name: Export IPA
        run: |
          xcodebuild -exportArchive \
            -archivePath ./build/Coins.xcarchive \
            -exportPath ./build \
            -exportOptionsPlist ExportOptions.plist
      
      - name: Upload to TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: './build/Coins.ipa'
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}
```

---

## Quick Start: Minimal Setup

For a quick start, create this minimal workflow:

**File:** `.github/workflows/test.yml`

```yaml
name: Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-14
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Run tests
        run: |
          xcodebuild test \
            -scheme Coins \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -quiet
```

---

## Required Setup Steps

### 1. **Find Your Scheme Name**

Your Xcode project has a "scheme" name. To find it:

```bash
# In your project directory
xcodebuild -list
```

Look for the scheme name (probably "Coins" or "CoinsApp")

### 2. **Test Locally First**

Before pushing to GitHub, test the command locally:

```bash
xcodebuild test \
  -scheme Coins \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 3. **Create the Workflow File**

1. Create `.github/workflows/` directory in your project root
2. Create a `.yml` file (e.g., `ci.yml`)
3. Copy one of the workflows above
4. Adjust the scheme name and destinations

### 4. **Commit and Push**

```bash
git add .github/workflows/ci.yml
git commit -m "Add GitHub Actions CI workflow"
git push
```

### 5. **Check GitHub**

Go to your GitHub repository → **Actions** tab to see the workflow running.

---

## Common Issues and Solutions

### Issue: "Scheme not found"

**Solution:** Make sure the scheme name matches exactly. Check with:
```bash
xcodebuild -list
```

### Issue: "Simulator not found"

**Solution:** Use a simulator that exists. List available simulators:
```bash
xcrun simctl list devices available
```

### Issue: "Tests fail but work locally"

**Solution:** 
- Check that all dependencies are committed
- Ensure test data files are included
- Verify simulator name matches exactly

### Issue: "Build takes too long"

**Solution:**
- Use `-quiet` flag to reduce output
- Only test on one simulator initially
- Cache dependencies if using Swift Package Manager

---

## Advanced: Caching Dependencies

If you use Swift Package Manager, cache dependencies to speed up builds:

```yaml
- name: Cache Swift packages
  uses: actions/cache@v3
  with:
    path: .build
    key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
    restore-keys: |
      ${{ runner.os }}-spm-
```

---

## What You'll See in GitHub

Once set up, you'll see:

1. **Actions Tab** - Shows all workflow runs
2. **Green Checkmark** ✅ - Tests passed
3. **Red X** ❌ - Tests failed
4. **Yellow Circle** ⏳ - Workflow running
5. **PR Status** - Test results shown directly in pull requests

---

## Benefits for Your Project

1. **Catch Bugs Early** - Tests run automatically, catch issues before merging
2. **Confidence** - Know that code works before deploying
3. **Documentation** - Shows that your project has automated testing
4. **Team Collaboration** - Everyone sees test results
5. **Professional** - Shows you follow best practices

---

## Next Steps

1. **Start Simple** - Use the minimal test workflow first
2. **Add More Tests** - Test on multiple simulators
3. **Add Code Quality** - Add SwiftLint if you use it
4. **Add Build Checks** - Verify builds succeed
5. **Advanced** - Set up TestFlight deployment (requires App Store Connect setup)

---

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Xcode Build Settings](https://developer.apple.com/documentation/xcode)
- [iOS Simulator Names](https://developer.apple.com/documentation/xcode/running-destinations)

---

## Example: Complete CI Workflow

Here's a complete, production-ready CI workflow:

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    name: Test on iOS ${{ matrix.ios }}
    runs-on: macos-14
    
    strategy:
      fail-fast: false
      matrix:
        ios: ['17.0', '16.0']
        device: ['iPhone 15', 'iPhone SE (3rd generation)']
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app
      
      - name: Show versions
        run: |
          xcodebuild -version
          swift --version
      
      - name: Run tests
        run: |
          xcodebuild test \
            -scheme Coins \
            -destination "platform=iOS Simulator,name=${{ matrix.device }},OS=${{ matrix.ios }}" \
            -enableCodeCoverage YES \
            -quiet \
            | xcpretty
      
      - name: Upload coverage
        if: matrix.ios == '17.0' && matrix.device == 'iPhone 15'
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml
```

---

## Summary

**To set up GitHub Actions:**

1. Create `.github/workflows/` directory
2. Add a `.yml` workflow file
3. Configure it to run your tests
4. Push to GitHub
5. Check the Actions tab

**What it gives you:**

- ✅ Automated testing on every push/PR
- ✅ Build verification
- ✅ Code quality checks
- ✅ Professional CI/CD setup
- ✅ Confidence in your code

Start with the minimal workflow and expand as needed!

