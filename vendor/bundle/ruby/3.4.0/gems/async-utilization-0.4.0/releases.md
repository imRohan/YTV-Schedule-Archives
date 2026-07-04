# Releases

## v0.4.0

  - Add `Async::Utilization::Namespace` for composing registry metric names.
  - `Async::Utilization::Metric` is the primary interface, remove `#set`, `#increment`, `#decrement` and `#track` from `Registry`.

## v0.3.2

  - Better observer state handling.

## v0.3.1

  - Remove unused `thread-local` dependency.

## v0.3.0

  - Introduce `Metric#track{...}` for increment -\> decrement.

## v0.1.0

  - Initial implementation.
