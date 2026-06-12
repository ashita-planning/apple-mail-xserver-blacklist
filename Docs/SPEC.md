# Product Specification

## Project

XServer Mail Blacklist is a macOS companion app and Apple Mail extension that allows users to add unwanted senders to XServer mail blacklists from Apple Mail.

## Goals

- Provide a simple action from Apple Mail to block a sender email address or sender domain.
- Support multiple email addresses, mail servers, XServer accounts, and API credentials.
- Keep credentials out of source code and store them securely on the user device.
- Provide a companion macOS app for account setup, blacklist review, and diagnostics.

## Non-goals

- Building a general-purpose spam filter.
- Replacing XServer's existing mail filtering features.
- Sending email content to third-party services.
- Storing message bodies unless explicitly needed for local diagnostics.

## Core user flows

### 1. Initial setup

1. User opens the companion macOS app.
2. User adds one or more XServer configurations.
3. For each configuration, user registers:
   - Display name
   - XServer account/server identifier
   - Target email addresses or domains managed by that configuration
   - API key or authentication method
4. App validates connectivity without saving secrets in plain text.
5. Secrets are stored in macOS Keychain.

### 2. Block sender from Apple Mail

1. User selects an email in Apple Mail.
2. User invokes the Mail extension action.
3. Extension extracts sender address and sender domain.
4. Extension resolves which XServer configuration applies to the target mailbox/account.
5. User confirms whether to block:
   - Sender email address only
   - Sender domain
6. App sends the blacklist update request to XServer.
7. User receives success or error feedback.

### 3. Manage blacklist history

1. User opens the companion app.
2. User reviews recently added blacklist entries.
3. User can see:
   - Sender address/domain
   - Target mailbox/server configuration
   - Date added
   - Result status
4. Future version may support removal if XServer API/CLI supports it reliably.

## Configuration model

The app must support this relationship:

```text
XServerConfiguration
├─ id
├─ displayName
├─ serverIdentifier
├─ authCredentialReference
├─ managedMailboxes[]
└─ apiMode: api | cli | mcp

ManagedMailbox
├─ emailAddress
├─ domain
├─ xserverConfigurationId
└─ blacklistTargetPolicy
```

Important rule: do not assume one global API key. Each email address or mail server may require a different XServer API key or credential.

## Security requirements

- Never hardcode API keys.
- Never commit local configuration files containing credentials.
- Store secrets in Keychain.
- Redact secrets from logs.
- Avoid logging full email message bodies.
- Prefer dependency injection for clients so tests can use mocks.

## Suggested app modules

```text
App/
  macOS companion app, settings, diagnostics, history

MailExtension/
  Apple Mail extension entry points and selected-message handling

Shared/
  domain models, credential references, XServer client protocols, validation

Tests/
  unit tests for matching, validation, and API client behavior

Docs/
  product and development documentation

Scripts/
  build/test helper scripts for AI agents and CI
```

## MVP scope

- Companion app can register multiple XServer configurations.
- Credentials are stored in Keychain.
- Sender email address can be extracted from selected message.
- User can add sender address to the matching XServer blacklist.
- Matching logic supports multiple mailbox/server/API-key combinations.
- Basic success/failure result is shown to the user.

## Later scope

- Domain-level blocking.
- Blacklist removal.
- Bulk block selected messages.
- Import/export local configuration without secrets.
- XServer CLI/MCP fallback mode.
- CI workflow for build and tests.
