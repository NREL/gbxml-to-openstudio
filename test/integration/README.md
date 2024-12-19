# Regression Tests

1. Ensure that the version of OpenStudio you want to run the tests against is installed in the default location
   1. Windows (e.g. `C:\openstudio-3.4.0`)
   2. macOS (e.g. `/Applications/OpenStudio-3.4.0`)
2. Update the `OS_VERSION` variable in the `.env` file to reflect the OpenStudio version
   1. Optionally set `THREADS` to the number of parallel simulations you want to run, otherwise it will default to the number of cores - 3
3. In the `test/regression` directory run `npm install` and then `npm start`
4. View the outputs in `workflows/regression-tests/{OS_VERSION}`
5. Optionally run `npm run stats` to produce a `test/regression/stats-{OS_VERSION}.csv` file with runtime and success results
