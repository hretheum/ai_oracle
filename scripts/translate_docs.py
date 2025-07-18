#!/usr/bin/env python3
"""
AI Research Oracle - Documentation Translation Script
Automatically translates English docs to Polish using DeepL API
"""

import os
import sys
import json
import frontmatter
from pathlib import Path
from deep_translator import DeeplTranslator
import re

# Configuration
SOURCE_DIR = 'docs'
TARGET_DIR = 'docs-pl'
SOURCE_LANG = 'en'
TARGET_LANG = 'pl'
GLOSSARY_FILE = 'translations/glossary.json'
OVERRIDES_FILE = 'translations/overrides.json'

# Load translation resources
def load_translation_resources():
    glossary = {}
    overrides = {}
    
    if os.path.exists(GLOSSARY_FILE):
        with open(GLOSSARY_FILE, 'r', encoding='utf-8') as f:
            glossary = json.load(f)
    
    if os.path.exists(OVERRIDES_FILE):
        with open(OVERRIDES_FILE, 'r', encoding='utf-8') as f:
            overrides = json.load(f)
            
    return glossary, overrides

# Protect code blocks and special markdown
def protect_markdown_elements(content):
    """Protect code blocks and other elements from translation"""
    protected = []
    
    # Protect code blocks
    code_pattern = r'```[\s\S]*?```|`[^`]+`'
    
    def replacer(match):
        protected.append(match.group(0))
        return f"__PROTECTED_{len(protected)-1}__"
    
    content = re.sub(code_pattern, replacer, content)
    
    # Protect links
    link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'
    
    def link_replacer(match):
        protected.append(match.group(2))  # Protect URL
        return f"[{match.group(1)}](__PROTECTED_{len(protected)-1}__)"
    
    content = re.sub(link_pattern, link_replacer, content)
    
    return content, protected

# Restore protected elements
def restore_protected_elements(content, protected):
    """Restore protected elements after translation"""
    for i, element in enumerate(protected):
        content = content.replace(f"__PROTECTED_{i}__", element)
    return content

# Apply glossary terms
def apply_glossary(content, glossary):
    """Replace terms with glossary placeholders before translation"""
    for term_en, term_pl in glossary.items():
        # Case-insensitive replacement
        pattern = re.compile(re.escape(term_en), re.IGNORECASE)
        content = pattern.sub(f"__GLOSSARY_{term_en}__", content)
    return content

# Restore glossary terms
def restore_glossary(content, glossary):
    """Replace glossary placeholders with Polish terms"""
    for term_en, term_pl in glossary.items():
        content = content.replace(f"__GLOSSARY_{term_en}__", term_pl)
    return content

# Translate file
def translate_file(source_path, target_path, translator, glossary, overrides):
    """Translate a single markdown file"""
    print(f"Translating: {source_path}")
    
    # Read source file
    with open(source_path, 'r', encoding='utf-8') as f:
        post = frontmatter.load(f)
    
    # Check for manual override
    relative_path = str(source_path)
    if relative_path in overrides:
        print(f"  Using manual override for {relative_path}")
        post.content = overrides[relative_path]
    else:
        # Protect markdown elements
        content, protected = protect_markdown_elements(post.content)
        
        # Apply glossary
        content = apply_glossary(content, glossary)
        
        # Split content into chunks (DeepL has character limits)
        chunks = []
        current_chunk = []
        current_size = 0
        
        for line in content.split('\n'):
            line_size = len(line)
            if current_size + line_size > 4000:  # Leave buffer
                chunks.append('\n'.join(current_chunk))
                current_chunk = [line]
                current_size = line_size
            else:
                current_chunk.append(line)
                current_size += line_size
        
        if current_chunk:
            chunks.append('\n'.join(current_chunk))
        
        # Translate chunks
        translated_chunks = []
        for chunk in chunks:
            if chunk.strip():  # Skip empty chunks
                try:
                    translated = translator.translate(chunk)
                    translated_chunks.append(translated)
                except Exception as e:
                    print(f"  Translation error: {e}")
                    translated_chunks.append(chunk)  # Keep original on error
            else:
                translated_chunks.append(chunk)
        
        # Combine translated chunks
        translated_content = '\n'.join(translated_chunks)
        
        # Restore glossary terms
        translated_content = restore_glossary(translated_content, glossary)
        
        # Restore protected elements
        translated_content = restore_protected_elements(translated_content, protected)
        
        post.content = translated_content
    
    # Translate metadata if present
    if 'title' in post.metadata and post.metadata['title']:
        try:
            post.metadata['title'] = translator.translate(post.metadata['title'])
        except:
            pass
    
    if 'description' in post.metadata and post.metadata['description']:
        try:
            post.metadata['description'] = translator.translate(post.metadata['description'])
        except:
            pass
    
    # Create target directory
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    
    # Save translated file
    with open(target_path, 'w', encoding='utf-8') as f:
        f.write(frontmatter.dumps(post))
    
    print(f"  Saved to: {target_path}")

# Main translation process
def main():
    # Check for API key
    api_key = os.environ.get('DEEPL_API_KEY')
    if not api_key:
        print("Error: DEEPL_API_KEY environment variable not set")
        sys.exit(1)
    
    # Initialize translator
    translator = DeeplTranslator(
        api_key=api_key,
        source=SOURCE_LANG,
        target=TARGET_LANG
    )
    
    # Load resources
    glossary, overrides = load_translation_resources()
    print(f"Loaded {len(glossary)} glossary terms and {len(overrides)} overrides")
    
    # Process all markdown files
    source_path = Path(SOURCE_DIR)
    translated_count = 0
    
    for md_file in source_path.rglob('*.md'):
        # Skip certain files
        if any(skip in str(md_file) for skip in ['node_modules', '.git', 'archive']):
            continue
            
        # Calculate target path
        relative = md_file.relative_to(source_path)
        target_file = Path(TARGET_DIR) / relative
        
        # Translate file
        try:
            translate_file(md_file, target_file, translator, glossary, overrides)
            translated_count += 1
        except Exception as e:
            print(f"Error translating {md_file}: {e}")
    
    print(f"\nTranslation complete! Translated {translated_count} files.")
    
    # Generate translation status
    generate_status_report()

# Generate status report
def generate_status_report():
    """Generate a report of translation status"""
    report = ["# Translation Status Report\n"]
    report.append(f"Generated: {os.popen('date').read().strip()}\n")
    
    source_files = set(Path(SOURCE_DIR).rglob('*.md'))
    target_files = set(Path(TARGET_DIR).rglob('*.md'))
    
    report.append(f"## Summary")
    report.append(f"- Source files (EN): {len(source_files)}")
    report.append(f"- Translated files (PL): {len(target_files)}")
    report.append(f"- Coverage: {len(target_files)/len(source_files)*100:.1f}%\n")
    
    # Find missing translations
    missing = []
    for source in source_files:
        relative = source.relative_to(SOURCE_DIR)
        target = Path(TARGET_DIR) / relative
        if not target.exists():
            missing.append(str(relative))
    
    if missing:
        report.append("## Missing Translations")
        for file in missing:
            report.append(f"- {file}")
    
    # Save report
    with open('translation-status.md', 'w', encoding='utf-8') as f:
        f.write('\n'.join(report))
    
    print("\nStatus report saved to translation-status.md")

if __name__ == "__main__":
    main()