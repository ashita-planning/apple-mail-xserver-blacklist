# Xcode Project Setup

## Purpose

This document defines the recommended Xcode project structure for the Apple Mail XServer Blacklist app.

The `.xcodeproj` should be created in Xcode so that signing, capabilities, bundle identifiers, and MailKit extension settings are generated correctly.

## Recommended Targets

```text
XServerMailBlacklistApp
├── App target
├── MailKit extension target
├── Shared framework target
└── Unit test targets
```

## Bundle Identifier Recommendation

```text
jp.ashita-planning.XServerMailBlacklist
jp.ashita-planning.XServerMailBlacklist.MailExtension
jp.ashita-planning.XServerMailBlacklist.Shared
```

## Target Responsibilities

### App Target

Name suggestion:

```text
XServerMailBlacklist
```

Responsibilities:

- Settings UI
- XServer configuration management
- Keychain credential registration
- Operation history
- Diagnostics

### MailKit Extension Target

Name suggestion:

```text
XServerMailBlacklistMailExtension
```

Responsibilities:

- Apple Mail integration
- Selected message handling
- Sender extraction
- Calling companion/shared logic

### Shared Framework Target

Name suggestion:

```text
XServerMailBlacklistShared
```

Responsibilities:

- Domain models
- XServer client protocol
- Keychain service protocol
- Mailbox matcher
- Repository protocols
- Validation

## Suggested Folder Layout

```text
XServerMailBlacklist/
  App/
    Views/
    ViewModels/
    Repositories/

  MailExtension/
    Actions/
    MessageParsing/

  Shared/
    Models/
    Clients/
    Credentials/
    Matching/
    Validation/

  Tests/
    SharedTests/
    AppTests/

Docs/
Scripts/
```

## Xcode Creation Steps

1. Open Xcode.
2. Create a new macOS App project.
3. Set product name to `XServerMailBlacklist`.
4. Use Swift and SwiftUI.
5. Add a MailKit extension target.
6. Add a shared framework target or Swift package for reusable logic.
7. Add unit test targets.
8. Verify bundle identifiers.
9. Verify signing team.
10. Commit the generated `.xcodeproj`.

## Build Scripts

After the Xcode project exists, update scripts to use the actual scheme names.

Example:

```bash
xcodebuild \
  -scheme XServerMailBlacklist \
  -configuration Debug \
  build
```

## Important Notes

- Do not hand-edit `.xcodeproj` unless necessary.
- Do not commit personal signing credentials.
- Do not commit local `.xcuserstate` files.
- Keep reusable business logic outside the MailKit extension target where possible.
- Use dependency injection so MailKit-specific code remains thin.
