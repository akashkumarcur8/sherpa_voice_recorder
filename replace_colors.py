#!/usr/bin/env python3
"""
Script to replace hardcoded Color values with AppColors constants
"""
import os
import re
from pathlib import Path

# Color mapping: hex value -> AppColors constant name
COLOR_MAP = {
    '0xFF565ADD': 'AppColors.primaryPurple',
    '0xFF2E3077': 'AppColors.primaryPurpleDark',
    '0xFF7B7FEE': 'AppColors.primaryPurpleLight',
    '0xFF6A5AE0': 'AppColors.secondaryPurple',
    '0xFFE5E5FF': 'AppColors.lightPurple',
    '0xFFD6D9FF': 'AppColors.rosePink',
    '0xFF9C27B0': 'AppColors.avatarDeepPurple',
    '0xFFC4D0FB': 'AppColors.purpleBackground',
    
    # Text colors
    '0xFF212121': 'AppColors.textPrimary',
    '0xFF1A1A1A': 'AppColors.textDark',
    '0xFF31373D': 'AppColors.textPrimaryLight',
    '0xFF757575': 'AppColors.textSecondary',
    '0xFF9D9D9D': 'AppColors.textMedium',
    '0xFFAFB0B0': 'AppColors.textLight',
    '0xFF555E67': 'AppColors.textLabel',
    '0xFFBDBDBD': 'AppColors.textHint',
    '0xFFE0E0E0': 'AppColors.textDisabled',
    '0xFFD32F2F': 'AppColors.textError',
    '0xFF7B7676': 'AppColors.textGrey',
    
    # Backgrounds
    '0xFFF5F5F5': 'AppColors.background',
    '0xFFF8F9FC': 'AppColors.backgroundLight',
    '0xFFFFFFFF': 'AppColors.white',
    '0xFFFAFAFA': 'AppColors.scaffoldBackground',
    '0xFFEFEFEF': 'AppColors.iconBackground',
    '0xFFE2FFE9': 'AppColors.backgroundSuccess',
    '0xFFC9F2E9': 'AppColors.backgroundSuccessAlt',
    '0xFFFFEFEF': 'AppColors.backgroundError',
    '0xFFE8F0FF': 'AppColors.backgroundInfo',
    '0xFFFFF9C2': 'AppColors.backgroundWarning',
    '0xFFFFD6DD': 'AppColors.backgroundPink',
    '0xFFD6F0FF': 'AppColors.backgroundBlue',
    
    # Borders
    '0xFFEBEBEB': 'AppColors.borderLight',
    '0xFFE5E5E5': 'AppColors.borderMedium',
    '0xFFECEDF0': 'AppColors.inputBorder',
    '0xFF5B5FED': 'AppColors.borderFocused',
    '0xFFDFDFDF': 'AppColors.dividerLight',
    
    # Status colors
    '0xFF4CAF50': 'AppColors.success',
    '0xFF0EC16E': 'AppColors.successGreen',
    '0xFF00E244': 'AppColors.successBright',
    '0xFFFFA726': 'AppColors.warning',
    '0xFFF44336': 'AppColors.error',
    '0xFFFF4444': 'AppColors.errorRed',
    '0xFF2196F3': 'AppColors.info',
    
    # Accents
    '0xFFFFC93D': 'AppColors.goldAccent',
    '0xFFFFD51A': 'AppColors.yellowAccent',
    '0xFF5EDEC3': 'AppColors.tealAccent',
    '0xFFFF6B84': 'AppColors.pinkAccent',
    '0xFF6BB8FF': 'AppColors.blueAccent',
    '0xFF00BCD4': 'AppColors.avatarCyan',
    
    # Avatars
    '0xFFFF9800': 'AppColors.avatarOrange',
    '0xFFE91E63': 'AppColors.avatarPink',
    '0xFFFF5722': 'AppColors.avatarDeepOrange',
    
    # Basic
    '0xFF000000': 'AppColors.black',
    '0xFF9E9E9E': 'AppColors.grey',
    '0xFF616161': 'AppColors.darkGrey',
    
    # Special gradients (handled separately)
    '0xFFD4B2FB': 'Color(0xFFD4B2FB)',  # Keep for gradient
}

def process_file(file_path):
    """Process a single Dart file to replace colors"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        modified = False
        needs_import = False
        
        # Replace Color(0xFFXXXXXX) with AppColors.xxx
        for hex_color, app_color in COLOR_MAP.items():
            pattern = rf'Color\({hex_color}\)'
            if re.search(pattern, content):
                content = re.sub(pattern, app_color, content)
                modified = True
                if 'AppColors.' in app_color:
                    needs_import = True
        
        # Add import if needed and not already present
        if needs_import and "import '../../../core/constants/app_colors.dart';" not in content:
            # Find the last import statement
            import_pattern = r"(import\s+['\"].*?['\"];)"
            imports = list(re.finditer(import_pattern, content))
            if imports:
                last_import = imports[-1]
                insert_pos = last_import.end()
                # Determine correct relative path based on file location
                rel_path = get_relative_import_path(file_path)
                content = content[:insert_pos] + f"\nimport '{rel_path}';" + content[insert_pos:]
                modified = True
        
        if modified:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def get_relative_import_path(file_path):
    """Calculate relative import path to app_colors.dart"""
    # Count directory depth from lib/app/
    parts = Path(file_path).parts
    try:
        app_index = parts.index('app')
        depth = len(parts) - app_index - 2  # -2 for 'app' and filename
        return '../' * depth + 'core/constants/app_colors.dart'
    except ValueError:
        return '../../../core/constants/app_colors.dart'  # fallback

def main():
    """Main function to process all Dart files"""
    lib_path = Path('lib/app/modules')
    dart_files = list(lib_path.rglob('*.dart'))
    
    print(f"Found {len(dart_files)} Dart files to process...")
    modified_count = 0
    
    for dart_file in dart_files:
        if process_file(dart_file):
            modified_count += 1
            print(f"✓ Modified: {dart_file}")
    
    print(f"\nCompleted! Modified {modified_count} files.")

if __name__ == '__main__':
    main()
