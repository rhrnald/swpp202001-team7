# SWPP Interpreter

This interpreter executes SWPP assembly programs.

## Build

- Requirement: cmake

```bash
# e.g. install cmake in ubuntu
sudo apt install cmake
```

- Build

```bash
# creates "sf-interpreter"
./build.sh
```

## Run

```bash
# executes a given assembly program and prints status to "sf-interpreter.log"
# note that it gets a standard input on call to "read"
./sf-interpreter <input assembly file>
```
