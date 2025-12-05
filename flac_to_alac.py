#!/usr/bin/env python3
"""
FLAC to ALAC Converter Tool

Converts FLAC audio files to ALAC (Apple Lossless Audio Codec) format.
Preserves metadata and supports batch conversion.

Requirements:
    - ffmpeg must be installed (brew install ffmpeg)
    
Usage:
    python flac_to_alac.py <input_file_or_directory> [--output-dir OUTPUT_DIR]
    python flac_to_alac.py song.flac
    python flac_to_alac.py /path/to/flac/files --output-dir /path/to/output
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path


def check_ffmpeg():
    """Check if ffmpeg is installed and available."""
    try:
        result = subprocess.run(
            ['ffmpeg', '-version'],
            capture_output=True,
            text=True,
            check=True
        )
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def convert_flac_to_alac(input_file, output_file=None, overwrite=False):
    """
    Convert a single FLAC file to ALAC format.
    
    Args:
        input_file: Path to input FLAC file
        output_file: Path to output ALAC file (optional, auto-generated if not provided)
        overwrite: Whether to overwrite existing output files
    
    Returns:
        True if conversion successful, False otherwise
    """
    input_path = Path(input_file)
    
    if not input_path.exists():
        print(f"Error: File not found: {input_file}")
        return False
    
    if input_path.suffix.lower() != '.flac':
        print(f"Warning: {input_file} doesn't appear to be a FLAC file (extension: {input_path.suffix})")
    
    # Generate output filename if not provided
    if output_file is None:
        output_file = input_path.with_suffix('.m4a')
    
    output_path = Path(output_file)
    
    # Check if output file already exists
    if output_path.exists() and not overwrite:
        print(f"Skipping {input_path.name} - output file already exists: {output_path.name}")
        return False
    
    print(f"Converting: {input_path.name} -> {output_path.name}")
    
    # ffmpeg command to convert FLAC to ALAC
    # -i: input file
    # -c:a alac: use ALAC codec for audio
    # -y: overwrite output file if exists (when overwrite=True)
    # -loglevel error: only show errors
    cmd = [
        'ffmpeg',
        '-i', str(input_path),
        '-c:a', 'alac',
        '-y' if overwrite else '-n',
        '-loglevel', 'error',
        str(output_path)
    ]
    
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True
        )
        print(f"  ✓ Success: {output_path.name}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"  ✗ Error converting {input_path.name}: {e.stderr}")
        return False


def find_flac_files(directory):
    """Find all FLAC files in a directory (recursively)."""
    directory = Path(directory)
    if not directory.is_dir():
        return []
    
    return list(directory.rglob('*.flac')) + list(directory.rglob('*.FLAC'))


def main():
    parser = argparse.ArgumentParser(
        description='Convert FLAC audio files to ALAC (Apple Lossless Audio Codec) format',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s song.flac
  %(prog)s /path/to/flac/files
  %(prog)s /path/to/flac/files --output-dir /path/to/output
  %(prog)s song.flac --overwrite
        """
    )
    
    parser.add_argument(
        'input',
        help='Input FLAC file or directory containing FLAC files'
    )
    
    parser.add_argument(
        '--output-dir',
        '-o',
        help='Output directory for converted files (default: same as input)'
    )
    
    parser.add_argument(
        '--overwrite',
        action='store_true',
        help='Overwrite existing output files'
    )
    
    parser.add_argument(
        '--recursive',
        '-r',
        action='store_true',
        default=True,
        help='Recursively search for FLAC files in directories (default: True)'
    )
    
    args = parser.parse_args()
    
    # Check if ffmpeg is available
    if not check_ffmpeg():
        print("Error: ffmpeg is not installed or not in PATH.")
        print("\nTo install ffmpeg on macOS:")
        print("  brew install ffmpeg")
        print("\nOr download from: https://ffmpeg.org/download.html")
        sys.exit(1)
    
    input_path = Path(args.input)
    
    # Determine output directory
    if args.output_dir:
        output_dir = Path(args.output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
    else:
        output_dir = None
    
    # Collect files to convert
    files_to_convert = []
    
    if input_path.is_file():
        files_to_convert = [input_path]
    elif input_path.is_dir():
        files_to_convert = find_flac_files(input_path)
        if not files_to_convert:
            print(f"No FLAC files found in: {input_path}")
            sys.exit(1)
    else:
        print(f"Error: Input path does not exist: {input_path}")
        sys.exit(1)
    
    print(f"Found {len(files_to_convert)} FLAC file(s) to convert\n")
    
    # Convert files
    successful = 0
    failed = 0
    
    for flac_file in files_to_convert:
        if output_dir:
            # Preserve directory structure relative to input
            relative_path = flac_file.relative_to(input_path)
            output_file = output_dir / relative_path.with_suffix('.m4a')
            output_file.parent.mkdir(parents=True, exist_ok=True)
        else:
            output_file = None  # Will be auto-generated in same directory
        
        if convert_flac_to_alac(flac_file, output_file, args.overwrite):
            successful += 1
        else:
            failed += 1
    
    # Summary
    print(f"\n{'='*50}")
    print(f"Conversion complete!")
    print(f"  Successful: {successful}")
    print(f"  Failed: {failed}")
    print(f"  Total: {len(files_to_convert)}")
    print(f"{'='*50}")


if __name__ == '__main__':
    main()
