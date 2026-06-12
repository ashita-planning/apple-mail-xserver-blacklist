# AGENT.md

## Project mission

Build a macOS solution that allows users to register unwanted email senders into XServer blacklists directly from Apple Mail.

## Technology stack

- Swift
- SwiftUI
- MailKit
- macOS 15+
- Xcode

## Architecture rules

- Shared business logic belongs in Shared/.
- UI belongs in App/.
- Apple Mail integration belongs in MailExtension/.
- Avoid duplicating models between targets.
- Prefer protocol-based dependency injection.

## Security rules

- Never hardcode API keys.
- Never commit secrets.
- Use Keychain for credential storage.
- Redact secrets in logs.

## XServer requirements

The system must support multiple independent XServer configurations.

Do not assume:
- One API key.
- One mail domain.
- One server.

Always model configuration ownership explicitly.

## Coding standards

- Favor small testable components.
- Prefer async/await.
- Avoid force unwraps.
- Keep UI and networking separated.
- Use SwiftLint-compatible style when possible.

## Before completing a task

Verify:

1. Project builds.
2. Tests pass.
3. No secrets are introduced.
4. Public APIs are documented.
5. New models support multi-account operation.

## Suggested implementation order

1. Shared domain models.
2. Keychain credential storage.
3. XServer client abstraction.
4. Mailbox-to-configuration matching.
5. Companion app settings UI.
6. MailKit integration.
7. Diagnostics and history.

## Definition of done

A task is complete only when:

- Code compiles.
- Tests pass.
- Documentation is updated if behavior changes.
- Multi-account support remains intact.
