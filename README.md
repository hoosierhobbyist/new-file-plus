# New File Plus - A better way to `ctrl-n`

This package overrides the existing `new-file` command to provide a more powerful and convenient way to create multiple files at once. Using the package [juliangruber/brace-expansion](http://github.com/juliangruber/brace-expansion), bash-like brace expansion can be used to specify a concise pattern that expands into a very large number of files. Original inspiration: [atom/atom#6537](http://github.com/atom/atom/issues/6537).

## Examples
```
a{b,c,d}.txt => ab.txt, ac.txt, ad.txt
a{1..3}.txt => a1.txt, a2.txt, a3.txt
a{M..P}.txt => aM.txt, aN.txt, aO.txt, aP.txt
a{b,c{1..3},d}.txt => ab.txt, ac1.txt, ac2.txt, ac3.txt, ad.txt
a{b..d}{1,2}.txt => ab1.txt, ab2.txt, ac1.txt, ac2.txt, ad1.txt, ad2.txt
```

## Other Features
* Create new directories by ending a pattern with either `/` or `\`
* Safe mode option to prevent overwriting existing files
* Save on creation option to automatically save new files to disk
* Base directory option that will be prepended to all relative paths
