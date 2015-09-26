# merge-n-reveal
Create a single Reveal.js index file from a bunch of files containing topic-specific slides

* Step 1: Create a bunch of topic files that contain slides within \<section\> tags. Say, basic\_magic.html, thaumaturgy\_basic.html, thaumaturgy\_advanced.html, boom\_and\_kaboom.html, veil\_and\_vanish.html

* Step 2: When you want to create a Reveal.js presentation, decide what topics should go in this presentation, and make a JSON file similar to the ones below: 

#####  defensive\_magic.json
```json
{
    "files": [
        "basic_magic",
        "./subfolder_path/thaumaturgy_basic",
        "./subfolder_path/veil_and_vanish",
    ]
}
```

#####  offensive\_magic.json
```json
{
    "files": [
        "basic_magic",
        {
            "./subfolder_path": [
                "boom_and_kaboom",
                "thaumaturgy_basic",
                "thaumaturgy_advanced",
            ]
        }
    ],
    "theme": "beige"
}
```

* Step 3: Run `merge_n_reveal.pl --topicsfile /path/to/your_magic.json --revealdir <reveal.js repository folder>`.

* Step 4: Check out the `present` folder within the folder that contains `your_magic.json`: that folder is now your presentation, and its index.html contains all the content from the slides you mentioned in the order you mentioned them.

TODO:

* Make the reading of `index.html` content more robust with HTML::TreeBuilder or something


