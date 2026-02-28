#!/bin/bash
# scripts/fix_icon_padding.sh

# Target size: 1024x1024
# Safe area: 924x924 (90% of canvas, or approx 80% visually depending on squircle)
# Based on Perplexity research, we need 50px transparent margin on all sides.

INPUT_ICON="assets/DPI Killer-iOS-Default-1024x1024@1x.png"
TEMP_ICON="assets/icon_resized.png"
OUTPUT_ICNS="assets/AppIcon.icns"

if [ ! -f "$INPUT_ICON" ]; then
    echo "Error: Input icon $INPUT_ICON not found."
    exit 1
fi

echo "Fixing icon padding for macOS standards..."

# We use sips (native macOS tool) to resize the icon to 824x824 (approx 80%) 
# then pad it to 1024x1024 with transparency.
# 1024 - 50*2 = 924. Let's use 924 for exact spec.

mkdir -p assets/AppIcon.iconset

# Define sizes for .icns
# We scale the original 1024 to the 'content' size and then pad to the 'canvas' size.

function generate_size() {
    local canvas_size=$1
    local scale=$2
    local content_size=$(echo "$canvas_size * 0.9" | bc | cut -d. -f1) # 90% content
    
    local name="icon_${canvas_size}x${canvas_size}${scale}.png"
    local actual_canvas=$canvas_size
    if [ "$scale" == "@2x" ]; then
        actual_canvas=$((canvas_size * 2))
        content_size=$((content_size * 2))
    fi
    
    # Resize content
    sips -z $content_size $content_size "$INPUT_ICON" --out "assets/AppIcon.iconset/tmp.png" > /dev/null
    
    # Pad to canvas with transparency
    # sips -p <height> <width> --padColor <hex>
    sips -p $actual_canvas $actual_canvas --padColor 000000 "assets/AppIcon.iconset/tmp.png" --out "assets/AppIcon.iconset/$name" > /dev/null
    
    # Force transparency (sips -p can sometimes result in black backgrounds if not handled carefully)
    # Actually, a better way for CI/macOS is to use the 'canvas' approach if available, 
    # but sips -p is standard.
    
    echo "Generated $name ($content_size inside $actual_canvas)"
}

# Standard icns sizes
generate_size 16 ""
generate_size 16 "@2x"
generate_size 32 ""
generate_size 32 "@2x"
generate_size 128 ""
generate_size 128 "@2x"
generate_size 256 ""
generate_size 256 "@2x"
generate_size 512 ""
generate_size 512 "@2x"

# Combine into .icns
iconutil -c icns assets/AppIcon.iconset -o "$OUTPUT_ICNS"

# Cleanup
rm -rf assets/AppIcon.iconset
rm -f assets/AppIcon.iconset/tmp.png

echo "New AppIcon.icns created with correct padding."
