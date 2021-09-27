package microstaging

import (
	"encoding/json"
	"strings"

	"alpha.dagger.io/dagger"
	"alpha.dagger.io/netlify"
	"alpha.dagger.io/os"
	multistage "github.com/grouville/dagger-multistaging-environment"
)

inputs: {
	// Git Auth Token
	gitAuthToken: dagger.#Input & { dagger.#Secret }

	// Include inputs of `#Deployment` child definitions
	deploymentInputs: {
		netlifyAccount: netlify.#Account
	}
}

multistageDeployment: {
	// Collect references
	refs: multistage.#References & {
		repository: authToken: inputs.gitAuthToken
	}

	// Compute all refs as [name: #Deployment]
	deployments: multistage.#MultiDeployment & {
		"refs": json.Unmarshal(refs.out)
		"authToken": inputs.gitAuthToken
	}

	out: {
		// [string]: #Deployment
		[string]: netlify.#Site
		// Loop on all deployments
		for key, def in deployments.out {
			// Add all required deployment definitions below =>
			// Frontend deployment definition
			"\(key)-frontend": netlify.#Site & {
				"account":  inputs.deploymentInputs.netlifyAccount
				"contents": os.#Dir & {
					from: def.src
					path: "./src"
				}
				"name": strings.Replace(
					strings.Replace(def.name, "/", "-", -1),
				".", "_", -1)
			}
		}
	}
}