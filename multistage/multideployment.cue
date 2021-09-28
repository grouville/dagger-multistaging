package multistage

import (
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/git"
)

// Compute each ref, and export back chosen keys
// Here: git repo at specific ref and name
#ComputedRefs: {
	// References collected as JSON
	refs:  dagger.#Artifact

	// Git Auth Token
	authToken: dagger.#Secret

	if refs.references != null {
		// Iterate on references 
		out: {
			[string]: #OutputRef

			for val in refs.references {
				"\(val)": #OutputRef & {
					// Compute src directory
					src: git.#Repository & {
						remote:      refs.url
						ref:         "\(val)"
						keepGitDir:  true
						"authToken": authToken
					}
					name: val
				}
			}
		}
	}
}

// Wraps all outputed keys to export
// from ref computation
#OutputRef: {
	// Git ref source directory
	src: dagger.#Artifact

	// Deployment name
	name: string
}
