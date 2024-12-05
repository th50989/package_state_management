<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: Simple state managemnt package

## Usage

Create state : 
StateManager.createState<int>('counter', 0);

Get state:
int counter = StateManager.getState<int>('counter');
print(counter); // Output: 0

Update the state:
StateManager.updateState<int>('counter', (value) => value + 1);

Listen for changes:
StateManager.watchState<int>('counter', () {
  print("Counter updated");
});

Use StatefulListener for UI updates:
StatefulListener<int>(
  stateKey: 'counter',
  builder: (context, counter) {
    return Text('Counter: $counter');
  },
)

# StateManager

StateManager is a lightweight state management solution for Flutter.

## Installation
Add this to your `pubspec.yaml`:

```yaml
dependencies:
  state_manager:
    path: ../package_state_manager
