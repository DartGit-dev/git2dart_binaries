# Android TLS Evidence Boundaries

```mermaid
flowchart LR
  Source["🟢 Current source<br/>state ordering and default wiring"] --> Host["🟢 Host Flutter tests<br/>injected success/cache/failure/retry"]
  Host -. "does not imply" .-> Device["🔴 Android device<br/>rootBundle + path_provider + file"]
  Source --> Plan["🟡 Asset declaration and<br/>documented managed-runtime order"]
  Plan -. "requires execution" .-> Consumer["🔴 External consumer<br/>initialize → extract → apply option"]
  Consumer -. "requires network behavior" .-> HTTPS["🔴 Android HTTPS operation"]
  Host -. "local only" .-> Hosted["🔴 Hosted same-run /<br/>cross-platform provenance"]
```

The evidence chain is intentionally non-transitive: definitions, asset declarations, and local injected tests do not establish device execution, external application of the path, HTTPS success, or hosted provenance.
