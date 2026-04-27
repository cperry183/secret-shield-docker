.PHONY: help build push scan scan-verbose clean lint test

# Configuration
DOCKER_IMAGE ?= secret-shield
DOCKER_TAG ?= latest
REGISTRY ?= docker.io
FULL_IMAGE := $(REGISTRY)/$(DOCKER_IMAGE):$(DOCKER_TAG)
SCAN_PATH ?= .
REPORT_FORMAT ?= json
REPORT_PATH ?= ./gitleaks-report.json

help:
	@echo "Secret Shield Docker - Makefile Commands"
	@echo ""
	@echo "Available targets:"
	@echo "  build              Build the Docker image"
	@echo "  push               Push the Docker image to registry"
	@echo "  scan               Run a secret scan on current directory"
	@echo "  scan-verbose       Run a secret scan with verbose output"
	@echo "  scan-path          Scan a specific path (SCAN_PATH=/path/to/scan)"
	@echo "  clean              Remove generated files and reports"
	@echo "  lint               Lint Dockerfile and shell scripts"
	@echo "  test               Run basic tests"
	@echo "  help               Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
	@echo "  make scan SCAN_PATH=/path/to/repo"
	@echo "  make scan-verbose REPORT_PATH=/tmp/report.json"
	@echo "  make push REGISTRY=ghcr.io DOCKER_IMAGE=myorg/secret-shield"

build:
	@echo "Building Docker image: $(FULL_IMAGE)"
	docker build -t $(FULL_IMAGE) \
		--build-arg GITLEAKS_VERSION=v8.24.2 \
		-f docker/Dockerfile \
		.
	@echo "✓ Image built successfully"

push: build
	@echo "Pushing Docker image to registry..."
	docker push $(FULL_IMAGE)
	@echo "✓ Image pushed successfully"

scan:
	@echo "Running secret scan on: $(SCAN_PATH)"
	@mkdir -p $(dir $(REPORT_PATH))
	docker run --rm \
		-v $(SCAN_PATH):/scan \
		-v $(shell pwd)/docker/.gitleaks.toml:/app/.gitleaks.toml:ro \
		-v $(shell pwd)/.gitleaksignore:/app/.gitleaksignore:ro \
		-v $(shell pwd)/$(REPORT_PATH):/app/gitleaks-report.json \
		-e SCAN_PATH=/scan \
		-e REPORT_FORMAT=$(REPORT_FORMAT) \
		-e REPORT_PATH=/app/gitleaks-report.json \
		-e EXIT_ON_FINDING=true \
		$(FULL_IMAGE) || true
	@if [ -f "$(REPORT_PATH)" ]; then \
		echo "✓ Report saved to: $(REPORT_PATH)"; \
		echo "Findings summary:"; \
		jq 'length' $(REPORT_PATH) 2>/dev/null || echo "Report generated"; \
	fi

scan-verbose:
	@echo "Running secret scan with verbose output on: $(SCAN_PATH)"
	@mkdir -p $(dir $(REPORT_PATH))
	docker run --rm \
		-v $(SCAN_PATH):/scan \
		-v $(shell pwd)/docker/.gitleaks.toml:/app/.gitleaks.toml:ro \
		-v $(shell pwd)/.gitleaksignore:/app/.gitleaksignore:ro \
		-v $(shell pwd)/$(REPORT_PATH):/app/gitleaks-report.json \
		-e SCAN_PATH=/scan \
		-e REPORT_FORMAT=$(REPORT_FORMAT) \
		-e REPORT_PATH=/app/gitleaks-report.json \
		-e EXIT_ON_FINDING=true \
		-e VERBOSE=true \
		$(FULL_IMAGE) || true
	@if [ -f "$(REPORT_PATH)" ]; then \
		echo "✓ Report saved to: $(REPORT_PATH)"; \
	fi

scan-path:
	@if [ -z "$(SCAN_PATH)" ] || [ "$(SCAN_PATH)" = "." ]; then \
		echo "Error: Please specify SCAN_PATH"; \
		echo "Usage: make scan-path SCAN_PATH=/path/to/scan"; \
		exit 1; \
	fi
	@$(MAKE) scan SCAN_PATH=$(SCAN_PATH)

clean:
	@echo "Cleaning up generated files..."
	rm -f gitleaks-report.json
	rm -f gitleaks-report.csv
	rm -f gitleaks-report.sarif
	rm -f gitleaks-report.junit.xml
	rm -rf reports/
	@echo "✓ Cleanup complete"

lint:
	@echo "Linting Dockerfile..."
	@if command -v hadolint &> /dev/null; then \
		hadolint docker/Dockerfile; \
	else \
		echo "Warning: hadolint not installed, skipping Dockerfile lint"; \
	fi
	@echo "Linting shell scripts..."
	@if command -v shellcheck &> /dev/null; then \
		shellcheck docker/entrypoint.sh scripts/scan.sh; \
	else \
		echo "Warning: shellcheck not installed, skipping shell script lint"; \
	fi
	@echo "✓ Linting complete"

test: build
	@echo "Running basic tests..."
	@echo "Test 1: Verify gitleaks is installed in container"
	docker run --rm $(FULL_IMAGE) gitleaks version
	@echo "✓ Test 1 passed"
	@echo "Test 2: Verify entrypoint script exists"
	docker run --rm $(FULL_IMAGE) which entrypoint.sh
	@echo "✓ Test 2 passed"
	@echo "✓ All tests passed"

.DEFAULT_GOAL := help
