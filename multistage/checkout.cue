package multistage

import (
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/git"
)

// Inputs map of references
// Returns a map: {"name": dagger.#Artifact}
#Checkouts: {
	// References collected as JSON
	refs:  dagger.#Artifact

	// Git Auth Token
	authToken: dagger.#Secret

	if refs.references != null {
		// Iterate on references 
		out: {
			[string]: dagger.#Artifact

			for val in refs.references {
				"\(val)": git.#Repository & {
					remote:      refs.url
					ref:         "\(val)"
					keepGitDir:  true
					"authToken": authToken
				}
			}
		}
	}
}