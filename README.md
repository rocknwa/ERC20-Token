

# 🪙 Solidity Token Suite

A comprehensive suite of Solidity-based ERC-20 token implementations, showcasing both manual and automated token functionalities, complete with robust testing using Foundry.

## 📌 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## 🧾 Overview

This project demonstrates the creation and testing of ERC-20 compliant tokens using Solidity. It includes:

- **ManualToken**: A manually implemented ERC-20 token with additional functionalities like `approveAndCall`, `burn`, and `burnFrom`.
- **OurToken**: A token deployed via a deployment script, emphasizing automated deployment processes.

Both tokens are thoroughly tested using Foundry's testing framework, ensuring reliability and correctness.

## ✨ Features

- **ERC-20 Compliance**: Both tokens adhere to the ERC-20 standard, ensuring compatibility with wallets and exchanges.
- **Advanced Functionalities**:
  - `approveAndCall`: Allows token holders to approve and then call a contract in a single transaction.
  - `burn` and `burnFrom`: Enable token holders and approved spenders to reduce the total supply.
- **Comprehensive Testing**: Utilizes Foundry's testing tools to ensure all functionalities work as intended.
- **Deployment Script**: Automates the deployment of `OurToken`, streamlining the deployment process.

## 🛠️ Technologies Used

- **Solidity**: Smart contract programming language.
- **Foundry**: Ethereum development framework for compiling, testing, and deploying contracts.
- **Forge**: Part of Foundry, used for testing and building smart contracts.
- **Anvil**: Local Ethereum node for testing.
- **OpenZeppelin**: Library for secure smart contract development.

## 🚀 Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed on your machine.

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/rocknwa/solidity-token-suite.git
   cd solidity-token-suite
   ```

2. **Install dependencies**:
   ```bash
   forge install
   ```

3. **Build the contracts**:
   ```bash
   forge build
   ```

## 🧪 Testing

Run the test suite using Forge:

```bash
forge test
```

This will execute all tests located in the `test/` directory, ensuring that all functionalities of both tokens are working correctly.

## 📁 Project Structure

```
solidity-token-suite/
├── src/
│   ├── ManualToken.sol        # Manual ERC-20 token implementation
│   └── OurToken.sol           # Token deployed via script
├── script/
│   └── DeployOurToken.s.sol   # Deployment script for OurToken
├── test/
│   ├── ManualToken.t.sol      # Tests for ManualToken
│   └── OurTokenTest.t.sol     # Tests for OurToken
├── foundry.toml               # Foundry configuration file
└── README.md                  # Project documentation
```

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any enhancements or bug fixes.

