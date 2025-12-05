# FLAC to ALAC Converter Tool

A simple command-line tool to convert FLAC audio files to ALAC (Apple Lossless Audio Codec) format for use with iTunes and Apple devices.

## Quick Start

### Convert a single file:
```bash
python3 flac_to_alac.py song.flac
```

### Convert all FLAC files in a directory:
```bash
python3 flac_to_alac.py /path/to/flac/files
```

### Convert to a specific output directory:
```bash
python3 flac_to_alac.py /path/to/flac/files --output-dir /path/to/output
```

### Using the wrapper script:
```bash
./flac2alac song.flac
```

## Features

- ✅ Lossless conversion (FLAC → ALAC)
- ✅ Preserves metadata (tags, artwork, etc.)
- ✅ Batch conversion support
- ✅ Recursive directory scanning
- ✅ Progress feedback
- ✅ Error handling

## Requirements

- Python 3.6+
- `ffmpeg` (already installed on your system via Homebrew)

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
| **This script** | CLI | ✅ | ✅ | ⭐⭐⭐ |
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
- Make script executable: `chmod +x flac_to_alac.py`

**Files not converting**
- Check that input files are actually FLAC format
- Verify ffmpeg supports ALAC: `ffmpeg -codecs | grep alac`

## License

Free to use and modify as needed.
