## [1.15.0](https://github.com/munimtechnologies/munim-pencilkit/compare/v1.14.1...v1.15.0) (2026-09-19)

### ✨ Features

* add stroke access, async API, content versions, and iOS 18 tool items ([c787130](https://github.com/munimtechnologies/munim-pencilkit/commit/c787130eb19520f03dca5d28914b9a189a7e7e37))

### 🐛 Bug Fixes

* compile the iOS 26 ink and stroke-threshold paths only with the iOS 26 SDK ([d26d8b6](https://github.com/munimtechnologies/munim-pencilkit/commit/d26d8b6f5e2f21e01de62b78e013f220772e2276)), closes [#available](https://github.com/munimtechnologies/munim-pencilkit/issues/available) [#if](https://github.com/munimtechnologies/munim-pencilkit/issues/if)
* import NitroModules for Promise and avoid window-less screen and responder lookups ([053a7ca](https://github.com/munimtechnologies/munim-pencilkit/commit/053a7caa3b47a7070b56563590eb5e07aadf84ea))
* make the ink type switch exhaustive ([47ba01e](https://github.com/munimtechnologies/munim-pencilkit/commit/47ba01e24b6855b431fb82206e2e1ad743fd1933))

### 📚 Documentation

* document strokes, async API, content versions, and tool picker focus ([49a1a72](https://github.com/munimtechnologies/munim-pencilkit/commit/49a1a72d1613eae624094c96f1b07cab787cd0c4))

### 🛠️ Other changes

* **example:** add stroke, tool item, and focus demos ([3d2e2f3](https://github.com/munimtechnologies/munim-pencilkit/commit/3d2e2f389f9396db08441010dfa935d60232d313))
* **example:** adopt the UIScene lifecycle ([4d56827](https://github.com/munimtechnologies/munim-pencilkit/commit/4d568275ee7e27628fb03a368449f89d15666270))
* **example:** upgrade React Native to 0.86.3 ([94552a9](https://github.com/munimtechnologies/munim-pencilkit/commit/94552a9e2266d689d55174150658deb9f3a61691))
* silence never-mutated warning in StylusDrawingView ([6e12c0e](https://github.com/munimtechnologies/munim-pencilkit/commit/6e12c0e8f1d3bdf9287bafea31f1ace5d86df90a))
* sync package-lock with the release ([6953057](https://github.com/munimtechnologies/munim-pencilkit/commit/69530571e2f7f809343128f6317275aa94c8686d))

## [1.14.1](https://github.com/munimtechnologies/munim-pencilkit/compare/v1.14.0...v1.14.1) (2026-09-14)

### 🛠️ Other changes

* **deps:** patch js-yaml and joi Dependabot alerts ([193e3fb](https://github.com/munimtechnologies/munim-pencilkit/commit/193e3fb9e257f713ac3c0669a32ab1b9ad2c9e27))
* **deps:** update browserslist to 4.28.9 for GHSA-c83g-rgw3-j3cx and GHSA-73wf-gq98-2v4g ([d0b8472](https://github.com/munimtechnologies/munim-pencilkit/commit/d0b84728116b59a6510ba1e5aaa02d62c4b766ba))
* sync package-lock with the release ([ad1685d](https://github.com/munimtechnologies/munim-pencilkit/commit/ad1685d40e0de00f6fd41fd1d4ed928a34b6b609))

## [1.14.0](https://github.com/munimtechnologies/munim-pencilkit/compare/v1.13.2...v1.14.0) (2026-09-05)

### ✨ Features

* **ios:** add scrollEnabled config and support the iOS 26 reed ink ([73aa00c](https://github.com/munimtechnologies/munim-pencilkit/commit/73aa00c3bc8a8502ed4024a85ce56ec9e0c0e6f6))

### 🐛 Bug Fixes

* **deps:** resolve Dependabot alerts in dev/example dependencies ([a77f516](https://github.com/munimtechnologies/munim-pencilkit/commit/a77f516e2db755c6eea02c1e1dd8bd817d3b1480))

### 🛠️ Other changes

* sync package-lock version ([911a9c2](https://github.com/munimtechnologies/munim-pencilkit/commit/911a9c21ff3294d814cd6dedb7b0ce74a02f214f))
* upgrade Nitro to 0.36.5 and fix repository metadata ([7afc807](https://github.com/munimtechnologies/munim-pencilkit/commit/7afc807cb9b9ba8176dd3f90062f6331c2aeda2e)), closes [margelo/nitro#1573](https://github.com/margelo/nitro/issues/1573)

## [1.13.2](https://github.com/munimtechnologies/munim-pencilkit/compare/v1.13.1...v1.13.2) (2026-08-15)

### 🛠️ Other changes

* switch license from MIT to Apache-2.0 ([c212bd6](https://github.com/munimtechnologies/munim-pencilkit/commit/c212bd655732cea8841b74495d07e5c8cd726dc5))

## [1.13.1](https://github.com/munimtechnologies/munim-pencilkit/compare/v1.13.0...v1.13.1) (2026-08-12)

### 🐛 Bug Fixes

* make PKCanvasView transparent so paper templates behind the canvas stay visible ([68ffecb](https://github.com/munimtechnologies/munim-pencilkit/commit/68ffecb07a58ce26e1242f3536283373fdba5d86))

### 🛠️ Other changes

* sync package-lock version ([309e083](https://github.com/munimtechnologies/munim-pencilkit/commit/309e083269529a0565a68f1a10504e69b61284bf))

## [1.13.0](https://github.com/munimtechnologies/munim-pencilkit/compare/v1.12.34...v1.13.0) (2026-08-12)

### ✨ Features

* document export/import, tool selection and picker control, drawing event overhaul, and custom stylus undo/redo ([1472d33](https://github.com/munimtechnologies/munim-pencilkit/commit/1472d333c328f02a50ccb430e6c961bb5aa677bb))

### 🐛 Bug Fixes

* point repository at munimtechnologies org ([ca4511c](https://github.com/munimtechnologies/munim-pencilkit/commit/ca4511c7366a983dddf6fa5c332c0dc642654684))

### 🛠️ Other changes

* drop GitHub Actions; release locally via release:local ([a33a8ac](https://github.com/munimtechnologies/munim-pencilkit/commit/a33a8acb2a7bb76e2d6b76b648ede80e536d03da))
* **release:** 1.13.0 [skip ci] ([94cdef9](https://github.com/munimtechnologies/munim-pencilkit/commit/94cdef9d21275a3dd9f3a72a89426bd0c577d3f1))
* **release:** 1.13.1 [skip ci] ([a3eaf2c](https://github.com/munimtechnologies/munim-pencilkit/commit/a3eaf2ca1fa18f37114ce8a34c382668b438609d))
* restore GitHub Actions workflows ([b86a9af](https://github.com/munimtechnologies/munim-pencilkit/commit/b86a9afac0c290ba66a06ee01018b4ac5156ade8))

## [1.13.1](https://github.com/munimtechnologies/munim-pencilkit/compare/v1.13.0...v1.13.1) (2026-08-12)

### 🛠️ Other changes

* restore GitHub Actions workflows ([b86a9af](https://github.com/munimtechnologies/munim-pencilkit/commit/b86a9afac0c290ba66a06ee01018b4ac5156ade8))

## [1.13.0](https://github.com/munimtechnologies/munim-pencilkit/compare/v1.12.34...v1.13.0) (2026-08-12)

### ✨ Features

* document export/import, tool selection and picker control, drawing event overhaul, and custom stylus undo/redo ([1472d33](https://github.com/munimtechnologies/munim-pencilkit/commit/1472d333c328f02a50ccb430e6c961bb5aa677bb))

### 🐛 Bug Fixes

* point repository at munimtechnologies org ([ca4511c](https://github.com/munimtechnologies/munim-pencilkit/commit/ca4511c7366a983dddf6fa5c332c0dc642654684))

### 🛠️ Other changes

* drop GitHub Actions; release locally via release:local ([a33a8ac](https://github.com/munimtechnologies/munim-pencilkit/commit/a33a8acb2a7bb76e2d6b76b648ede80e536d03da))
