package microstaging

import (
	"strings"

	"alpha.dagger.io/dagger"
	"alpha.dagger.io/git"
	"alpha.dagger.io/netlify"
	"alpha.dagger.io/os"
)

// Apply Deployment on each Git ref
#MultiDeployment: {
	// References collected as JSON
	refs:  dagger.#Artifact

	// Git Auth Token
	authToken: dagger.#Secret

	if refs.references != null {
		// Iterate on references 
		out: {
			[string]: #Deployment

			for val in refs.references {
				"\(val)": #Deployment & {
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

// Wraps all deployments #Def to apply on a Git ref
#Deployment: {
	// Git ref source directory
	src: dagger.#Artifact

	// Deployment name
	name: string

	// Add all required deployment definitions below =>
	// Frontend deployment definition
	frontend: netlify.#Site & {
		"account":  multistageDeployment.deploymentInputs.netlifyAccount
		"contents": os.#Dir & {
			from: src
			path: "./src"
		}
		"name": strings.Replace(
			strings.Replace(name, "/", "-", -1),
		".", "_", -1)
	}
}
