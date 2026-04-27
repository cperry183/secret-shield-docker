# Contributing to Secret Shield Docker

Thank you for your interest in contributing to Secret Shield Docker! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

Please be respectful and constructive in all interactions with other contributors and maintainers.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with the following information:

*   **Description:** Clear description of the bug
*   **Steps to Reproduce:** Step-by-step instructions to reproduce the issue
*   **Expected Behavior:** What you expected to happen
*   **Actual Behavior:** What actually happened
*   **Environment:** Your OS, Docker version, and other relevant details
*   **Logs:** Any error messages or logs from the scan

### Suggesting Enhancements

To suggest a new feature or enhancement:

1. Check if the feature has already been suggested in the issues
2. Open a new issue with the label `enhancement`
3. Provide a clear description of the feature and its use case
4. Explain why this feature would be useful

### Submitting Pull Requests

1. **Fork the repository** and create a new branch for your feature

```bash
git checkout -b feature/your-feature-name
```

2. **Make your changes** following the code style guidelines

3. **Test your changes** thoroughly

```bash
make lint
make test
```

4. **Commit your changes** with clear, descriptive commit messages

```bash
git commit -m "Add feature: description of your feature"
```

5. **Push to your fork** and open a Pull Request

```bash
git push origin feature/your-feature-name
```

6. **Describe your changes** in the Pull Request, referencing any related issues

## Development Setup

To set up a development environment:

1. **Clone the repository:**

```bash
git clone https://github.com/yourusername/secret-shield-docker.git
cd secret-shield-docker
```

2. **Install development dependencies:**

```bash
# Install linting tools
brew install hadolint shellcheck  # macOS
# or
sudo apt-get install hadolint shellcheck  # Ubuntu/Debian
```

3. **Build the Docker image:**

```bash
make build
```

4. **Run tests:**

```bash
make test
```

## Code Style Guidelines

### Shell Scripts

*   Use `#!/bin/bash` shebang
*   Use 4-space indentation
*   Include comments for complex logic
*   Use meaningful variable names
*   Quote variables: `"$var"` instead of `$var`

### Dockerfile

*   Use Alpine Linux for minimal image size
*   Combine RUN commands to reduce layers
*   Use `--no-cache` with `apk add` to reduce image size
*   Include comments for non-obvious instructions
*   Use specific version tags for base images

### Configuration Files

*   Use TOML format for Gitleaks configuration
*   Include comments explaining each section
*   Use meaningful names for custom rules

## Testing

Before submitting a Pull Request, ensure your changes pass all tests:

```bash
make lint
make test
```

### Adding New Tests

If you add new functionality, please include tests. Tests should:

*   Be clear and descriptive
*   Test both success and failure cases
*   Be reproducible and deterministic

## Documentation

When adding new features, please update the relevant documentation:

*   Update `README.md` if the feature affects user-facing functionality
*   Update `docs/CONFIGURATION.md` if the feature adds new configuration options
*   Add examples in the `examples/` directory if applicable

## Commit Message Guidelines

Use clear, descriptive commit messages:

*   Use the imperative mood ("Add feature" not "Added feature")
*   Keep the first line under 50 characters
*   Reference issues using `#issue-number`
*   Example: `Add support for custom rules (#42)`

## Release Process

Maintainers will handle releases. When a new version is ready:

1. Update version numbers in relevant files
2. Update the CHANGELOG
3. Create a GitHub release with release notes
4. Tag the commit with the version number

## Questions?

If you have questions or need clarification, please open an issue or reach out to the maintainers.

Thank you for contributing!
