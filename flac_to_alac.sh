#!/bin/bash
#
# FLAC to ALAC Converter Tool
#
# Converts FLAC audio files to ALAC (Apple Lossless Audio Codec) format.
# Preserves metadata and supports batch conversion.
#
# Requirements:
#     - ffmpeg must be installed (brew install ffmpeg)
#
# Usage:
#     ./flac_to_alac.sh <input_file_or_directory> [--output-dir OUTPUT_DIR]
#     ./flac_to_alac.sh song.flac
#     ./flac_to_alac.sh /path/to/flac/files --output-dir /path/to/output
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
OUTPUT_DIR=""
OVERWRITE=false
RECURSIVE=true

# Function to print usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS] INPUT

Convert FLAC audio files to ALAC (Apple Lossless Audio Codec) format.

Arguments:
    INPUT                  Input FLAC file or directory containing FLAC files

Options:
    -o, --output-dir DIR    Output directory for converted files (default: same as input)
    --overwrite            Overwrite existing output files
    -r, --recursive        Recursively search for FLAC files in directories (default: true)
    -h, --help             Show this help message

Examples:
    $0 song.flac
    $0 /path/to/flac/files
    $0 /path/to/flac/files --output-dir /path/to/output
    $0 song.flac --overwrite
EOF
}

# Function to check if ffmpeg is installed
check_ffmpeg() {
    if ! command -v ffmpeg &> /dev/null; then
        echo -e "${RED}Error: ffmpeg is not installed or not in PATH.${NC}" >&2
        echo "" >&2
        echo "To install ffmpeg on macOS:" >&2
        echo "  brew install ffmpeg" >&2
        echo "" >&2
        echo "Or download from: https://ffmpeg.org/download.html" >&2
        exit 1
    fi
}

# Convert one file. Exit: 0 = converted OK, 1 = error, 2 = skipped (non-empty output exists, no --overwrite)
convert_flac_to_alac() {
    local input_file="$1"
    local output_file="$2"
    local overwrite_flag="$3"
    
    local input_path
    if command -v realpath &> /dev/null; then
        input_path=$(realpath "$input_file")
    else
        input_path=$(cd "$(dirname "$input_file")" && pwd)/$(basename "$input_file")
    fi
    
    local output_path
    
    if [ -n "$output_file" ]; then
        # macOS realpath has no -m; join after mkdir so path is absolute
        local out_dir
        out_dir=$(dirname "$output_file")
        mkdir -p "$out_dir"
        output_path="$(cd "$out_dir" && pwd)/$(basename "$output_file")"
    else
        # %.* strips any final extension (.flac, .FLAC, etc.)
        output_path="${input_path%.*}.m4a"
    fi
    
    # Check if input file exists
    if [ ! -f "$input_path" ]; then
        echo -e "${RED}Error: File not found: $input_file${NC}" >&2
        return 1
    fi

    # Check if it's a FLAC file (case-insensitive; tr works on macOS bash 3.2 — no ${var,,})
    local input_lower
    input_lower=$(printf '%s' "$input_path" | tr '[:upper:]' '[:lower:]')
    if [[ ! "$input_lower" =~ \.flac$ ]]; then
        echo -e "${YELLOW}Warning: $input_file doesn't appear to be a FLAC file${NC}" >&2
    fi

    # Stale 0-byte (or interrupted) outputs: remove so ffmpeg can write; otherwise -n would block forever
    if [ -f "$output_path" ] && [ ! -s "$output_path" ]; then
        echo -e "${YELLOW}Removing empty output (re-encoding): $(basename "$output_path")${NC}" >&2
        rm -f "$output_path"
    fi
    
    # Skip only when a non-empty output already exists
    if [ -f "$output_path" ] && [ -s "$output_path" ] && [ "$overwrite_flag" = "false" ]; then
        echo "Skipping $(basename "$input_path") - output file already exists: $(basename "$output_path")"
        return 2
    fi
    
    echo "Converting: $(basename "$input_path") -> $(basename "$output_path")"
    
    # Create output directory if it doesn't exist
    local output_dir=$(dirname "$output_path")
    mkdir -p "$output_dir"
    
    # ffmpeg: -map 0:a = encode all audio streams; global -y/-n before -i
    local overwrite_opt="-n"
    if [ "$overwrite_flag" = "true" ]; then
        overwrite_opt="-y"
    fi
    
    if ffmpeg -hide_banner -nostdin $overwrite_opt -loglevel error -i "$input_path" -map 0:a -c:a alac "$output_path" 2>&1; then
        if [ ! -s "$output_path" ]; then
            echo -e "  ${RED}✗${NC} Output file is empty after encode: $(basename "$output_path")" >&2
            rm -f "$output_path"
            return 1
        fi
        echo -e "  ${GREEN}✓${NC} Success: $(basename "$output_path")"
        return 0
    else
        echo -e "  ${RED}✗${NC} Error converting $(basename "$input_path")" >&2
        rm -f "$output_path" 2>/dev/null || true
        return 1
    fi
}

