#!/bin/bash

# Fix navigation ribbons in all markdown files to be under 80 characters

find . -name "*.md" -exec grep -l "🔙 Return to the Dragon" {} \; | \
while read file; do
    echo "Fixing navigation ribbon in: $file"
    
    # Fix the main navigation ribbon pattern
    pattern='🔙 Return to the Dragon'\''s Front Door: \[README\.md\]\(README\.md\) 🗺️ Repository Map'
    replacement='🔙 Return to the Dragon'\''s Front Door: [README.md](README.md) 🗺️\nRepository Map'
    sed -E -i '' "s|${pattern}|${replacement}|" "$file" || true
    
    # Fix the lantern scroll pattern
    pattern2='(lantern scroll): \[REPOSITORY\.md\]\(REPOSITORY\.md\) 📚 Curriculum Index: \[030-edu\/000-curriculum\.md\]\(030-edu\/000-curriculum\.md\)'
    replacement2='(lantern scroll): [REPOSITORY.md](REPOSITORY.md) 📚\nCurriculum Index: [030-edu/000-curriculum.md](030-edu/000-curriculum.md)'
    sed -E -i '' "s|${pattern2}|${replacement2}|" "$file" || true
    
    # Fix the sadhana pattern (normalize spacing only)
    pattern3='🧘 Spiritual Practice: \[001-sadhana\.md\]\(001-sadhana\.md\)'
    replacement3='🧘 Spiritual Practice: [001-sadhana.md](001-sadhana.md)'
    sed -E -i '' "s|${pattern3}|${replacement3}|" "$file" || true
done

echo "Navigation ribbon fixes complete."
