# Solutions of Lecture 8

1. Most makefiles provide a target called `clean`. This isn’t intended to produce a file called `clean`, but instead to clean up any files that can be re-built by make. Think of it as a way to "undo" all of the build steps. Implement a clean target for the `paper.pdf` `Makefile` above. You will have to make the target `phony`. You may find the `git ls-files` subcommand useful. A number of other very common make targets are listed here.

```
paper.pdf: paper.tex plot-data.png
	pdflatex paper.tex

plot-%.png: %.dat plot.py
	./plot.py -i $*.dat -o $@

.PHONY: clean

clean:
	git ls-files . --exclude-standard --others | xargs -I '{}' rm '{}' ;\
```

2. Take a look at the various ways to specify version requirements for dependencies in Rust’s build system. Most package repositories support similar syntax. For each one (caret, tilde, wildcard, comparison, and multiple), try to come up with a use-case in which that particular kind of requirement makes sense.

- **caret**: in a production environment, use version `^x.y.0` so you can get all bugfixes but ensure that features and API remain compatible.
- **tilde**: make you application dependent on version `x.0.0` and use specification `~x`, this way you can get new features and fixes without API compatibility problems since major is fixed.
- **comparison**: ensure compatibility with version `x.0.0` and then your application will be compatible with `x.y.z`. For example, there are a lot of libraries that depend on python 3 (note that the minor nor patch are specified).
- **multiple**: test your application against majors `x.0.0` and `X.0.0` (`x` < `X`) of a dependency, if it (luckily) works, then use comparison specification so the users of both majors can use your library, `* < x.0.0, > X.0.0`.

3. Set up a simple auto-published page using GitHub Pages. Add a GitHub Action to the repository to run shellcheck on any shell files in that repository (here is one way to do it). Check that it works! 

See solution to exercise 4.

4. Build your own GitHub action to run proselint or write-good on all the .md files in the repository. Enable it in your repository, and check that it works by filing a pull request with a typo in it.

I've built a workflow that performs two jobs: proselint and shellcheck. The former one is custom and the later is from [here](https://github.com/marketplace/actions/shellcheck).

- [Dockerfile](../../../.github/actions/proselint/Dockerfile)
- [action.yaml](../../../.github/actions/proselint/action.yaml)
- [entrypoint.sh](../../../.github/actions/proselint/entrypoint.sh)

However, the custom action needs to be improved in order to exit when `proselint` detects bad writting practices.
