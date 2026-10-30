#!/usr/bin/env bash
set -Eeuo pipefail

HOSTS_DIR="/etc/dnsmasq.d/hosts"
DOMAIN="gg"
TARGET_NETWORK="greygoose"

# Remote Docker connection string (e.g., ssh://user@remote-host or tcp://ip:port)
REMOTE_DOCKER="${REMOTE_DOCKER:-}"

# 1. Start dnsmasq in the background
echo "Starting dnsmasq..."
dnsmasq --hostsdir="$HOSTS_DIR" --local="/$DOMAIN/"

# Generic function to handle sync and event streaming for any Docker target
monitor_docker() {
    local docker_args="$1"
    local prefix="$2"

    cleanup_container() {
        local cid="$1"
        local host_file="$HOSTS_DIR/${prefix}-$cid.hosts"
        if [[ -f "$host_file" ]]; then
            echo "[$prefix] Removing DNS record for $cid"
            rm -f "$host_file"
        fi
    }

    publish_container() {
        local cid="$1"
        local ip
        local hostname
        
        # Only grab the IP if the container is connected to the specific target network
        ip=$(docker $docker_args inspect -f "{{with index .NetworkSettings.Networks \"$TARGET_NETWORK\"}}{{.IPAddress}}{{end}}" "$cid" 2>/dev/null || true)
        
        if [[ -z "$ip" || "$ip" == "<no value>" ]]; then
            return
        fi

        # Check for the greygoose.hostname label; fallback to container name if missing
        hostname=$(docker $docker_args inspect -f '{{ index .Config.Labels "greygoose.hostname" }}' "$cid" 2>/dev/null || true)
        if [[ -z "$hostname" || "$hostname" == "<no value>" ]]; then
            hostname=$(docker $docker_args inspect -f '{{.Name}}' "$cid" 2>/dev/null | sed 's#^/##')
        fi

        if [[ -n "$hostname" ]]; then
            echo "[$prefix] Creating DNS record: ${hostname}.${DOMAIN} -> ${ip} (on $TARGET_NETWORK)"
            printf "%s\t%s.%s\t%s\n" "$ip" "$hostname" "$DOMAIN" "$hostname" > "$HOSTS_DIR/${prefix}-$cid.hosts"
        fi
    }

    # Initial sync for already running containers
    for cid in $(docker $docker_args ps -q 2>/dev/null || true); do
        publish_container "$cid"
    done

    # Stream container events using .Action and .Actor.ID
    echo "[$prefix] Listening for container events..."
    while true; do
        # Use process substitution instead of a pipe
        while read -r status cid; do
            if [[ "$status" == "start" ]]; then
                publish_container "$cid"
            elif [[ "$status" == "die" ]]; then
                cleanup_container "$cid"
            fi
        done < <(docker $docker_args events --filter 'type=container' --filter 'event=start' --filter 'event=die' --format '{{.Action}} {{.Actor.ID}}')

        echo "[$prefix] Event stream disconnected. Retrying in 5 seconds..." >&2
        sleep 5
    done
}

# 2. Start local monitor in the background
monitor_docker "" "local" &

# 3. Start remote monitor in the background (if configured)
if [[ -n "$REMOTE_DOCKER" ]]; then
    echo "Starting remote monitor for $REMOTE_DOCKER..."
    monitor_docker "-H $REMOTE_DOCKER" "remote" &
fi

# Keep container alive by waiting for all background jobs
wait