# MQTT Helper Flutter Project

## Overview

This Flutter project is an MQTT (Message Queuing Telemetry Transport) helper application designed to facilitate easy publishing and subscribing of messages between devices and servers using the MQTT protocol. The app provides a straightforward interface for connecting to MQTT brokers, managing subscriptions, and publishing messages, making it ideal for IoT (Internet of Things) applications where lightweight messaging is crucial.

## Features

- **MQTT Connection Management** :  Connect to any MQTT broker using configurable settings such as host, port, client ID, and credentials.
- **Publish and Subscribe**  : Easily publish messages to topics and subscribe to multiple topics to receive messages in real-time.
- **Dashboard View**   : Visualize incoming messages and manage subscriptions through a user-friendly dashboard.
- **Cross-Platform Compatibility**   : Built with Flutter, enabling the app to run on Android, iOS, and potentially other platforms.

## Project Structure

The project is organized into several directories and files, each serving a specific purpose:

 - **`lib/`**: Contains the main application code, including core logic and user interface.
     - **`core/`**: Contains the core logic of the application.
     - **`util/`**: Utility functions and helpers used across the app.
     - **`mqtt/`**: Houses MQTT-related functionality and helper classes.
        - **`mqtt_helper.dart`**: The main helper class for managing MQTT connections, publishing, and subscribing.
     - **`features/`**: Contains feature-specific code, organized by domain.
        - **`mqtt/`**: Code related to MQTT functionality.
          - **`domain/`**: Defines entities and business logic.
            - **`entity/message_entity.dart`**: Represents the structure of an MQTT message.
          - **`presentation/`**: Manages the presentation layer of the application.
            - **`provider/`**: Contains state management providers.
              - **`mqtt_provider.dart`**: Manages the state for MQTT connections, topics, and messages.
            - **`view/`**: Contains the screens and UI components.
              - **`connection_screen.dart`**: Interface for connecting to the MQTT broker.
              - **`home_screen.dart`**: Main screen after successful connection.
            - **`widgets/`**: Custom widgets used in the app.
              - **`dashboard.dart`**: Widget for displaying subscribed topics and received messages.
              - **`subscribe.dart`**: Widget for managing subscriptions to topics.
 - **`main.dart`**: The entry point of the application.
 - **`android/`**, **`ios/`**: Platform-specific files and configurations for running the app on Android and iOS.

## Getting Started

### Prerequisites

Before begin make sure you have the following installed:

- Flutter 3.-.- (Above 3)

### Installation

1. Clone the repository

   ```
   git clone https://github.com/jibinkj-07/Mqtt-Helper.git
   
   ```
2. Install Flutter: Ensure Flutter is installed on your machine. You can find installation instructions here.

3. Dependencies: Navigate to the project directory and run flutter pub get to install the necessary dependencies.

4. Run the App: Use flutter run to launch the app on your desired platform (mobile, web, or desktop).

## Contact
For any questions or suggestions, please contact jibinkunnumpurath@gmail.com.
