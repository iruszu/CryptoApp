# How to Downgrade Xcode Project Format

Your project is using Xcode project format 77 (Xcode 16), but GitHub Actions runners currently use Xcode 15. To make your CI work, you need to downgrade the project format.

## Steps to Downgrade Project Format

1. **Open your project in Xcode**
   ```bash
   open Coins.xcodeproj
   ```

2. **Go to Project Settings**
   - Click on the project name "Coins" in the Project Navigator (left sidebar)
   - Select the "Coins" project (not the target)
   - Click the "Info" tab at the top

3. **Change Project Format**
   - Find "Project Format" dropdown
   - Change from "Xcode 16.0-compatible" to "Xcode 15.0-compatible"
   - Or select the oldest format that works: "Xcode 14.0-compatible"

4. **Save**
   - Xcode will automatically save the change
   - The project file will be updated

5. **Commit the change**
   ```bash
   git add Coins.xcodeproj/project.pbxproj
   git commit -m "Downgrade project format for CI compatibility"
   git push
   ```

## Alternative: Use Xcode Command Line

If you prefer command line:

```bash
# This will downgrade to Xcode 15 format
# Note: You may need to adjust the format number
plutil -convert xml1 Coins.xcodeproj/project.pbxproj
# Then manually edit the objectVersion in the file
```

## What This Changes

- **Project Format 77** → **Project Format 54** (Xcode 15)
- Your code and functionality remain the same
- Only the project file format changes
- Compatible with Xcode 15.x and Xcode 16.x (backward compatible)

## Verify

After downgrading, verify it works:
```bash
xcodebuild -list -project Coins.xcodeproj
```

This should work without errors.


