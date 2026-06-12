# XServer API Integration

## Purpose

This document defines how the application should integrate with XServer for blacklist management.

The MVP should prefer the official XServer API. CLI and MCP integrations are future-compatible alternatives behind the same client abstraction.

## Integration Modes

```text
XServerClient
    ├── XServerAPIClient
    ├── XServerCLIClient
    └── XServerMCPClient
```

The UI and business logic should depend on `XServerClient`, not a concrete implementation.

## Client Protocol

```swift
protocol XServerClient {
    func addToBlacklist(_ request: AddBlacklistRequest) async throws -> AddBlacklistResponse
}
```

Future methods may include:

```swift
func removeFromBlacklist(_ request: RemoveBlacklistRequest) async throws -> RemoveBlacklistResponse
func listBlacklistEntries(_ request: ListBlacklistRequest) async throws -> ListBlacklistResponse
```

## Request Model

```swift
struct AddBlacklistRequest: Codable, Hashable {
    var configurationId: UUID
    var targetMailbox: String
    var entryValue: String
    var entryType: BlacklistEntryType
}
```

### Field Notes

| Field | Description |
| --- | --- |
| `configurationId` | Local XServer configuration to use |
| `targetMailbox` | Mailbox whose blacklist should be updated |
| `entryValue` | Email address or domain to block |
| `entryType` | `emailAddress` or `domain` |

## Response Model

```swift
struct AddBlacklistResponse: Codable, Hashable {
    var requestId: String?
    var status: XServerAPIResultStatus
    var message: String?
}
```

```swift
enum XServerAPIResultStatus: String, Codable {
    case succeeded
    case alreadyExists
    case failed
}
```

## Authentication

Authentication material must be loaded through a credential provider.

```swift
protocol XServerCredentialProvider {
    func credential(for reference: CredentialReference) async throws -> XServerCredential
}
```

```swift
struct XServerCredential: Sendable {
    var apiKey: String
}
```

Rules:

- API keys must be stored in Keychain.
- API keys must never be logged.
- API keys must never be stored in SwiftData.
- API keys must be injected into the client at runtime.

## Client Construction

```swift
struct XServerAPIClient: XServerClient {
    let configuration: XServerConfiguration
    let credentialProvider: XServerCredentialProvider
    let httpClient: HTTPClient
}
```

This allows unit tests to inject a mock HTTP client.

## HTTP Abstraction

```swift
protocol HTTPClient {
    func send(_ request: URLRequest) async throws -> HTTPResponse
}
```

```swift
struct HTTPResponse {
    var statusCode: Int
    var data: Data
    var headers: [String: String]
}
```

## Error Handling

```swift
enum XServerClientError: Error, Equatable {
    case missingCredential
    case invalidRequest(String)
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(statusCode: Int)
    case decodingFailed
    case networkFailed(String)
    case unknown(String)
}
```

## Expected Status Handling

| Status | App Handling |
| --- | --- |
| 200 / 201 | Mark operation succeeded |
| 400 | Show validation error |
| 401 | Ask user to recheck API key |
| 403 | Show permission error |
| 404 | Show target mailbox/server not found |
| 409 | Treat as already exists if API indicates duplicate |
| 429 | Show rate-limit message |
| 500+ | Show server error and allow retry |

## Blacklist Operation Flow

```text
SenderCandidate
    ↓
MailboxMatcher
    ↓
XServerConfiguration
    ↓
CredentialProvider
    ↓
XServerClient
    ↓
OperationHistoryRepository
```

## Idempotency

Adding the same blacklist entry multiple times should not create a bad user experience.

If XServer reports that an entry already exists, the app should show a successful or neutral result:

```text
Already blocked
```

and record the operation as `succeeded` or `alreadyExists` depending on the local status model.

## Logging

Allowed:

- Configuration ID
- Target mailbox
- Entry type
- Redacted entry value when necessary
- HTTP status code
- Error category

Not allowed:

- API keys
- Raw authorization headers
- Full email body
- Raw MIME source

## Retry Policy

MVP should avoid automatic aggressive retries.

Suggested policy:

- Retry once for transient network failure.
- Do not retry 400/401/403 validation or auth errors.
- Allow manual retry from operation history.

## Test Strategy

Unit tests should cover:

- Successful add blacklist request.
- Unauthorized response.
- Duplicate/already-exists response.
- Network error.
- Credential missing.
- Request body does not include unrelated mailbox data.
- API key is not included in logs or serialized models.

## Open Items

The exact XServer endpoint paths, request body, and response schema should be filled in after validating the official XServer API documentation and/or CLI behavior.

Until then, implementation should keep endpoint construction isolated in `XServerAPIEndpoint` or a similar type.
