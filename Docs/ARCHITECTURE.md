# Architecture

## Overview

The solution consists of three primary components:

```text
Apple Mail
    │
    ▼
MailKit Extension
    │
    ▼
Companion macOS App
    │
    ▼
Shared Framework
    │
    ▼
XServer API / CLI / MCP
```

The MailKit extension provides the user interaction inside Apple Mail.
The companion application owns configuration, credentials, diagnostics, and communication with XServer services.

## Modules

### MailExtension

Responsibilities:

- Receive user actions from Apple Mail.
- Extract sender email address and domain.
- Request blacklist operations.
- Display success or failure status.

Must not:

- Store credentials.
- Contain business rules duplicated elsewhere.

### Companion App

Responsibilities:

- Manage XServer configurations.
- Store and retrieve credentials.
- Execute blacklist operations.
- Maintain operation history.
- Provide diagnostics.

### Shared Framework

Responsibilities:

- Domain models.
- Validation.
- Matching logic.
- Client protocols.
- Repository layer.

## MVVM Structure

```text
View
  ↓
ViewModel
  ↓
Repository
  ↓
Client
  ↓
XServer
```

Views never communicate directly with API clients.

## Data Model

### XServerConfiguration

```text
id
name
connectionType
credentialReference
managedMailboxes[]
```

### ManagedMailbox

```text
id
emailAddress
domain
configurationId
```

### BlacklistEntry

```text
id
value
entryType
createdAt
configurationId
```

## Credential Storage

Secrets are stored in macOS Keychain.

```text
Configuration
      │
      ▼
Credential Reference
      │
      ▼
Keychain Item
```

No API key should be stored in UserDefaults.

## Mailbox Matching

A key architectural requirement is support for multiple XServer environments.

```text
Incoming Mailbox
      │
      ▼
Mailbox Matcher
      │
      ├─ Configuration A
      ├─ Configuration B
      └─ Configuration C
```

The matcher determines which XServer credentials should be used for the selected mailbox.

## XServer Client Abstraction

```swift
protocol XServerClient {
    func addToBlacklist(address: String) async throws
}
```

Implementations:

```text
XServerAPIClient
XServerCLIClient
XServerMCPClient
```

The application should depend on the protocol rather than concrete implementations.

## Persistence

Local persistence should store:

- Configurations
- Mailbox mappings
- History records

Suggested technology:

- SwiftData

Credentials remain in Keychain.

## Future Extensions

- Bulk blacklist operations
- Domain blacklist support
- Synchronization of blacklist status
- Audit logging
- Enterprise configuration deployment
