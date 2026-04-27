# 🛡️ Secret Shield Docker

**A robust, containerized secret scanning solution using Gitleaks for detecting hardcoded secrets, API keys, tokens, and other sensitive data in your code repositories.**

## 📖 Overview

Secret Shield Docker provides a production-ready, containerized approach to secret scanning using [Gitleaks](https://github.com/gitleaks/gitleaks), a powerful SAST (Static Application Security Testing) tool designed to detect secrets in git repositories. By containerizing Gitleaks, Secret Shield enables consistent, reproducible secret scanning across your entire organization without requiring local tool installations.

The solution is designed for **DevSecOps teams** and **security-conscious organizations** that want to implement **shift-left security** practices. It integrates seamlessly with popular CI/CD platforms including GitHub Actions, GitLab CI/CD, and Jenkins, enabling automated secret detection at every stage of the development pipeline.

### ✨ Key Features

| Feature | Description |
| :-- | :-- |
| 🐳 **Container-First Architecture** | All scanning logic and dependencies are encapsulated in a lightweight Docker image, ensuring consistency across all environments. |
| 🔍 **Comprehensive Secret Detection** | Detects AWS keys, GitHub tokens, Slack webhooks, database credentials, private keys, API keys, and 100+ other secret patterns out of the box. |
| ⚙️ **Highly Customizable** | Extend or modify detection rules using TOML configuration files to match your organization's specific security requirements. |
| 📊 **Multiple Report Formats** | Generate reports in JSON, CSV, SARIF, and JUnit XML formats for integration with security dashboards and compliance tools. |
| 🚀 **CI/CD Ready** | Pre-built workflow templates for GitHub Actions and GitLab CI/CD enable quick integration into existing pipelines. |
| 🎯 **False Positive Management** | Use `.gitleaksignore` files to exclude known false positives and baseline findings, reducing alert fatigue. |
| 📈 **Scalable** | Deploy a single container image across hundreds of repositories with parameterized configuration per project. |
| 🔔 **Actionable Reporting** | Detailed findings include file paths, line numbers, commit information, and fingerprints for easy remediation. |

## 📂 Repository Structure

```
secret-shield-docker/
├── docker/                             # Docker image definition
│   ├── Dockerfile                      # Multi-stage build for minimal image size
│   ├── entrypoint.sh                   # Container orchestration script
│   └── .gitleaks.toml                  # Default Gitleaks configuration
├── scripts/
│   └── scan.sh                         # Local scanning convenience script
├── github-workflows/
│   └── secret-scan.yml                 # GitHub Actions workflow template
├── gitlab-ci/
│   └── secret-scan.yml                 # GitLab CI/CD job template
├── examples/
│   ├── github-actions.yml              # Complete CI/CD pipeline example (GitHub)
│   └── gitlab-ci.yml                   # Complete CI/CD pipeline example (GitLab)
├── docs/
│   ├── INSTALLATION.md                 # Detailed installation guide
│   ├── CONFIGURATION.md                # Configuration and customization guide
│   └── TROUBLESHOOTING.md              # Common issues and solutions
├── .gitleaksignore                     # Global baseline for false positives
├── Makefile                            # Build and test automation
├── LICENSE                             # MIT License
└── README.md                           # This file
```

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following installed on your system:

*   **Docker** (version 20.10 or later)
*   **Docker Compose** (optional, for advanced scenarios)
*   **Make** (optional, for using the Makefile)
*   **Git** (for cloning the repository)

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/secret-shield-docker.git
cd secret-shield-docker
```

### 2. Build the Docker Image

Build the Secret Shield Docker image using the provided Makefile or Docker directly.

**Using Makefile:**

```bash
make build
```

**Using Docker directly:**

```bash
docker build -t secret-shield:latest -f docker/Dockerfile .
```

### 3. Run a Local Scan

Scan your current directory or any repository for secrets using the convenience script or Docker directly.

**Using the scan script:**

```bash
chmod +x scripts/scan.sh
./scripts/scan.sh /path/to/scan
```

**Using Docker directly:**

```bash
docker run --rm \
  -v /path/to/scan:/scan \
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
make scan SCAN_PATH=/path/to/scan
make scan-verbose SCAN_PATH=/path/to/scan
```

### 4. Review the Report

After the scan completes, review the generated report in your preferred format.

```bash
# View JSON report
cat reports/gitleaks-report.json | jq '.'

# View summary
jq 'length' reports/gitleaks-report.json
```

## 🔧 Configuration

### Environment Variables

Control the scanning behavior using environment variables:

| Variable | Default | Description |
| :-- | :-- | :-- |
| `SCAN_PATH` | `.` | Path to scan (absolute path inside container) |
| `CONFIG_PATH` | `/app/.gitleaks.toml` | Path to Gitleaks configuration file |
| `REPORT_FORMAT` | `json` | Report format: `json`, `csv`, `sarif`, `junit` |
| `REPORT_PATH` | `/app/gitleaks-report.json` | Path where the report will be saved |
| `EXIT_ON_FINDING` | `true` | Exit with error code 1 if secrets are found |
| `VERBOSE` | `false` | Enable verbose output for debugging |
| `BASELINE_PATH` | `` | Path to baseline file for ignoring known issues |

### Customizing Detection Rules

The default configuration file (`docker/.gitleaks.toml`) includes rules for detecting common secret patterns. To customize the rules:

1. **Copy the default configuration:**

```bash
cp docker/.gitleaks.toml my-custom-config.toml
```

2. **Edit the configuration** to add, remove, or modify rules:

```toml
[[rules]]
id = "custom-secret"
description = "My custom secret pattern"
regex = '''my_secret_pattern_here'''
entropy = 3.5
keywords = ["secret", "custom"]
```

3. **Use the custom configuration** in your scans:

```bash
docker run --rm \
  -v /path/to/scan:/scan \
  -v $(pwd)/my-custom-config.toml:/app/.gitleaks.toml:ro \
  secret-shield:latest
```

### Managing False Positives

Use the `.gitleaksignore` file to exclude known false positives:

1. **Find the fingerprint** of the false positive from the scan report
2. **Add it to `.gitleaksignore`:**

```bash
echo "cd5226711335c68be1e720b318b7bc3135a30eb2:cmd/generate/config/rules/sidekiq.go:sidekiq-secret:23" >> .gitleaksignore
```

3. **Re-run the scan** — the fingerprint will now be ignored

## 🔄 CI/CD Integration

### GitHub Actions

Copy the workflow file to your repository and enable GitHub Actions:

```bash
mkdir -p .github/workflows
cp github-workflows/secret-scan.yml .github/workflows/
git add .github/workflows/secret-scan.yml
git commit -m "Add Secret Shield scan workflow"
git push
```

The workflow will automatically run on:
*   Push to `main` and `develop` branches
*   Pull requests to `main` and `develop` branches
*   Daily schedule at 2 AM UTC
*   Manual trigger via `workflow_dispatch`

### GitLab CI/CD

Include the Secret Shield job in your `.gitlab-ci.yml`:

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

Then push and GitLab will automatically run the scan on every pipeline.

### Jenkins

Create a Jenkins pipeline job with the following stage:

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

### JSON Report Format

The JSON report contains detailed information about each finding:

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

The SARIF (Static Analysis Results Interchange Format) report is compatible with GitHub Security and other SIEM tools:

```bash
docker run --rm \
  -v /path/to/scan:/scan \
  -e REPORT_FORMAT=sarif \
  -e REPORT_PATH=/app/gitleaks-report.sarif \
  secret-shield:latest
```

## 🛠️ Advanced Usage

### Scanning Git History

To scan the entire git history of a repository:

```bash
docker run --rm \
  -v /path/to/repo:/scan \
  -e SCAN_PATH=/scan \
  secret-shield:latest
```

The container automatically detects if the path is a git repository and scans all commits.

### Incremental Scanning

For large repositories, use baseline files to track only new findings:

```bash
# First scan - create baseline
docker run --rm \
  -v /path/to/scan:/scan \
  -e REPORT_PATH=/app/baseline.json \
  secret-shield:latest

# Subsequent scans - only new findings
docker run --rm \
  -v /path/to/scan:/scan \
  -e BASELINE_PATH=/app/baseline.json \
  -e REPORT_PATH=/app/new-findings.json \
  secret-shield:latest
```

### Multi-Format Reporting

Generate reports in multiple formats for different tools:

```bash
# JSON for programmatic processing
docker run --rm \
  -v /path/to/scan:/scan \
  -e REPORT_FORMAT=json \
  -e REPORT_PATH=/app/report.json \
  secret-shield:latest

# SARIF for GitHub Security
docker run --rm \
  -v /path/to/scan:/scan \
  -e REPORT_FORMAT=sarif \
  -e REPORT_PATH=/app/report.sarif \
  secret-shield:latest

# CSV for spreadsheet analysis
docker run --rm \
  -v /path/to/scan:/scan \
  -e REPORT_FORMAT=csv \
  -e REPORT_PATH=/app/report.csv \
  secret-shield:latest
```

## 🐛 Troubleshooting

### Common Issues

**Issue: "No secrets detected" but I know there are secrets**

*Solution:* Ensure your configuration file includes the appropriate rules. Check the `docker/.gitleaks.toml` file and verify that the secret patterns match your use case.

**Issue: Too many false positives**

*Solution:* Add the fingerprints of false positives to the `.gitleaksignore` file. You can also customize the detection rules in `docker/.gitleaks.toml`.

**Issue: Scan is very slow**

*Solution:* For large repositories, consider using baseline files to scan only new commits. You can also exclude specific directories by modifying the configuration.

**Issue: Docker image build fails**

*Solution:* Ensure you have sufficient disk space and that Docker is running. Check the build logs for specific error messages.

For more troubleshooting tips, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## 📚 Documentation

For more detailed information, refer to the following documentation files:

*   **[INSTALLATION.md](docs/INSTALLATION.md)** — Detailed installation and setup guide
*   **[CONFIGURATION.md](docs/CONFIGURATION.md)** — Advanced configuration options
*   **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** — Common issues and solutions

## 🤝 Contributing

Contributions are welcome! If you have suggestions for improvements, new features, or bug fixes, please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code follows the existing style and includes appropriate tests.

## 📜 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for complete details.

## 🙏 Acknowledgments

Secret Shield Docker is built on top of the excellent [Gitleaks](https://github.com/gitleaks/gitleaks) project by [Zachary Rice](https://github.com/zricethezav). Special thanks to the Gitleaks community for creating such a powerful secret detection tool.

## 📞 Support

For issues, questions, or feature requests, please open an [issue](https://github.com/yourusername/secret-shield-docker/issues) on GitHub.

---

**Made with ❤️ for secure software development**
# secret-shield-docker
