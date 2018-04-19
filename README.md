# merge-n-reveal
Create a Reveal.js presentation by merging multiple HTML slides as specified.

* Step 1: Create individual slides as HTML content within \<section\> tags. Say, basic\_magic.html, thaumaturgy\_basic.html, thaumaturgy\_advanced.html, boom\_and\_kaboom.html, veil\_and\_vanish.html

* Step 2: When you want to create a Reveal.js presentation, decide what topics should go in this presentation, and make a JSON file similar to the ones below: 

#####  defensive\_magic.json
```json
{
    "title": "Defensive magic",
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
    "title": "Offensive magic!",
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

* Step 3: Run `merge_n_reveal.pl --topicsfile content/folder/your_magic.json --revealdir <reveal.js repository folder>`.

* Step 4: Check out the `present` folder under `content/folder/` (the folder that contains the json file): your presentation is now in this `present` folder. Its index.html contains the content from the slides mentioned in the manifest in order, and can be opened in any browser as a presentation. 

Note: 

* The `reveal.js` repository has to be downloaded separately, and then its path given as an argument to this script

* If a slide is just specified by name, the script looks for it under `content/folder/slides/`. If it's a relative path, it's treated as relative to the `content/folder/` (i.e. the folder that contains the manifest json. 

TODO:

* Find a way to allow discontinuous slides from a single folder. In general, make the file inclusion syntax saner (maybe just remove the complex `"{ ./subfolder_path": [ ... ] }` form and require path specification for every slide individually).
* Better names for things