# Function to find FLAC files in a directory
find_flac_files() {
    local directory="$1"
    local recursive="$2"
    
    if [ "$recursive" = "true" ]; then
        find "$directory" -type f \( -iname "*.flac" \)
    else
        find "$directory" -maxdepth 1 -type f \( -iname "*.flac" \)
    fi
}

# Parse command-line arguments
INPUT=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --overwrite)
            OVERWRITE=true
            shift
            ;;
        -r|--recursive)
            RECURSIVE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo -e "${RED}Error: Unknown option: $1${NC}" >&2
            usage
            exit 1
            ;;
        *)
            if [ -z "$INPUT" ]; then
                INPUT="$1"
            else
                echo -e "${RED}Error: Multiple input arguments provided${NC}" >&2
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if input was provided
if [ -z "$INPUT" ]; then
    echo -e "${RED}Error: Input file or directory required${NC}" >&2
    usage
    exit 1
fi

# Check if ffmpeg is available
check_ffmpeg

# Resolve input path
if [ ! -e "$INPUT" ]; then
    echo -e "${RED}Error: Input path does not exist: $INPUT${NC}" >&2
    exit 1
fi

INPUT_PATH="$INPUT"
if command -v realpath &> /dev/null; then
    INPUT_PATH=$(realpath "$INPUT")
fi

# Determine output directory (avoid realpath -m: not supported on macOS BSD realpath)
if [ -n "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    if command -v realpath &> /dev/null; then
        OUTPUT_DIR_PATH=$(realpath "$OUTPUT_DIR")
    else
        OUTPUT_DIR_PATH=$(cd "$OUTPUT_DIR" && pwd)
    fi
else
    OUTPUT_DIR_PATH=""
fi

# Collect files to convert
FILES_TO_CONVERT=()

if [ -f "$INPUT_PATH" ]; then
    FILES_TO_CONVERT=("$INPUT_PATH")
elif [ -d "$INPUT_PATH" ]; then
    while IFS= read -r -d '' file; do
        FILES_TO_CONVERT+=("$file")
    done < <(find_flac_files "$INPUT_PATH" "$RECURSIVE" | tr '\n' '\0')
    
    if [ ${#FILES_TO_CONVERT[@]} -eq 0 ]; then
        echo -e "${YELLOW}No FLAC files found in: $INPUT_PATH${NC}"
        exit 1
    fi
else
    echo -e "${RED}Error: Input path is neither a file nor a directory: $INPUT_PATH${NC}" >&2
    exit 1
fi

echo "Found ${#FILES_TO_CONVERT[@]} FLAC file(s) to convert"
echo ""

# Convert files
CONVERTED=0
SKIPPED=0
FAILED=0

for flac_file in "${FILES_TO_CONVERT[@]}"; do
    if [ -n "$OUTPUT_DIR_PATH" ]; then
        # Preserve directory structure relative to input
        if [ -f "$INPUT_PATH" ]; then
            # Single file case
            relative_path=$(basename "$flac_file")
        else
            # Directory case - preserve relative path
            relative_path="${flac_file#$INPUT_PATH/}"
        fi
        output_file="$OUTPUT_DIR_PATH/${relative_path%.*}.m4a"
    else
        output_file=""
    fi

    convert_flac_to_alac "$flac_file" "$output_file" "$OVERWRITE"
    case $? in
        0) ((CONVERTED++)) ;;
        2) ((SKIPPED++)) ;;
        *) ((FAILED++)) ;;
    esac
done

# Summary
echo ""
echo "=================================================="
echo "Conversion complete!"
echo "  Converted: $CONVERTED"
echo "  Skipped (already exists): $SKIPPED"
echo "  Failed: $FAILED"
echo "  Total: ${#FILES_TO_CONVERT[@]}"
echo "=================================================="

# Exit with error code if any conversions failed
if [ $FAILED -gt 0 ]; then
    exit 1
fi
