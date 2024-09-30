# Solana snapshot ETL tools
This repository collects 3 necessary things to fill any DB with current state of all the Solana accounts.

### Building

    $ make build

### Dowload snapshot
Snapshot will be downloaded to ./snapshot directory

    $ make download

### Stream snapshot
All snapshots inside ./snapshot directory will be streamed one by one

    $ make stream
