# Blockchain-Based-Property-Registration


## Land Registration using Blockchain

## Problem it Solves:
1. The elimination of middlemen: The elimination of middlemen or brokers makes the process of land registration less expensive. Brokers who try to defraud uninformed people will be unable to do so any longer. Brokers frequently take a long time to finish procedures, thus our project will help people save time.
2. A distributed tamper-proof ledger that prohibits ownership fraud.
3. IPFS is used to store important property registration papers in a secure manner.

## Technology Stack:
1. Ethereum Blockchain
2. Polygon/Matic
3. Web3Dart
4. IPFS
5. Flutter
6. Metamask

## To Run Application Locally
1. Clone the github repository and cd to the folder
2. Install the flutter 3.0.2, nodejs
3. Install ganache and truffle as shown below:
```
npm install -g truffle
```
4. Open Ganache and keep it running in the Background
5. Install the Metamask chrome extension, choose the local network and import the accounts
6. Compile and run our migrations from the command line as shown below:
```
truffle compile
truffle migrate
```
7. Copy contract address from the migration output and paste in variable `contractAddress` located in the file `./lib/constant/constant.dart`

Example output:
```
2_deploy_migration.js
=====================

   Replacing 'Land'
   ----------------
   > transaction hash:    0x427b2b402f767ac6a90334ab3c687b086b274de747fe10d6e194743b15057d78
   > Blocks: 0            Seconds: 0
   > contract address:    0xed690C24C60A48F8A9819c9A15AD75B70CFBEa5a
   > block number:        3
   > block timestamp:     1650602828
   > account:             0x33e94e4619f0AecDf81e9676Eb82c109FBa53356
   > balance:             99.9154895
   > gas used:            3996227
   > gas price:           20 gwei
   > value sent:          0 ETH
   > total cost:          0.07992454 ETH
```

8. In `constant.dart` file, change the value of the variable `chainId` to `'1337'` and change the value of the variable `rpcUrl` to `"http://127.0.0.1:7545"`
9. Run the flutter web app
```
flutter pub get
flutter run -d web-server --web-port 5555
```
10. Open the browser and the dapp will be running in http://localhost:5555/
    
## Project Flowchart
(Flowchart image removed)

## Key Features
- Home Page and Wallet connect/Login functionality
- Contract Owner Dashboard with User Registration
- Land Inspector Dashboard with User Verification 
- User Dashboard with Map Integration for Adding land
- Land Gallery with detailed Land Information
- Request Management and Payment System
- Transfer ownership with Seller/Buyer verification
- Witness information and photo capture during transfers
