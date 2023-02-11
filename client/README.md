# Oracle client

This a poncho project for the oracle client code.

The `oracle_client` dir is the home of the user facing CLI tool for users.

The `oracle_client_lib` is the library code that can be used by different projects in this dir.

To build CLI tool locally you will need [Zig](https://ziglang.org) `0.10.0` or higher. There is a solid zig plugin for ASDF.

Also, to test the socket connection have the `oraclex` Phoenix server running in a different tab.

Currently the CLI will only publish to the oraclex channel what you input in prompt.

As of right the only target for the CLI Mac OXS arm64.

To build in debug mode, which will print a lot of debug information when you run the CLI.

```
cd oracle_client
mix deps.get
mix release
... wait for build
./burrito_out/oracle_client_macos_m1
```

If you want to build for production mode - to not print all the debug data during CLI start change your `mix release` command to `MIX_ENV=prod mix release`.

This should speed up CLI start and not dump so much data to the terminal.

The nice thing about poncho projects in the projects can be ran separately.

If you want to run the library code execute these commands:

```
cd oracle_client_lib
mix deps.get
iex -S mix
```

Now you're in the IEx session with the library code loaded. To connect to the `oraclex` channel run:

```
OracleClientLib.start_socket()
OracleClientLib.Socket.publish_message("to the moon")
```
