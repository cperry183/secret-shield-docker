# 🛡️ Secret Shield Docker

[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/cperry183/secret-shield-docker?label=Docker%20Image%20Size)](https://hub.docker.com/r/cperry183/secret-shield-docker/tags)
[![Gitleaks Version](https://img.shields.io/badge/Gitleaks-v8.24.2-blue)](https://github.com/gitleaks/gitleaks)
[![License](https://img.shields.io/github/license/cperry183/secret-shield-docker)](LICENSE)

**A robust, containerized secret scanning solution using Gitleaks for detecting hardcoded secrets, API keys, tokens, and other sensitive data in your code repositories.**

## 📖 Overview

Secret Shield Docker provides a production-ready, containerized approach to secret scanning using [Gitleaks](https://github.com/gitleaks/gitleaks), a powerful SAST (Static Application Security Testing) tool designed to detect secrets in git repositories. By encapsulating Gitleaks within a lightweight Docker image, Secret Shield ensures **consistent, reproducible secret scanning** across your entire organization without requiring local tool installations or managing complex dependencies. This solution is ideal for **DevSecOps teams** and **security-conscious organizations** aiming to implement **shift-left security** practices, integrating automated secret detection seamlessly into CI/CD pipelines like GitHub Actions, GitLab CI/CD, and Jenkins.

## ✨ Key Features

| Feature | Description | Benefit |
| :-- | :-- | :-- |
| 🐳 **Container-First Architecture** | All scanning logic and dependencies are encapsulated in a lightweight Docker image. | Ensures consistent and reproducible scans across diverse environments, eliminating 
dependency conflicts and simplifying deployment. |
| 🔍 **Comprehensive Secret Detection** | Detects AWS keys, GitHub tokens, Slack webhooks, database credentials, private keys, API keys, and 100+ other secret patterns out of the box using Gitleaks' extensive rule set. | Proactively identifies a wide array of sensitive data, significantly reducing the risk of accidental exposure and enhancing overall security posture. |
| ⚙️ **Highly Customizable** | Extend or modify detection rules using TOML configuration files (`.gitleaks.toml`) to match your organization's specific security requirements and integrate custom patterns. | Provides flexibility to adapt the scanning process to unique project needs, allowing for precise control over what constitutes a secret within your codebase. |
| 📊 **Multiple Report Formats** | Generate reports in JSON, CSV, SARIF, and JUnit XML formats for integration with security dashboards, compliance tools, and other automated systems. | Facilitates seamless integration with existing security ecosystems, enabling automated analysis, tracking, and reporting of identified secrets. |
| 🚀 **CI/CD Ready** | Pre-built workflow templates for GitHub Actions and GitLab CI/CD enable quick integration into existing pipelines, automating scans at every commit or pull request. | Shifts security left by embedding secret detection early in the development lifecycle, catching issues before they reach production and reducing remediation costs. |
| 🎯 **False Positive Management** | Utilize `.gitleaksignore` files to exclude known false positives and baseline findings, reducing alert fatigue and allowing teams to focus on genuine threats. | Improves the efficiency of security teams by minimizing noise from irrelevant alerts, ensuring that critical findings receive immediate attention. |
| 📈 **Scalable & Efficient** | Deploy a single container image across hundreds of repositories with parameterized configuration per project, optimizing resource usage. | Supports large-scale deployments and diverse project portfolios, providing a cost-effective and high-performance solution for enterprise-level secret scanning. |
| 🔔 **Actionable Reporting** | Detailed findings include file paths, line numbers, commit information, and fingerprints for easy remediation and historical tracking. | Empowers developers with precise information to quickly locate and fix identified secrets, streamlining the remediation process. |

## 📂 Repository Structure

```
secret-shield-docker/
├── docker/                             # Docker image definition and default Gitleaks configuration
│   ├── Dockerfile                      # Multi-stage build for minimal image size
│   ├── entrypoint.sh                   # Container orchestration script for Gitleaks execution
│   └── .gitleaks.toml                  # Default Gitleaks configuration file with predefined rules
├── scripts/                            # Helper scripts for local development and testing
│   └── scan.sh                         # Convenience script to run local Gitleaks scans
├── github-workflows/                   # GitHub Actions workflow templates for CI/CD integration
│   └── secret-scan.yml                 # Example GitHub Actions workflow for automated secret scanning
├── gitlab-ci/                          # GitLab CI/CD job templates for pipeline integration
│   └── secret-scan.yml                 # Example GitLab CI/CD job for automated secret scanning
├── examples/                           # Comprehensive CI/CD pipeline examples
│   ├── github-actions.yml              # Full GitHub Actions pipeline demonstrating Secret Shield usage
│   └── gitlab-ci.yml                   # Full GitLab CI/CD pipeline demonstrating Secret Shield usage
├── docs/                               # Detailed documentation and guides
│   ├── INSTALLATION.md                 # Step-by-step installation guide
│   ├── CONFIGURATION.md                # In-depth configuration and customization guide
│   └── TROUBLESHOOTING.md              # Common issues and their solutions
├── .gitleaksignore                     # Global baseline file for managing false positives across the repository
├── Makefile                            # Automation script for building, testing, and scanning
├── LICENSE                             # MIT License details
└── README.md                           # Project overview and usage instructions (this file)
```

## 🚀 Quick Start

This section guides you through setting up and running your first secret scan with Secret Shield Docker.

### Prerequisites

Before you begin, ensure you have the following installed on your system:

*   **Docker** (version 20.10 or later): For building and running the containerized scanner.
*   **Docker Compose** (optional): Useful for advanced scenarios and orchestrating multiple services.
*   **Make** (optional): Simplifies common tasks like building and scanning via the provided `Makefile`.
*   **Git**: For cloning the repository and managing your codebase.

### 1. Clone the Repository

Start by cloning the Secret Shield Docker repository to your local machine:

```bash
git clone https://github.com/cperry183/secret-shield-docker.git
cd secret-shield-docker
```

### 2. Build the Docker Image

Build the Secret Shield Docker image. You can use the provided `Makefile` for convenience or build directly with Docker.

**Using Makefile (Recommended):**

```bash
make build
```

**Using Docker directly:**

```bash
docker build -t secret-shield:latest -f docker/Dockerfile .
```

### 3. Run a Local Scan

Execute a secret scan on your current directory or any specified repository. This can be done using the convenience script or by directly invoking Docker.

**Using the `scan.sh` script:**

```bash
chmod +x scripts/scan.sh
./scripts/scan.sh /path/to/your/repository
```

**Using Docker directly:**

```bash
docker run --rm \
  -v /path/to/your/repository:/scan \
  -v $(pwd)/docker/.gitleaks.toml:/app/.gitleaks.toml:ro \
  -v $(pwd)/.gitleaksignore:/app/.gitleaksignore:ro \
  -v $(pwd)/reports:/app/reports \
  -e SCAN_PATH=/scan \
  -e REPORT_FORMAT=json \
  -e REPORT_PATH=/app/reports/gitleaks-report.json \
  secret-shield:latest
```

**Using Makefile:**

```bash
make scan SCAN_PATH=/path/to/your/repository
make scan-verbose SCAN_PATH=/path/to/your/repository
```

### 4. Review the Report

After the scan completes, review the generated report in your chosen format. Reports are typically saved in the `./reports` directory.

```bash
# View JSON report (requires `jq`)
cat reports/gitleaks-report.json | jq "."

# View summary of findings
jq 'length' reports/gitleaks-report.json
```

## 🔧 Configuration

Secret Shield Docker offers extensive configuration options to tailor the scanning process to your needs.

### Environment Variables

Control the scanning behavior and output using the following environment variables:

| Variable | Default | Description |
| :-- | :-- | :-- |
| `SCAN_PATH` | `.` | **Required.** Absolute path inside the container to the directory or repository to be scanned. |
| `CONFIG_PATH` | `/app/.gitleaks.toml` | Path to the Gitleaks configuration file. Mount your custom `.gitleaks.toml` here. |
| `REPORT_FORMAT` | `json` | Output format for the scan report. Supported: `json`, `csv`, `sarif`, `junit`. |
| `REPORT_PATH` | `/app/gitleaks-report.json` | Absolute path inside the container where the scan report will be saved. Ensure this path is volume-mounted. |
| `EXIT_ON_FINDING` | `true` | If `true`, the container exits with a non-zero status code (1) if any secrets are found, suitable for CI/CD gates. |
| `VERBOSE` | `false` | Enable verbose output for detailed logging and debugging purposes. |
| `BASELINE_PATH` | `` | Path to a baseline file (`.gitleaksignore` or a previous report) to ignore known issues in subsequent scans. |

### Customizing Detection Rules

The default configuration (`docker/.gitleaks.toml`) includes a robust set of rules. To define custom detection patterns:

1.  **Copy the default configuration:**

    ```bash
    cp docker/.gitleaks.toml my-custom-config.toml
    ```

2.  **Edit `my-custom-config.toml`** to add, remove, or modify rules. For example, to add a custom regex pattern:

    ```toml
    [[rules]]
    id = "custom-api-key"
    description = "Custom API Key Pattern"
    regex = '''(?i)(api_key|apikey|access_token|auth_token)[\s=:]*["\\]?[0-9a-zA-Z]{32,64}["\\]?'''
    entropy = 3.5
    keywords = ["api", "key", "custom"]
    ```

3.  **Use your custom configuration** during scans by mounting it into the container:

    ```bash
    docker run --rm \
      -v /path/to/your/repository:/scan \
      -v $(pwd)/my-custom-config.toml:/app/.gitleaks.toml:ro \
      secret-shield:latest
    ```

### Managing False Positives

To prevent recurring alerts for known or intentional secrets, use a `.gitleaksignore` file:

1.  **Identify the fingerprint** of the false positive from the scan report.
2.  **Add the fingerprint to your `.gitleaksignore` file.** For example:

    ```bash
    echo "cd5226711335c68be1e720b318b7bc3135a30eb2:cmd/generate/config/rules/sidekiq.go:sidekiq-secret:23" >> .gitleaksignore
    ```

3.  **Re-run the scan.** Gitleaks will now ignore findings matching the specified fingerprint.

## 🔄 CI/CD Integration

Integrate Secret Shield Docker into your Continuous Integration/Continuous Delivery (CI/CD) pipelines to automate secret scanning at every stage of development.

### GitHub Actions

To integrate with GitHub Actions, copy the provided workflow template and commit it to your repository:

```bash
mkdir -p .github/workflows
cp github-workflows/secret-scan.yml .github/workflows/
git add .github/workflows/secret-scan.yml
git commit -m "Add Secret Shield scan workflow"
git push
```

This workflow is configured to automatically run on:

*   Pushes to `main` and `develop` branches.
*   Pull requests targeting `main` and `develop` branches.
*   A daily schedule (e.g., 2 AM UTC).
*   Manual triggers via `workflow_dispatch`.

### GitLab CI/CD

For GitLab CI/CD, include the Secret Shield job in your `.gitlab-ci.yml` file:

```yaml
include:
  - local: 'gitlab-ci/secret-scan.yml'

stages:
  - scan
  - build
  - test

secret-scan:
  extends: .secret_scan
  stage: scan
```

After committing these changes, GitLab will automatically run the secret scan as part of your pipeline.

### Jenkins

To integrate with Jenkins, create a pipeline job and add a stage similar to the following:

```groovy
stage('Secret Scan') {
    steps {
        sh '''
            docker build -t secret-shield:latest -f docker/Dockerfile .
            docker run --rm \
              -v ${WORKSPACE}:/scan \
              -v ${WORKSPACE}/docker/.gitleaks.toml:/app/.gitleaks.toml:ro \
              -v ${WORKSPACE}/.gitleaksignore:/app/.gitleaksignore:ro \
              -v ${WORKSPACE}/reports:/app/reports \
              -e SCAN_PATH=/scan \
              -e REPORT_FORMAT=json \
              -e REPORT_PATH=/app/reports/gitleaks-report.json \
              secret-shield:latest
        '''
    }
}
```

## 📊 Understanding Reports

Secret Shield Docker generates detailed reports to help you understand and remediate identified secrets.

### JSON Report Format

The JSON report provides comprehensive information about each finding, making it suitable for programmatic processing and integration with other tools:

```json
[
  {
    "Description": "AWS Access Key",
    "StartLine": 10,
    "EndLine": 10,
    "StartColumn": 15,
    "EndColumn": 55,
    "Match": "AKIAIOSFODNN7EXAMPLE",
    "Secret": "AKIAIOSFODNN7EXAMPLE",
    "File": "config/secrets.env",
    "Commit": "abc123def456",
    "Entropy": 4.2,
    "Author": "John Doe",
    "Email": "john@example.com",
    "Date": "2024-01-15T10:30:00Z",
    "Message": "Add AWS configuration",
    "Tags": [],
    "RuleID": "aws-access-key",
    "Fingerprint": "abc123def456:config/secrets.env:aws-access-key:10"
  }
]
```

### SARIF Report Format

The SARIF (Static Analysis Results Interchange Format) report is designed for integration with security tools like GitHub Security, allowing for standardized vulnerability reporting:

```bash
docker run --rm \
  -v /path/to/your/repository:/scan \
  -e REPORT_FORMAT=sarif \
  -e REPORT_PATH=/app/gitleaks-report.sarif \
  secret-shield:latest
```

## 🛠️ Advanced Usage

Explore advanced functionalities to optimize your secret scanning workflow.

### Scanning Git History

To perform a comprehensive scan across the entire Git history of a repository, simply mount the repository and run the container. Secret Shield Docker (via Gitleaks) automatically detects Git repositories and scans all commits:

```bash
docker run --rm \
  -v /path/to/your/repository:/scan \
  -e SCAN_PATH=/scan \
  secret-shield:latest
```

### Incremental Scanning

For large repositories, incremental scanning helps to focus on new findings and reduce scan times. This involves generating a baseline and then scanning only for changes against that baseline:

1.  **First scan - create baseline:**

    ```bash
    docker run --rm \
      -v /path/to/your/repository:/scan \
      -e REPORT_PATH=/app/baseline.json \
      secret-shield:latest
    ```

2.  **Subsequent scans - only new findings:**

    ```bash
    docker run --rm \
      -v /path/to/your/repository:/scan \
      -e BASELINE_PATH=/app/baseline.json \
      -e REPORT_PATH=/app/new-findings.json \
      secret-shield:latest
    ```

### Multi-Format Reporting

Generate reports in multiple formats to cater to different tools and reporting requirements:

```bash
# JSON for programmatic processing
docker run --rm \
  -v /path/to/your/repository:/scan \
  -e REPORT_FORMAT=json \
  -e REPORT_PATH=/app/report.json \
  secret-shield:latest

# SARIF for GitHub Security
docker run --rm \
  -v /path/to/your/repository:/scan \
  -e REPORT_FORMAT=sarif \
  -e REPORT_PATH=/app/report.sarif \
  secret-shield:latest
```

## 🤝 Contributing

We welcome contributions to Secret Shield Docker! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to submit pull requests, report bugs, and suggest new features.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ❓ Troubleshooting

Encountering issues? Check our [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) guide for common problems 
