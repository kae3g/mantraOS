#!/bin/bash

# Fix Uddhava Gita verse citations that are too long

find . -name "*.md" -exec grep -l "SB 11\." {} \; | while read file; do
    echo "Fixing verses in: $file"
    
    # Fix the common SB 11.19.36 pattern
    pattern='> \*\*SB 11\.19\.36\*\* \*dayā bhūteṣu santuṣṭiḥ titikṣoparatiḥ śamaḥ ahiṁsā satyam'
    replacement='> **SB 11.19.36** *dayā bhūteṣu santuṣṭiḥ titikṣoparatiḥ śamaḥ*\n> *ahiṁsā satyam*'
    sed -i '' "s/${pattern}/${replacement}/" "$file" || true
    
    # Fix other long verse patterns
    pattern2='> \*\*SB 11\.7\.39\*\* \*jñānaṁ niṣṭhāṁ ca vijñānaṁ dhairyaṁ śauryaṁ balaṁ smṛtiḥ'
    replacement2='> **SB 11.7.39** *jñānaṁ niṣṭhāṁ ca vijñānaṁ dhairyaṁ śauryaṁ*\n> *balaṁ smṛtiḥ*'
    sed -i '' "s/${pattern2}/${replacement2}/" "$file" || true
    
    pattern3='> \*\*SB 11\.7\.43\*\* \*yathā taror mūla-niṣecanena tṛpyanti tat-skandha-bhujopaśākhāḥ'
    replacement3='> **SB 11.7.43** *yathā taror mūla-niṣecanena tṛpyanti*\n> *tat-skandha-bhujopaśākhāḥ*'
    sed -i '' "s/${pattern3}/${replacement3}/" "$file" || true
done

echo "Verse fixes complete."
