# Do the build in a rust image (we'll move the binaries later)
FROM rust:latest as builder

# Dependencies and folders
#RUN USER=root apt-get update && apt-get -y install libssl-dev libpocketsphinx-dev libsphinxbase-dev clang
RUN mkdir build
WORKDIR /build

# With Rust in Docker the best way to proceed is to first build the dependencies
# (by setting up dummy projects) and then build the actual project.

# First, populate workspace with dummies
RUN USER=root cargo init --bin ./ --name default-skill

# Copy all project files
COPY ./Cargo.toml ./Cargo.lock ./


# Build the dependencies
RUN cargo build --release

# Actual build
## Delete dummy sources
RUN rm ./src/*.rs

## Copy sources and build again
COPY . ./
RUN rm ./target/release/deps/* && cargo build --release

# Move to final image and configure it
FROM debian:bullseye-slim
ARG APP=/usr/src/app


# CoAP Port
EXPOSE 5683

ENV TZ=Etc/UTC \
    APP_USER=appuser

RUN groupadd $APP_USER \
    && useradd -g $APP_USER $APP_USER \
    && mkdir -p ${APP}

# Copy binary
COPY --from=builder \
    /build/target/release/default-skill \
    ${APP}/default-skill

RUN chown -R $APP_USER:$APP_USER ${APP}

USER $APP_USER
WORKDIR ${APP}

CMD ["./default-skill"]
