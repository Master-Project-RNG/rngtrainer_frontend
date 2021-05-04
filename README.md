# rgntrainer_frontend

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

## About The Project

### Built With

* [Flutter](https://flutter.dev/)


## Getting Started

### Prerequisites
#### Option 1: Using docker!
The easiest way to get the frontend running is by using Visual Studio Code and its extensions + Docker. With docker you don't need to install the Flutter and Android SDK on your developer machine.

* [Install Visual Studio Code](https://code.visualstudio.com/) 
* [Install Docker](https://www.docker.com/products/docker-desktop)

Inside VsCode, install following extensions:
* [Docker extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
* [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)


The configuration for the dockerfile can be found in the following repository file:
[Configuration of dockerfile](.devcontainer/devcontainer.json).

For debugging, the following chrome extension is needed:
[Chrome Debug Extension](https://chrome.google.com/webstore/detail/dart-debug-extension/eljbmlghnomdjgdjmbdekegdkbabckhm).
After installing that please navigate to lib/main.dart and press F5. This will launch a new browser tab and you have to click the Dart debug plugin to finally open the app.

#### Option 2: Get it run without docker!
* [Install Visual Studio Code](https://code.visualstudio.com/) 

Inside VsCode, install following extensions:

### Installation

<!-- USAGE EXAMPLES -->
## Usage
```sh
TODO: This space will be used to show  examples of how a project can be used. 
Additional screenshots, code examples and demos work will be in this space. 
```

<!-- ROADMAP -->
## Roadmap
See the [open issues](https://github.com/Master-Project-RNG/rgntrainer_frontend/issues) for a list of proposed features (and known issues).

<!-- LICENSE -->
## License
```sh
TODO
```
