# Async::Utilization

High-performance utilization metrics for Async services using shared memory.

[![Development Status](https://github.com/socketry/async-utilization/workflows/Test/badge.svg)](https://github.com/socketry/async-utilization/actions?workflow=Test)

## Usage

Please see the [project documentation](https://socketry.github.io/async-utilization/) for more details.

  - [Getting Started](https://socketry.github.io/async-utilization/guides/getting-started/index) - This guide explains how to get started with `async-utilization` to track high-performance utilization metrics for Async services using shared memory.

## Releases

Please see the [project releases](https://socketry.github.io/async-utilization/releases/index) for all releases.

### v0.4.0

  - Add `Async::Utilization::Namespace` for composing registry metric names.
  - `Async::Utilization::Metric` is the primary interface, remove `#set`, `#increment`, `#decrement` and `#track` from `Registry`.

### v0.3.2

  - Better observer state handling.

### v0.3.1

  - Remove unused `thread-local` dependency.

### v0.3.0

  - Introduce `Metric#track{...}` for increment -\> decrement.

### v0.1.0

  - Initial implementation.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Running Tests

To run the test suite:

``` shell
bundle exec sus
```

### Making Releases

To make a new release:

``` shell
bundle exec bake gem:release:patch # or minor or major
```

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
