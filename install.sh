#!/usr/bin/env bash

mkdir modules
cd modules

git clone git@github.com:TrejGun/first.git
git clone git@github.com:TrejGun/second.git

cd ../
mkdir packages
cd packages

git clone git@github.com:TrejGun/optimize-mongoose-controllers.git
git clone git@github.com:TrejGun/optimize-mongoose-models.git

npm i
npm run bootstrap
npm run build
