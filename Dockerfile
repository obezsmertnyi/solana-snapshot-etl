FROM rust:1.70.0

RUN apt-get update && apt install -y git curl

WORKDIR /app

# Clone geyser repo
RUN git clone --depth 1 --branch v0.1.11 https://github.com/extrnode/solana-geyser-zmq

COPY ./solana-snapshot-etl solana-snapshot-etl
COPY Cargo.* ./

# build geyser zmq
RUN cargo build --release -p solana-geyser-plugin-scaffold

# build snapshot etl
RUN cargo build --features=standalone --bin=solana-snapshot-etl

ENTRYPOINT ["cargo", "r", "--features=standalone", "--bin=solana-snapshot-etl"]