# Contributing to Uptospeed

Thank you for considering contributing to Uptospeed! This project aims to make setting up data science environments quick and painless across different systems.

## How to Contribute

1. **Fork the repository** to your GitHub account
2. **Clone the forked repository** to your local machine
3. **Create a new branch** for your changes
4. **Make your changes**
5. **Test your changes** on different platforms if possible
6. **Commit and push** your changes to your fork
7. **Submit a pull request** to the main repository

## Types of Contributions

- **Bug fixes**: If you find a bug, please submit an issue or a PR with a fix
- **New features**: Add new tools, packages, or capabilities
- **Documentation**: Improve the documentation with examples, use cases, or clearer explanations
- **Testing**: Test the scripts on different platforms and report your findings

## Guidelines

### Script Contributions

When adding new features to the setup script:

1. Ensure compatibility with the supported platforms (Ubuntu/Debian, CentOS/RedHat/Fedora, macOS)
2. Use clear variable names and add comments explaining complex operations
3. Follow the existing logging pattern (using the log, success, warn, error functions)
4. Make sure any added tools are properly checked for existence before installation
5. When adding new packages to the environment, include them in the appropriate section of the environment.yml template

### Documentation Contributions

When improving documentation:

1. Use clear, concise language
2. Add examples when explaining features
3. Make sure all commands and examples are correct and tested
4. Keep the README focused on quick-start and essential information

## Environment.yml Guidelines

When adding packages to the environment.yml template:

1. Group related packages together
2. Add a brief comment indicating what the package is used for if it's not obvious
3. Consider compatibility across different operating systems
4. For packages only available via pip, add them to the pip section

## Code Style

- Use 4 spaces for indentation in scripts
- Follow standard shell script best practices
- Add comments to explain complex operations
- Use functions to organize code into logical units

## Testing

Before submitting a PR:

1. Test your changes on your local system
2. If possible, test on multiple systems (e.g., different Linux distributions, macOS)
3. Make sure all the components install correctly
4. Check that the conda environment can be created with the specified packages

## License

By contributing to this project, you agree that your contributions will be licensed under the project's MIT License.