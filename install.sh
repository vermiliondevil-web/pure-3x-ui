name: Build and Release

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:
    inputs:
      tag:
        description: 'Tag to build (e.g. v1.0.2)'
        required: true
        default: 'v1.0.2'

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version-file: go.mod

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Build frontend
        run: |
          cd frontend
          npm ci
          npm run build
          cd ..

      - name: Build Go binary
        run: |
          CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -ldflags "-w -s" -o x-ui main.go

      - name: Download Xray core
        run: |
          mkdir -p x-ui-package/bin
          wget -q -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
          unzip -q xray.zip -d x-ui-package/bin/
          rm xray.zip

      - name: Package release tarball
        run: |
          cp x-ui x-ui-package/x-ui
          cp x-ui.sh x-ui-package/x-ui.sh
          cp x-ui.service.debian x-ui-package/ 2>/dev/null || true
          cp x-ui.service.arch   x-ui-package/ 2>/dev/null || true
          cp x-ui.service.rhel   x-ui-package/ 2>/dev/null || true
          cp x-ui.rc             x-ui-package/ 2>/dev/null || true
          chmod +x x-ui-package/x-ui x-ui-package/x-ui.sh
          chmod +x x-ui-package/bin/*
          tar -czvf x-ui-linux-amd64.tar.gz -C x-ui-package .
          sha256sum x-ui-linux-amd64.tar.gz > x-ui-linux-amd64.tar.gz.sha256

      - name: Create release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ github.event.inputs.tag || github.ref_name }}
          files: |
            x-ui-linux-amd64.tar.gz
            x-ui-linux-amd64.tar.gz.sha256
