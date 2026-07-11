#!/usr/bin/env bash

playerctl -a metadata --format '{"text": "{{artist}} — {{title}}", "tooltip": "{{playerName}}: {{artist}} — {{title}} ({{album}})", "alt": "{{status}}", "class": "{{status}}"}' -F 2>/dev/null || echo '{"text": "  No Media", "tooltip": "Nothing playing", "alt": "Stopped", "class": "Stopped"}'
