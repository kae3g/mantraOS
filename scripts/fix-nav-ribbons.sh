#!/bin/bash

# Fix navigation ribbons in all markdown files to be under 80 characters

find . -name "*.md" -exec grep -l "🔙 Return to the Dragon" {} \; | \
while read file; do
    echo "Fixing navigation ribbon in: $file"
    
    # Fix the main navigation ribbon pattern
    local pattern='🔙 Return to the Dragon'\''s Front Door: '\
'\[README\.md\](README\.md) 🗺️ Repository Map'
    local replacement='🔙 Return to the Dragon'\''s Front Door: '\
'[README.md](README.md) 🗺️\nRepository Map'
    sed -i '' "s/$pattern/$replacement/" "$file"
    
    # Fix the lantern scroll pattern
    local pattern2='(lantern scroll): \[REPOSITORY\.md\](REPOSITORY\.md) '\
'📚 Curriculum Index: \[030-edu\/000-curriculum\.md\](030-edu\/000-curriculum\.md)'
    local replacement2='(lantern scroll): [REPOSITORY.md](REPOSITORY.md) '\
'📚\nCurriculum Index: [030-edu\/000-curriculum.md](030-edu\/000-curriculum.md)'
    sed -i '' "s/$pattern2/$replacement2/" "$file"
    
    # Fix the sadhana pattern
    local pattern3='🧘 Spiritual Practice: '\
'\[001-sadhana\.md\](001-sadhana\.md)'
    local replacement3='🧘 Spiritual Practice: '\
'[001-sadhana.md](001-sadhana.md)'
    sed -i '' "s/$pattern3/$replacement3/" "$file"
done

echo "Navigation ribbon fixes complete."
