# Data Model

## Purpose

This document defines the initial data model for the Apple Mail XServer Blacklist project.

The model must support multiple mailboxes, multiple XServer configurations, and multiple API credentials.

## Design Principles

- Do not assume a single global XServer account.
- Do not assume a single API key.
- Do not store secrets in SwiftData, UserDefaults, or plain files.
- Use stable identifiers for relationships.
- Keep MailKit-specific objects out of persistent models.

## Entity Relationship

```text
XServerConfiguration
    │ 1
    │
    ├── many ManagedMailbox
    │
    ├── many BlacklistOperation
    │
    └── 1 CredentialReference
```

## XServerConfiguration

Represents one XServer connection target.

```swift
struct XServerConfiguration: Identifiable, Codable, Hashable {
    var id: UUID
    var displayName: String
    var serverIdentifier: String
    var connectionType: XServerConnectionType
    var credentialReference: CredentialReference
    var isEnabled: Bool
    var createdAt: Date
    var updatedAt: Date
}
```

### Fields

| Field | Description |
| --- | --- |
| `id` | Local stable identifier |
| `displayName` | User-facing name |
| `serverIdentifier` | XServer server/account identifier |
| `connectionType` | API, CLI, or MCP |
| `credentialReference` | Pointer to Keychain credential |
| `isEnabled` | Whether this configuration is active |
| `createdAt` | Creation date |
| `updatedAt` | Last update date |

## XServerConnectionType

```swift
enum XServerConnectionType: String, Codable, CaseIterable {
    case api
    case cli
    case mcp
}
```

MVP should implement `api` first.

## CredentialReference

Stores only a reference to a secret, not the secret itself.

```swift
struct CredentialReference: Codable, Hashable {
    var keychainService: String
    var keychainAccount: String
}
```

Example:

```text
service: jp.ashita-planning.apple-mail-xserver-blacklist.xserver-api-key
account: <configuration-id>
```

## ManagedMailbox

Represents a mailbox or email address managed by an XServer configuration.

```swift
struct ManagedMailbox: Identifiable, Codable, Hashable {
    var id: UUID
    var emailAddress: String
    var domain: String
    var configurationId: UUID
    var defaultBlockPolicy: BlacklistEntryType
    var isEnabled: Bool
    var createdAt: Date
    var updatedAt: Date
}
```

### Matching Rules

Priority order:

1. Exact mailbox address match.
2. Domain match.
3. No match.

If multiple matches are found, exact email address match wins.

## BlacklistEntryType

```swift
enum BlacklistEntryType: String, Codable, CaseIterable {
    case emailAddress
    case domain
}
```

## BlacklistOperation

Represents a local history record for a blacklist request.

```swift
struct BlacklistOperation: Identifiable, Codable, Hashable {
    var id: UUID
    var configurationId: UUID
    var mailboxId: UUID?
    var sourceMessageId: String?
    var senderAddress: String
    var entryValue: String
    var entryType: BlacklistEntryType
    var status: BlacklistOperationStatus
    var errorMessage: String?
    var createdAt: Date
    var completedAt: Date?
}
```

### Notes

- `sourceMessageId` should be optional and should not contain full message content.
- `senderAddress` is stored for audit/history.
- `entryValue` is either the full sender email address or domain.

## BlacklistOperationStatus

```swift
enum BlacklistOperationStatus: String, Codable, CaseIterable {
    case pending
    case succeeded
    case failed
    case cancelled
}
```

## SenderCandidate

Temporary non-persistent value extracted from Apple Mail.

```swift
struct SenderCandidate: Codable, Hashable {
    var displayName: String?
    var emailAddress: String
    var domain: String
}
```

This should not be persisted unless a blacklist operation is created.

## Repositories

### ConfigurationRepository

```swift
protocol ConfigurationRepository {
    func listConfigurations() async throws -> [XServerConfiguration]
    func saveConfiguration(_ configuration: XServerConfiguration) async throws
    func deleteConfiguration(id: UUID) async throws
}
```

### MailboxRepository

```swift
protocol MailboxRepository {
    func listManagedMailboxes() async throws -> [ManagedMailbox]
    func saveManagedMailbox(_ mailbox: ManagedMailbox) async throws
    func findConfiguration(for emailAddress: String) async throws -> XServerConfiguration?
}
```

### OperationHistoryRepository

```swift
protocol OperationHistoryRepository {
    func saveOperation(_ operation: BlacklistOperation) async throws
    func listRecentOperations(limit: Int) async throws -> [BlacklistOperation]
}
```

## Persistence Recommendation

Use SwiftData for local non-secret state.

Persist:

- XServer configurations
- Managed mailbox mappings
- Blacklist operation history

Do not persist:

- API keys
- OAuth tokens
- Mail message bodies
- Raw MIME content

## Validation Rules

- Email address must be syntactically valid.
- Domain must be normalized to lowercase.
- Duplicate mailbox mappings should be prevented.
- Disabled configurations must not be selected for new blacklist operations.
- Credential references must resolve before executing XServer requests.

## Test Cases

- Exact mailbox match returns the expected configuration.
- Domain match works when exact mailbox is absent.
- Exact mailbox match wins over domain match.
- Disabled configuration is ignored.
- API key values never appear in serialized model output.
