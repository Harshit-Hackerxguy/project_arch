#!/usr/bin/env bash

get_art() {
    art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)
    if [[ -n "$art_url" ]]; then
        if [[ "$art_url" == file://* ]]; then
            echo "${art_url#file://}"
        else
            local cache_dir="$HOME/.cache/eww-media"
            mkdir -p "$cache_dir"
            local art_file="$cache_dir/cover.jpg"
            curl -s -o "$art_file" "$art_url" 2>/dev/null
            echo "$art_file"
        fi
    else
        echo ""
    fi
}

playerctl -a metadata --format '{"title":"{{title}}","artist":"{{artist}}","status":"{{status}}","art":"'"$(get_art)"'"}' -F 2>/dev/null || echo '{"title":"Nothing Playing","artist":"","status":"Stopped","art":""}'
