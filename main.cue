package microstaging

import (
	// "encoding/json"
	"strings"

	"alpha.dagger.io/dagger"
	"alpha.dagger.io/git"
	"alpha.dagger.io/netlify"
	"alpha.dagger.io/os"
)

// Debug
// pat: dagger.#Input & { dagger.#Secret }

// Deploy microstage
deployment: #MultiDeployment

// Apply Deployment on each Git ref
#MultiDeployment: {
	// References collected
	refs: dagger.#Input & { dagger.#Artifact }
	// refs: json.Unmarshal(jsonTest)
	gitAuthToken: dagger.#Input & { dagger.#Secret } // To change

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
						"authToken": gitAuthToken
					}
					name: val
				}
			}
		}
	}
}

// Add definition that includes all inputs of #Deployment
// Tokens wrapper
netlifyAccount: netlify.#Account

// Wraps all deployments to execute on a Git ref
#Deployment: {
	// Git ref source directory
	src: dagger.#Artifact

	// Deployment name
	name: string

	// Add all required deployment definitions below =>
	// Frontend deployment definition
	frontend: netlify.#Site & {
		"account":  netlifyAccount
		"contents": os.#Dir & {
			from: src
			path: "./src"
		}
		"name": strings.Replace(
			strings.Replace(name, "/", "-", -1),
		".", "_", -1)
	}
}
