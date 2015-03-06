# merge-n-reveal
Create a single Reveal.js index file from a bunch of files containing topic-specific slides

* Step 1: Create a bunch of topic files that contain slides within \<section\> tags. For eg., basic\_magic.html, boom\_and\_kaboom.html, veil\_and\_vanish.html
* Step 2: When you want to create a Reveal.js presentation, decide what topics should go in this presentation, and make a JSON file similar to the ones below: 

  1. offensive\_magic.json
```json
{
    "files": [
        /path/to/basic_magic.html,
        /path/to/boom_and_kaboom.html,
    ]
}
```

  2. defensive\_magic.json
```json
{
    "files": [
        /path/to/basic_magic.html,
        /path/to/veil_and_vanish.html
    ]
}
```

* Step 3: Run `merge_n_reveal.pl your_magic.json` to get a your\_magic.html file which has all the slides which were mentioned in the json file, along with the basic reveal.js boilerplate

* Step 4: Copy the generated html file into the reveal.js folder as `index.html` 


