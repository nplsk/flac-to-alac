# FLAC to ALAC Converter Tool

A simple command-line tool to convert FLAC audio files to ALAC (Apple Lossless Audio Codec) format for use with iTunes and Apple devices.

Available as both a **standalone bash script** and a **zsh function** for easy use in your terminal.

## Quick Start

### Zsh Function (Recommended)

If installed in your `.zshrc`, simply use:

```bash
f2a                    # Convert all FLAC files in current directory
f2a song.flac          # Convert single file
f2a /path/to/flac/files  # Convert all FLAC files in directory
f2a /path/to/flac/files --output-dir /path/to/output  # Convert to specific directory
```

### Standalone Bash Script

**Convert a single file:**
```bash
./flac_to_alac.sh song.flac
```

**Convert all FLAC files in a directory:**
```bash
./flac_to_alac.sh /path/to/flac/files
```

**Convert to a specific output directory:**
```bash
./flac_to_alac.sh /path/to/flac/files --output-dir /path/to/output
```

**Make executable (if needed):**
```bash
chmod +x flac_to_alac.sh
```

## Installation

### Install as Zsh Function

Add this to your `~/.zshrc`:

```bash
# FLAC to ALAC converter function
f2a() {
  local target="${1:-.}"
  local output_dir="${2:-}"
  local overwrite="${3:-}"
  
  # Build command
  local cmd="$HOME/Sites/flac-to-alac/flac_to_alac.sh"
  
  if [ -n "$output_dir" ]; then
    cmd="$cmd --output-dir \"$output_dir\""
  fi
  
  if [ "$overwrite" = "--overwrite" ]; then
    cmd="$cmd --overwrite"
  fi
  
  eval "$cmd \"$target\""
}
```

Or simply source the function file if provided.

## Features

- ✅ Lossless conversion (FLAC → ALAC)
- ✅ Preserves metadata (tags, artwork, etc.)
- ✅ Batch conversion support
- ✅ Recursive directory scanning
- ✅ Progress feedback with colors
- ✅ Error handling
- ✅ Works as standalone script or zsh function

## Requirements

- Bash 4.0+ (standard on macOS) or Zsh
- `ffmpeg` (install with `brew install ffmpeg`)

## Why ALAC?

Apple devices and iTunes don't natively support FLAC files. ALAC (Apple Lossless Audio Codec) provides:
- **Lossless quality** - Same audio quality as FLAC
- **iTunes/iOS compatibility** - Works seamlessly with Apple ecosystem
- **Smaller file size** - Typically 5-10% smaller than FLAC
- **Metadata support** - Full support for tags and album art

## Alternative Options

If you prefer GUI tools or other solutions:

### 1. **X Lossless Decoder (XLD)** ⭐ Recommended for macOS
- **Free, open-source** macOS app
- Drag-and-drop interface
- Excellent metadata preservation
- Download: https://sourceforge.net/projects/xld/

### 2. **MediaHuman Audio Converter**
- Free GUI application
- Batch conversion
- iTunes integration
- Download: https://www.mediahuman.com/audio-converter/

### 3. **Audacity** (with FFmpeg plugin)
- Free audio editor
- Can export to ALAC after installing FFmpeg plugin
- More complex workflow
- Download: https://www.audacityteam.org/

### 4. **Online Converters**
- FreeConvert.com, CloudConvert, etc.
- No installation required
- Limited to small files/batches
- Privacy concerns for large libraries

### 5. **Command-line alternatives**

**Using ffmpeg directly:**
```bash
ffmpeg -i input.flac -c:a alac output.m4a
```

**Batch conversion with find:**
```bash
find . -name "*.flac" -exec sh -c 'ffmpeg -i "$1" -c:a alac "${1%.flac}.m4a"' _ {} \;
```

## Comparison

| Tool | Type | Batch | Metadata | Ease of Use |
|------|------|-------|----------|-------------|
| **This script** | CLI | ✅ | ✅ | ⭐⭐⭐⭐ |
| **XLD** | GUI | ✅ | ✅ | ⭐⭐⭐⭐⭐ |
| **MediaHuman** | GUI | ✅ | ✅ | ⭐⭐⭐⭐ |
| **Audacity** | GUI | ❌ | ✅ | ⭐⭐ |
| **Online** | Web | Limited | ⚠️ | ⭐⭐⭐ |

## Tips

1. **Backup first**: Always keep your original FLAC files as backup
2. **Test one file**: Convert a single file first to verify quality
3. **Metadata**: The script preserves tags, but you may want to verify with a tag editor
4. **Storage**: ALAC files are slightly smaller than FLAC, saving some disk space

## Troubleshooting

**"ffmpeg not found"**
- Install with: `brew install ffmpeg`

**"Permission denied"**
- Make script executable: `chmod +x flac_to_alac.sh`

**Files not converting**
- Check that input files are actually FLAC format
- Verify ffmpeg supports ALAC: `ffmpeg -codecs | grep alac`

## License

Free to use and modify as needed.
