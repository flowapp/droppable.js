# Droppable.js

## Installing

droppable.js is available on npm and can be installed by running:

``` 
$ npm install --save droppable.js 
```

## Contributing

Make sure to download dependencies by running `npm install` and installing
`karma-cli` and `broccoli-cli` globally by running `npm install -g karma-cli
broccoli-cli`.

### Running

``` 
$ broccoli serve 
```

Broccoli will serve a build on `http://localhost:4200/droppable.js`. All
examples will use this build when available.

### Running the test suite

To simplify the test setup, we’re using broccoli to build our tests as well,
simply run `broccoli serve` and `karma start` to run the test suite.

The test suite assumes the user agent implementations works. Down the road, we
might create implementation tests using selenium, to make sure they work as
expected as well.

### Distributing a build

``` 
$ broccoli build ./dist 
```
