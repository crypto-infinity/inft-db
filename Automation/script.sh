#!/bin/bash

echo Beginning Agent preparation

sudo apt update
sudo apt upgrade -y
sudo apt install npm -y
sudo npm install -g truffle
npm i @openzeppelin/contracts
npm i @openzeppelin/contracts-upgradeable
truffle init
cd contracts/
sudo curl -o INFT_DB.sol https://raw.githubusercontent.com/crypto-infinity/inft-db/main/contracts/INFT_DB.sol
sudo curl -o standardNFT_DB.sol https://raw.githubusercontent.com/crypto-infinity/inft-db/main/contracts/standardNFT_DB.sol
truffle compile


