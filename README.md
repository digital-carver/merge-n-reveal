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

* Step 3: Run `merge_n_reveal.pl your_magic.json` to get a your\_magic.html file which has all the slides which were mentioned in the json file, along with the basic reveal.js boilerplate

* Step 4: Copy the generated html file into the reveal.js folder as `index.html` 


