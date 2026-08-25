# `AndroidSSLHelper._initialize` Function

```mermaid
flowchart TD
  Start["_initialize(dependencies)"] --> Guard{"_initialized == true<br/>and _certPath != null?"}
  Guard -- yes --> Cached["return _certPath!"]
  Guard -- no --> Try["enter try"]
  Try --> GetTemp["await dependencies.temporaryDirectory()"]
  GetTemp --> Target["certFile = File(temp.path + /cacert.pem)"]
  Target --> Load["await dependencies.loadCertificateAsset()"]
  Load --> Write["await dependencies.writeCertificate(certFile, certData)"]
  Write --> Path["_certPath = certFile.path"]
  Path --> Flag["_initialized = true"]
  Flag --> Return["return _certPath!"]
  GetTemp -->|exception| Catch["stderr.write bounded marker"]
  Load -->|exception| Catch
  Write -->|exception| Catch
  Catch --> NoCommit["success fields not assigned<br/>by this attempt"]
  NoCommit --> Rethrow["rethrow original error"]
```

🟢 The commit occurs only after the writer Future completes. 🟡 A throwing writer can leave an untracked partial file. 🔴 No in-flight operation serializes concurrent first calls.
