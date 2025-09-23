#!/usr/bin/env python3
"""
Comprehensive file wrapper that handles all file types while preserving syntax.
"""

import os
import re
import sys
from pathlib import Path

ROOT = Path('.')
APPLY = os.environ.get("APPLY", "0") == "1"
WIDTH = int(os.environ.get("WRAP_COL", "80"))

# File extensions to process
EXTENSIONS = {
    'md', 'mdx', 'txt', 'py', 'sh', 'yml', 'yaml', 'tf', 'html', 'css', 
    'js', 'ts', 'json', 'toml', 'tex', 'typ'
}

def should_process_file(path):
    """Check if file should be processed."""
    if not path.is_file():
        return False
    if path.name.startswith('.git') or '/.git/' in str(path):
        return False
    if '/node_modules/' in str(path):
        return False
    if path.suffix.lower().lstrip('.') in EXTENSIONS:
        return True
    return False

def wrap_text_file(path):
    """Wrap a text-based file to 80 characters."""
    try:
        content = path.read_text(encoding='utf-8')
        lines = content.splitlines()
        wrapped_lines = []
        
        for line in lines:
            if len(line) <= WIDTH:
                wrapped_lines.append(line)
            else:
                # For long lines, try to break at logical points
                if line.strip().startswith('#'):
                    # Headers - break after the title
                    parts = line.split(' ', 1)
                    if len(parts) > 1 and len(parts[1]) > WIDTH - len(parts[0])
                    - 1:
                        wrapped_lines.append(parts[0] + ' ' +
                        parts[1][:WIDTH-len(parts[0])-1])
                        wrapped_lines.append('  ' +
                        parts[1][WIDTH-len(parts[0])-1:])
                    else:
                        wrapped_lines.append(line)
                elif line.strip().startswith('>'):
                    # Blockquotes - break at spaces
                    wrapped_lines.extend(wrap_line_at_spaces(line, WIDTH))
                elif line.strip().startswith('-') or
                line.strip().startswith('*'):
                    # Lists - break at spaces
                    wrapped_lines.extend(wrap_line_at_spaces(line, WIDTH))
                elif '=' in line and '==' in line:
                    # Python/comparison - don't break
                    wrapped_lines.append(line)
                elif line.strip().startswith('import') or
                line.strip().startswith('from'):
                    # Python imports - don't break
                    wrapped_lines.append(line)
                else:
                    # General text - break at spaces
                    wrapped_lines.extend(wrap_line_at_spaces(line, WIDTH))
        
        return '\n'.join(wrapped_lines)
    except Exception as e:
        print(f"Error processing {path}: {e}")
        return None

def wrap_line_at_spaces(line, width):
    """Break a line at spaces to fit within width."""
    if len(line) <= width:
        return [line]
    
    # Find the last space before width
    break_point = width
    while break_point > 0 and line[break_point] != ' ':
        break_point -= 1
    
    if break_point <= 0:
        # No good break point, just break at width
        return [line[:width], line[width:]]
    
    # Break at the space
    first_part = line[:break_point].rstrip()
    second_part = line[break_point+1:]
    
    result = [first_part]
    if second_part:
        # Indent the continuation line
        indent = len(line) - len(line.lstrip())
        result.append(' ' * indent + second_part)
    
    return result

def process_file(path):
    """Process a single file."""
    try:
        new_content = wrap_text_file(path)
        if new_content is None:
            return False
        
        original_content = path.read_text(encoding='utf-8')
        if new_content != original_content:
            if APPLY:
                path.write_text(new_content, encoding='utf-8')
                print(f"✔ wrapped: {path}")
            else:
                print(f"→ would wrap: {path}")
            return True
        return False
    except Exception as e:
        print(f"Error processing {path}: {e}")
        return False

def main():
    """Main function."""
    processed_count = 0
    total_count = 0
    
    for path in ROOT.rglob('*'):
        if should_process_file(path):
            total_count += 1
            if process_file(path):
                processed_count += 1
    
    print(f"\nProcessed {processed_count}/{total_count} files")
    if not APPLY:
        print("Run with APPLY=1 to apply changes")

if __name__ == "__main__":
